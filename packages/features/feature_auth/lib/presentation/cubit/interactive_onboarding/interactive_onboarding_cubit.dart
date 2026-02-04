import 'package:flutter_bloc/flutter_bloc.dart';

part 'interactive_onboarding_state.dart';

/// Story script for the salary day simulation
class _StoryScript {
  static const List<Map<String, dynamic>> sequence = [
    {
      'delay': 500,
      'type': 'narrator',
      'content': "It's payday! You just received your salary... 💰",
    },
    {
      'delay': 2000,
      'type': 'user',
      'content': 'Got my salary 50,000 taka',
    },
    {
      'delay': 1500,
      'type': 'bot',
      'content':
          "Great! I've added ৳50,000 income to your balance.\n\n💵 Balance: ৳50,000",
    },
    {
      'delay': 2500,
      'type': 'narrator',
      'content': 'Now your rent is due...',
    },
    {
      'delay': 1500,
      'type': 'user',
      'content': 'Paid 15k rent',
    },
    {
      'delay': 1500,
      'type': 'bot',
      'content':
          "Recorded ৳15,000 expense under Rent.\n\n💵 Balance: ৳35,000\n📊 Saved: 70% of salary!",
    },
  ];
}

/// Cubit for managing interactive onboarding state
class InteractiveOnboardingCubit extends Cubit<InteractiveOnboardingState> {
  InteractiveOnboardingCubit() : super(const InteractiveOnboardingState());

  int _scriptIndex = 0;
  bool _isPlayingStory = false;

  /// Move to the next screen
  void nextScreen() {
    if (state.currentScreen < 2) {
      emit(state.copyWith(currentScreen: state.currentScreen + 1));

      // Auto-start story when entering story screen
      if (state.currentScreen == 1) {
        startStory();
      }
    }
  }

  /// Go back to previous screen
  void previousScreen() {
    if (state.currentScreen > 0) {
      emit(state.copyWith(currentScreen: state.currentScreen - 1));
    }
  }

  /// Start playing the salary day story
  Future<void> startStory() async {
    if (_isPlayingStory || isClosed) return;
    _isPlayingStory = true;
    _scriptIndex = 0;

    emit(state.copyWith(
      storyPlaying: true,
      storyCompleted: false,
      messages: [],
    ));

    await _playNextScriptItem();
  }

  Future<void> _playNextScriptItem() async {
    if (isClosed) return;

    if (_scriptIndex >= _StoryScript.sequence.length) {
      // Story complete
      _isPlayingStory = false;
      if (!isClosed) {
        emit(state.copyWith(
          storyPlaying: false,
          storyCompleted: true,
        ));
      }
      return;
    }

    final item = _StoryScript.sequence[_scriptIndex];
    final delay = item['delay'] as int;
    final type = item['type'] as String;
    final content = item['content'] as String;

    // Wait for the delay
    await Future.delayed(Duration(milliseconds: delay));

    if (isClosed) return;
    if (!_isPlayingStory) return; // Cancelled

    // Add typing indicator for bot messages
    if (type == 'bot') {
      final typingMessage = SimulatedMessage(
        id: 'typing_$_scriptIndex',
        content: '',
        isUser: false,
        isTyping: true,
        timestamp: DateTime.now(),
      );
      if (!isClosed) {
        emit(state.copyWith(messages: [...state.messages, typingMessage]));
      }

      await Future.delayed(const Duration(milliseconds: 800));
      if (isClosed) return;
      if (!_isPlayingStory) return;

      // Replace typing with actual message
      final messages =
          state.messages.where((m) => m.id != 'typing_$_scriptIndex').toList();
      final actualMessage = SimulatedMessage(
        id: 'msg_$_scriptIndex',
        content: content,
        isUser: false,
        timestamp: DateTime.now(),
      );
      if (!isClosed) {
        emit(state.copyWith(messages: [...messages, actualMessage]));
      }
    } else {
      // User or narrator message
      final message = SimulatedMessage(
        id: 'msg_$_scriptIndex',
        content: content,
        isUser: type == 'user',
        timestamp: DateTime.now(),
      );
      if (!isClosed) {
        emit(state.copyWith(messages: [...state.messages, message]));
      }
    }

    _scriptIndex++;
    await _playNextScriptItem();
  }

  /// Skip the story animation
  void skipStory() {
    _isPlayingStory = false;

    // Show all messages immediately
    final allMessages = _StoryScript.sequence
        .where((item) => item['type'] != 'narrator')
        .toList()
        .asMap()
        .entries
        .map((entry) => SimulatedMessage(
              id: 'msg_${entry.key}',
              content: entry.value['content'] as String,
              isUser: entry.value['type'] == 'user',
              timestamp: DateTime.now(),
            ))
        .toList();

    emit(state.copyWith(
      messages: allMessages,
      storyPlaying: false,
      storyCompleted: true,
    ));
  }

  /// Handle user practice input
  Future<void> submitPractice(String input) async {
    if (input.trim().isEmpty || isClosed) return;

    emit(state.copyWith(userInput: input));

    // Add user message
    final userMessage = SimulatedMessage(
      id: 'practice_user',
      content: input,
      isUser: true,
      timestamp: DateTime.now(),
    );
    if (!isClosed)
      emit(state.copyWith(messages: [...state.messages, userMessage]));

    // Add typing indicator
    await Future.delayed(const Duration(milliseconds: 300));
    if (isClosed) return;

    final typingMessage = SimulatedMessage(
      id: 'practice_typing',
      content: '',
      isUser: false,
      isTyping: true,
      timestamp: DateTime.now(),
    );
    if (!isClosed)
      emit(state.copyWith(messages: [...state.messages, typingMessage]));

    await Future.delayed(const Duration(milliseconds: 1000));
    if (isClosed) return;

    // Replace with bot response
    final messages =
        state.messages.where((m) => m.id != 'practice_typing').toList();
    final botResponse = SimulatedMessage(
      id: 'practice_bot',
      content: _generatePracticeResponse(input),
      isUser: false,
      timestamp: DateTime.now(),
    );

    if (!isClosed) {
      emit(state.copyWith(
        messages: [...messages, botResponse],
        userPracticed: true,
        showCelebration: true,
      ));
    }

    // Hide celebration after delay
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!isClosed) {
      emit(state.copyWith(showCelebration: false));
    }
  }

  String _generatePracticeResponse(String input) {
    // Parse amount from input
    final amountRegex = RegExp(r'(\d+)');
    final match = amountRegex.firstMatch(input);
    final amount = match?.group(1) ?? '100';

    // Detect category
    String category = 'Others';
    final lowercaseInput = input.toLowerCase();
    if (lowercaseInput.contains('rickshaw') ||
        lowercaseInput.contains('uber') ||
        lowercaseInput.contains('pathao')) {
      category = 'Transport';
    } else if (lowercaseInput.contains('chai') ||
        lowercaseInput.contains('coffee') ||
        lowercaseInput.contains('tea')) {
      category = 'Food & Drinks';
    } else if (lowercaseInput.contains('lunch') ||
        lowercaseInput.contains('dinner') ||
        lowercaseInput.contains('breakfast')) {
      category = 'Food';
    }

    return "✅ Recorded ৳$amount expense under $category!\n\nThat's how easy it is! 🎉";
  }

  /// Reset state for practice screen
  void resetForPractice() {
    emit(state.copyWith(
      messages: [],
      userPracticed: false,
      userInput: null,
      showCelebration: false,
    ));
  }

  /// Reset entire onboarding
  void reset() {
    _isPlayingStory = false;
    _scriptIndex = 0;
    emit(const InteractiveOnboardingState());
  }
}
