import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/message.dart';
import 'package:dolfin_core/constants/app_constants.dart';
import '../cubit/chat_cubit.dart';
import 'message_bubble.dart';
import 'typing_indicator.dart';

class MessageList extends StatelessWidget {
  final List<Message> messages;
  final String botId;
  final String botName;
  final bool isSending;
  final bool hasMore;
  final bool isLoadingMore;
  final ScrollController? scrollController;
  final EdgeInsets? padding;

  const MessageList({
    super.key,
    required this.messages,
    required this.botId,
    required this.botName,
    this.isSending = false,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.scrollController,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty && !isSending) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: Image.asset(
                'assets/icons/app_icon.png',
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hi! I\'m your $botName.',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _getWelcomeMessage(botId),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      controller: scrollController,
      reverse: true,
      slivers: [
        // Bottom Spacer (dynamic padding for floating widget)
        SliverToBoxAdapter(
          child: SizedBox(height: padding?.bottom ?? 16),
        ),

        // Message List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (isSending) {
                  if (index == 0) {
                    return _buildTypingIndicator(context);
                  }
                  // Adjust index for typing indicator
                  final messageIndex = index - 1;
                  if (messageIndex < messages.length) {
                    final message = messages[messageIndex];
                    final isUser = message.sender ==
                        GetIt.instance<AppConstants>().senderUser;
                    // When sending, the first message (index 0) is typing indicator,
                    // so index 1 (messageIndex 0) is the last message.
                    final isLastMessage = messageIndex == 0;

                    return MessageBubble(
                      message: message,
                      isUser: isUser,
                      botName: botName,
                      isLastMessage: isLastMessage,
                      onRetry: (isUser && message.hasError)
                          ? () => context
                              .read<ChatCubit>()
                              .retryMessage(message)
                          : null,
                    );
                  }
                  return null;
                }

                // Normal behavior (not sending)
                if (index < messages.length) {
                  final message = messages[index];
                  final isUser = message.sender ==
                      GetIt.instance<AppConstants>().senderUser;
                  // In reversed list, index 0 is the last message
                  final isLastMessage = index == 0;

                  return MessageBubble(
                    message: message,
                    isUser: isUser,
                    botName: botName,
                    isLastMessage: isLastMessage,
                    onRetry: (isUser && message.hasError)
                        ? () => context
                            .read<ChatCubit>()
                            .retryMessage(message)
                        : null,
                  );
                }
                return null;
              },
              childCount: isSending
                  ? messages.length + 1
                  : messages.length, // +1 for Typing indicator
            ),
          ),
        ),

        // Pagination Loading Indicator (at top when scrolling up)
        if (isLoadingMore)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Top Padding
        SliverPadding(padding: EdgeInsets.only(top: padding?.top ?? 16)),
      ],
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: TypingIndicator(),
    );
  }

  String _getWelcomeMessage(String botId) {
    final constants = GetIt.instance<AppConstants>();
    if (botId == constants.balanceTrackerID) {
      return 'I can help you track your expenses and monitor your financial position.';
    } else if (botId == constants.investmentGuruID) {
      return 'I can provide insights and tips on investment options and strategies.';
    } else if (botId == constants.budgetPlannerID) {
      return 'I can assist you in creating budgets and managing your finances.';
    } else if (botId == constants.finTipsID) {
      return 'I can share financial literacy tips and smart money habits.';
    } else {
      return 'How can I help you today?';
    }
  }
}
