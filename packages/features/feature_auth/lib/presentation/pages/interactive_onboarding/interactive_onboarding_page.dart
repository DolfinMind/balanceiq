import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:feature_auth/presentation/cubit/interactive_onboarding/interactive_onboarding_cubit.dart';
import '../../widgets/celebration_animation.dart';
import 'onboarding_welcome_screen.dart';
import 'salary_day_story_screen.dart';
import 'try_it_yourself_screen.dart';

/// Main controller for the interactive onboarding flow
class InteractiveOnboardingPage extends StatefulWidget {
  const InteractiveOnboardingPage({super.key});

  @override
  State<InteractiveOnboardingPage> createState() =>
      _InteractiveOnboardingPageState();
}

class _InteractiveOnboardingPageState extends State<InteractiveOnboardingPage> {
  late PageController _pageController;
  late InteractiveOnboardingCubit _cubit;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _cubit = InteractiveOnboardingCubit();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _goToNextScreen() {
    final currentPage = _pageController.page?.round() ?? 0;
    if (currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _cubit.nextScreen();

      // Start story automatically when entering story screen
      if (currentPage == 0) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _cubit.startStory();
        });
      }

      // Reset for practice screen
      if (currentPage == 1) {
        _cubit.resetForPractice();
      }
    }
  }

  void _goToPreviousScreen() {
    final currentPage = _pageController.page?.round() ?? 0;
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _cubit.previousScreen();
    }
  }

  void _skipOnboarding() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _completeOnboarding() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar with Skip
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Back button (shown after first screen)
                    BlocBuilder<InteractiveOnboardingCubit,
                        InteractiveOnboardingState>(
                      builder: (context, state) {
                        if (state.currentScreen > 0) {
                          return IconButton(
                            onPressed: _goToPreviousScreen,
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: colorScheme.onSurface,
                            ),
                          );
                        }
                        return const SizedBox(width: 48);
                      },
                    ),
                    const Spacer(),
                    // Skip button
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Indicator
              BlocBuilder<InteractiveOnboardingCubit,
                  InteractiveOnboardingState>(
                builder: (context, state) {
                  return OnboardingProgressIndicator(
                    totalSteps: 3,
                    currentStep: state.currentScreen,
                  );
                },
              ),

              const SizedBox(height: 16),

              // Page View
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    // Sync cubit with page changes
                    // This is mainly for programmatic navigation tracking
                  },
                  children: [
                    // Screen 1: Welcome
                    OnboardingWelcomeScreen(
                      onStart: _goToNextScreen,
                      onSkip: _skipOnboarding,
                    ),

                    // Screen 2: Salary Day Story
                    SalaryDayStoryScreen(
                      onContinue: _goToNextScreen,
                      onSkip: _skipOnboarding,
                    ),

                    // Screen 3: Try It Yourself
                    TryItYourselfScreen(
                      onComplete: _completeOnboarding,
                      onSkip: _skipOnboarding,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
