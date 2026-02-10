import 'package:flutter_bloc/flutter_bloc.dart';

import '../analytics/analytics_service.dart';
import 'product_tour_service.dart';
import 'product_tour_state.dart';

/// Cubit for managing the product tour lifecycle.
///
/// Handles all tour state transitions:
/// - Starting the tour based on onboarded flag from API
/// - Advancing through tour steps
/// - Handling email verification acknowledgment
/// - Completing or skipping the tour via API
class ProductTourCubit extends Cubit<ProductTourState> {
  final ProductTourService _tourService;
  final AnalyticsService _analyticsService;

  ProductTourCubit({
    required ProductTourService tourService,
    required AnalyticsService analyticsService,
  })  : _tourService = tourService,
        _analyticsService = analyticsService,
        super(const TourInactive());

  /// Check if tour should start based on the onboarded status from dashboard API.
  /// This should be called from HomePage after dashboard is loaded.
  /// @param isOnboarded - the onboarded field from DashboardSummary
  Future<void> checkAndStartTourIfNeeded({required bool isOnboarded}) async {
    // Only start if currently inactive and user is not onboarded
    if (state is TourInactive && !isOnboarded) {
      await startTour();
    } else if (isOnboarded &&
        state is! TourCompleted &&
        state is! TourSkipped) {
      // User is already onboarded
      emit(const TourCompleted());
    }
  }

  /// Check if the initialization has completed (no longer loading)
  bool get isInitialized => state is! TourLoading;

  /// Start the product tour
  Future<void> startTour() async {
    if (state is TourCompleted || state is TourSkipped) {
      return;
    }

    const firstStep = TourStep.dashboardProfileIcon;
    await _tourService.saveTourStep(firstStep);

    // Log tutorial_begin
    _analyticsService.logEvent(name: 'tutorial_begin');

    emit(const TourActive(currentStep: firstStep));
  }

  /// Advance to a specific tour step
  Future<void> advanceToStep(TourStep step) async {
    if (state is! TourActive) return;

    // Mark as transitioning briefly
    emit((state as TourActive).copyWith(isTransitioning: true));

    // Small delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 300));

    await _tourService.saveTourStep(step);
    emit(TourActive(currentStep: step, isTransitioning: false));
  }

  /// Called when user taps profile icon during step 1
  Future<void> onProfileIconTapped() async {
    if (state is! TourActive) return;
    final currentState = state as TourActive;

    if (currentState.currentStep == TourStep.dashboardProfileIcon) {
      await advanceToStep(TourStep.profileSubscription);
    }
  }


  /// Called when user successfully subscribes to a plan
  Future<void> onSubscriptionCreated() async {
    if (state is! TourActive) return;
    final currentState = state as TourActive;

    if (currentState.currentStep == TourStep.profileSubscription) {
      await advanceToStep(TourStep.chatInputHint);
    }
  }

  /// Called when user sends their first message or dismisses chat hint
  Future<void> onChatInteraction() async {
    if (state is! TourActive) return;
    final currentState = state as TourActive;

    if (currentState.currentStep == TourStep.chatInputHint) {
      await completeTour();
    }
  }

  /// Complete the tour successfully (calls API to mark as onboarded)
  Future<void> completeTour() async {
    await _tourService.markTourCompleted();

    // Log tutorial_complete with skipped=false
    _analyticsService.logEvent(
      name: 'tutorial_complete',
      parameters: {'skipped': false},
    );

    emit(const TourCompleted());
  }

  /// Skip the entire tour (calls API to mark as onboarded)
  Future<void> skipTour() async {
    await _tourService.markTourSkipped();

    // Log tutorial_complete with skipped=true
    _analyticsService.logEvent(
      name: 'tutorial_complete',
      parameters: {'skipped': true},
    );

    emit(const TourSkipped());
  }

  /// Reset tour state (for testing purposes)
  Future<void> resetTour() async {
    await _tourService.resetTour();
    emit(const TourInactive());
  }

  /// Open mail app (delegates to service)
  Future<bool> openMailApp() async {
    return await _tourService.openMailApp();
  }

  /// Check if tour is currently active at a specific step
  bool isAtStep(TourStep step) {
    if (state is! TourActive) return false;
    return (state as TourActive).currentStep == step;
  }

  /// Check if tour is active (at any step)
  bool get isTourActive => state is TourActive;

  /// Get current step if tour is active
  TourStep? get currentStep {
    if (state is! TourActive) return null;
    return (state as TourActive).currentStep;
  }
}
