import 'package:equatable/equatable.dart';

/// Enum representing the current step in the product tour
enum TourStep {
  /// Tour has not started
  notStarted,

  /// Step 1: Highlight profile icon on dashboard
  dashboardProfileIcon,


  /// Step 3: Highlight subscription card on profile page
  profileSubscription,

  /// Step 4: Show chat input hint with example message
  chatInputHint,

  /// Tour is completed
  completed,
}

/// Base class for all product tour states
abstract class ProductTourState extends Equatable {
  const ProductTourState();

  @override
  List<Object?> get props => [];
}

/// Tour is inactive (not started or user hasn't signed up yet)
class TourInactive extends ProductTourState {
  const TourInactive();
}

/// Tour is currently active at a specific step
class TourActive extends ProductTourState {
  final TourStep currentStep;
  final bool isTransitioning;

  const TourActive({
    required this.currentStep,
    this.isTransitioning = false,
  });

  TourActive copyWith({
    TourStep? currentStep,
    bool? isTransitioning,
  }) {
    return TourActive(
      currentStep: currentStep ?? this.currentStep,
      isTransitioning: isTransitioning ?? this.isTransitioning,
    );
  }

  @override
  List<Object?> get props => [currentStep, isTransitioning];
}

/// Tour has been completed
class TourCompleted extends ProductTourState {
  const TourCompleted();
}

/// Tour was skipped by the user
class TourSkipped extends ProductTourState {
  const TourSkipped();
}

/// Tour is loading (checking persistence state)
class TourLoading extends ProductTourState {
  const TourLoading();
}
