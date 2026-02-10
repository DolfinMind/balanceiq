import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:synchronized/synchronized.dart';
import 'package:get_it/get_it.dart';

import 'package:dolfin_core/constants/app_constants.dart';
import 'package:dolfin_core/error/failures.dart';
import 'package:dolfin_core/storage/secure_storage_service.dart';
import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:dolfin_core/analytics/analytics_service.dart';
import 'dart:async';

// Feature dependencies
import 'package:feature_auth/domain/usecases/get_current_user.dart';
import 'package:feature_subscription/domain/usecases/get_subscription_status.dart';

import '../../domain/entities/message.dart';
import '../../domain/entities/message_usage.dart';
import '../../domain/entities/chat_feedback.dart';
import '../../domain/usecases/get_chat_history.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/update_message.dart';
import '../../domain/usecases/get_message_usage.dart';
import '../../domain/usecases/submit_feedback.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetMessages getMessages;
  final GetChatHistory getChatHistory;
  final GetMessageUsage getMessageUsage;
  final SendMessage sendMessage;
  final UpdateMessage updateMessage;
  final SubmitFeedback submitFeedback;
  final SecureStorageService secureStorage;
  final Uuid uuid;
  final GetCurrentUser getCurrentUser;
  final GetSubscriptionStatus getSubscriptionStatus;
  final AnalyticsService analyticsService;

  String? currentBotId;
  int _apiPage = 0;
  bool _hasMore = true;
  final Lock _lock = Lock();
  MessageUsage? _cachedMessageUsage;

  ChatCubit({
    required this.getMessages,
    required this.getChatHistory,
    required this.getMessageUsage,
    required this.sendMessage,
    required this.updateMessage,
    required this.submitFeedback,
    required this.secureStorage,
    required this.uuid,
    required this.getCurrentUser,
    required this.getSubscriptionStatus,
    required this.analyticsService,
  }) : super(ChatInitial()); // Removed const

  Future<void> loadMessageUsage() async {
    final result = await getMessageUsage();
    result.fold(
      (failure) {},
      (usage) {
        _cachedMessageUsage = usage;

        if (state is ChatLoaded) {
          emit((state as ChatLoaded).copyWith(
            messagesUsedToday: usage.messagesUsedToday,
            dailyMessageLimit: usage.dailyLimit,
            messageUsage: usage,
          ));
        }
      },
    );
  }

  Future<void> loadChatHistory(String botId) async {
    currentBotId = botId;

    emit(ChatLoading()); // Removed const
    debugPrint('[ChatDebug] ChatCubit emitted ChatLoading for botId: $botId');

    // 1. Check Email Verification (Highest Priority)
    final userResult = await getCurrentUser();
    final user = userResult.fold((l) => null, (r) => r);

    if (user != null && !user.isEmailVerified) {
      debugPrint('[ChatDebug] ChatCubit: Email not verified.');
      emit(const ChatError(
        message: 'Email not verified',
        errorType: ChatErrorType.emailNotVerified,
      ));
      return;
    }

    // 2. Check Subscription Status
    final subResult = await getSubscriptionStatus();
    final isSubscribed =
        subResult.fold((l) => false, (r) => r.hasActiveSubscription);

    if (!isSubscribed) {
      debugPrint('[ChatDebug] ChatCubit: Subscription required.');
      emit(const ChatError(
        message: 'Subscription required',
        errorType: ChatErrorType.subscriptionRequired,
      ));
      return;
    }

    // 3. Check Currency (Lowest Priority) - using CurrencyCubit state
    final currencyCubit = GetIt.instance<CurrencyCubit>();
    if (!currencyCubit.state.isCurrencySet) {
      debugPrint('[ChatDebug] ChatCubit: Currency not set.');
      emit(const ChatError(
        message: 'Currency not set',
        errorType: ChatErrorType.currencyRequired,
      ));
      return;
    }

    await loadMessageUsage();
    debugPrint('[ChatDebug] ChatCubit loaded message usage');

    final userId = await secureStorage.getUserId() ?? '';

    // Load local cached messages first
    final cachedResult = await getMessages(userId, botId, limit: 20);
    cachedResult.fold(
      (failure) {},
      (cached) {
        if (cached.isNotEmpty && !isClosed) {
          emit(ChatLoaded(
            messages: cached,
            hasMore: true,
            messagesUsedToday: _cachedMessageUsage?.messagesUsedToday ?? 0,
            messageUsage: _cachedMessageUsage,
            dailyMessageLimit: _cachedMessageUsage?.dailyLimit ??
                GetIt.instance<AppConstants>().dailyMessageLimit,
          ));
        }
      },
    );

    _apiPage = 1;

    // Load remote history (Direct call, no Params object)
    final apiResult = await getChatHistory(
      userId: userId,
      page: _apiPage,
      limit: 10,
      botId: botId,
    );

    if (!isClosed) {
      apiResult.fold(
        (failure) {
          debugPrint(
              '[ChatDebug] ChatCubit API failure: ${failure.message}, Type: ${failure is ChatApiFailure ? failure.failureType : "Unknown"}');
          final currentState = state;

          ChatErrorType? errorType;
          if (failure is ChatApiFailure) {
            errorType = _mapChatFailureType(failure.failureType);
            debugPrint('[ChatDebug] ChatCubit mapped errorType: $errorType');
          }

          if (currentState is ChatLoaded) {
            debugPrint(
                '[ChatDebug] ChatCubit emitting ChatError (preserving messages)');
            emit(ChatError(
              message: failure.message,
              messages: currentState.messages,
              errorType: errorType,
            ));
          } else {
            debugPrint(
                '[ChatDebug] ChatCubit emitting ChatError (no messages)');
            emit(ChatError(
              message: failure.message,
              errorType: errorType,
            ));
          }
        },
        (response) async {
          _hasMore = response.pagination.hasNext;

          // Sync local messages with remote logic if needed, or just fetch updated local
          // Assuming getChatHistory updates local DB, we re-fetch from local.
          final updatedResult = await getMessages(userId, botId, limit: 20);
          updatedResult.fold(
            (failure) => emit(ChatError(
              message: failure.message,
              errorType: ChatErrorType.general,
            )),
            (messages) {
              emit(ChatLoaded(
                messages: messages,
                hasMore: _hasMore,
                messagesUsedToday: _cachedMessageUsage?.messagesUsedToday ?? 0,
                messageUsage: _cachedMessageUsage,
                dailyMessageLimit: _cachedMessageUsage?.dailyLimit ??
                    GetIt.instance<AppConstants>().dailyMessageLimit,
              ));
            },
          );
        },
      );
    }
  }

  Future<void> loadMoreMessages() async {
    if (!_hasMore || currentBotId == null) {
      return;
    }

    final currentState = state;
    if (currentState is! ChatLoaded) {
      return;
    }

    if (currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    _apiPage++;
    final userId = await secureStorage.getUserId() ?? '0';

    final result = await getChatHistory(
      userId: userId,
      page: _apiPage,
      limit: 10,
      botId: currentBotId!,
    );

    if (!isClosed) {
      result.fold(
        (failure) {
          emit(currentState.copyWith(isLoadingMore: false));
        },
        (response) async {
          _hasMore = response.pagination.hasNext;

          final currentCount = currentState.messages.length;
          final updatedResult = await getMessages(userId, currentBotId!,
              limit: currentCount + 20);
          updatedResult.fold(
            (failure) => emit(currentState.copyWith(isLoadingMore: false)),
            (messages) {
              emit(ChatLoaded(
                messages: messages,
                hasMore: _hasMore,
                isLoadingMore: false,
                messagesUsedToday: _cachedMessageUsage?.messagesUsedToday ??
                    currentState.messagesUsedToday,
                messageUsage: _cachedMessageUsage ?? currentState.messageUsage,
                dailyMessageLimit: currentState.dailyMessageLimit,
              ));
            },
          );
        },
      );
    }
  }

  @Deprecated('Use loadChatHistory instead')
  Future<void> loadMessages(String botId, {bool showLoading = true}) async {
    await loadChatHistory(botId);
  }

  Future<void> sendNewMessage({
    required String botId,
    required String content,
    String? imagePath,
    String? audioPath,
  }) async {
    await _lock.synchronized(() async {
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;

        final userId = await secureStorage.getUserId() ?? '';

        final tempUserMessage = Message(
          id: uuid.v4(),
          userId: userId,
          botId: botId,
          sender: GetIt.instance<AppConstants>().senderUser,
          content: content,
          imageUrl: imagePath,
          audioUrl: audioPath,
          timestamp: DateTime.now(),
          isSending: true,
          hasError: false,
        );

        final updatedMessages = [tempUserMessage, ...currentState.messages];

        emit(currentState.copyWith(messages: updatedMessages, isSending: true));

        final result = await sendMessage(
          botId: botId,
          content: content,
          imagePath: imagePath,
          audioPath: audioPath,
        );

        // Log analytics event
        unawaited(analyticsService.logEvent(
          name: 'send_message',
          parameters: {
            'bot_id': botId,
            'has_image': (imagePath != null).toString(),
            'has_audio': (audioPath != null).toString(),
          },
        ));

        if (!isClosed) {
          result.fold((failure) {
            // Mark message as failed
            final failedMessages = updatedMessages.map((m) {
              if (m.id == tempUserMessage.id) {
                return m.copyWith(hasError: true, isSending: false);
              }
              return m;
            }).toList();

            emit(currentState.copyWith(
                messages: failedMessages, isSending: false));

            // Also show error state if critical (or snackbar usually)
            // But here we might want to keep the chat loaded.
          }, (_) async {
            // Success. Re-fetch messages to get the AI response or confirmed user message state
            final reloadResult = await getMessages(userId, botId,
                limit: updatedMessages.length + 2);
            reloadResult.fold(
                (failure) => emit(currentState.copyWith(isSending: false)),
                (messages) {
              emit(currentState.copyWith(messages: messages, isSending: false));
              loadMessageUsage();
            });
          });
        }
      }
    });
  }

  ChatErrorType _mapChatFailureType(ChatFailureType failureType) {
    switch (failureType) {
      case ChatFailureType.emailNotVerified:
        return ChatErrorType.emailNotVerified;
      case ChatFailureType.subscriptionRequired:
        return ChatErrorType.subscriptionRequired;
      case ChatFailureType.subscriptionExpired:
        return ChatErrorType.subscriptionExpired;
      case ChatFailureType.tokenLimitExceeded:
        return ChatErrorType.messageLimitExceeded;
      case ChatFailureType.rateLimitExceeded:
        return ChatErrorType.rateLimitExceeded;
      case ChatFailureType.currencyRequired:
        return ChatErrorType.currencyRequired;
      case ChatFailureType.general:
        return ChatErrorType.general;
    }
  }

  Future<void> submitMessageFeedback(
      String messageId, FeedbackType feedback) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;

      final updatedMessages = currentState.messages.map((msg) {
        if (msg.id == messageId) {
          return msg.copyWith(feedback: feedback.toApiValue());
        }
        return msg;
      }).toList();

      emit(currentState.copyWith(messages: updatedMessages));

      final updatedMessage =
          updatedMessages.firstWhere((m) => m.id == messageId);
      await updateMessage(updatedMessage);

      if (updatedMessage.conversationId != null) {
        await submitFeedback(
          messageId: updatedMessage.conversationId!,
          feedback: feedback,
        );
      }
    }
  }

  /// Retry a failed message
  Future<void> retryMessage(Message failedMessage) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;

      // Remove the failed message from the list
      final updatedMessages = currentState.messages
          .where((m) => m.id != failedMessage.id)
          .toList();

      emit(currentState.copyWith(messages: updatedMessages));

      // Re-send the message
      await sendNewMessage(
        botId: failedMessage.botId,
        content: failedMessage.content,
        imagePath: failedMessage.imageUrl,
        audioPath: failedMessage.audioUrl,
      );
    }
  }

  void clearChat() {
    if (currentBotId != null) {
      emit(ChatLoaded(
        messages: const [],
        dailyMessageLimit: GetIt.instance<AppConstants>().dailyMessageLimit,
      ));
    }
  }
}
