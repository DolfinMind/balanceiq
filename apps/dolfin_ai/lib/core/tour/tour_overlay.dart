import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dolfin_core/tour/product_tour_cubit.dart';
import 'package:dolfin_core/tour/product_tour_state.dart';

/// A modal-based tour overlay that doesn't require GlobalKeys.
/// Shows instruction cards with visual indicators pointing to UI areas.
class TourOverlay extends StatelessWidget {
  final Widget child;

  const TourOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductTourCubit, ProductTourState>(
      builder: (context, state) {
        if (state is TourActive && !state.isTransitioning) {
          return Stack(
            children: [
              child,
              _buildTourStep(context, state.currentStep),
            ],
          );
        }
        return child;
      },
    );
  }

  Widget _buildTourStep(BuildContext context, TourStep step) {
    switch (step) {
      case TourStep.dashboardProfileIcon:
        return _TourCard(
          title: 'Welcome to Dolfin AI! 👋',
          description:
              'Tap on the profile icon in the top-left corner to set up your account.',
          arrowPosition: ArrowPosition.topLeft,
          buttonText: 'Got it!',
          onButtonPressed: () {
            // Just dismiss - user will tap the icon naturally
            context.read<ProductTourCubit>().onProfileIconTapped();
          },
          onSkip: () => context.read<ProductTourCubit>().skipTour(),
          showSkip: true,
        );

      case TourStep.profileSubscription:
        return _TourCard(
          title: 'Choose Your Plan 💳',
          description:
              'Select a subscription plan to unlock all features. Start with the free plan!',
          arrowPosition: ArrowPosition.center,
          buttonText: 'Got it!',
          onButtonPressed: () {
            // Just dismiss - user will tap subscribe naturally
          },
          onSkip: () => context.read<ProductTourCubit>().skipTour(),
          showSkip: true,
        );
      case TourStep.chatInputHint:
        return _TourCard(
          title: 'Start Tracking! 💰',
          description:
              'Type your first income or expense here.\n\nExample: "Got my salary 76k on December 1st"',
          arrowPosition: ArrowPosition.bottom,
          buttonText: 'Let\'s Go!',
          onButtonPressed: () {
            context.read<ProductTourCubit>().completeTour();
          },
          onSkip: () => context.read<ProductTourCubit>().skipTour(),
          showSkip: false,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

enum ArrowPosition { topLeft, top, center, bottom }

class _TourCard extends StatelessWidget {
  final String title;
  final String description;
  final ArrowPosition arrowPosition;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final VoidCallback onSkip;
  final bool showSkip;

  const _TourCard({
    required this.title,
    required this.description,
    required this.arrowPosition,
    required this.buttonText,
    required this.onButtonPressed,
    required this.onSkip,
    this.showSkip = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: SafeArea(
        child: _buildPositionedCard(context),
      ),
    );
  }

  Widget _buildPositionedCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final card = Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).hintColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (showSkip)
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip Tour',
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Position the card based on arrow position
    switch (arrowPosition) {
      case ArrowPosition.topLeft:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 60),
              child: _buildArrow(context, direction: _ArrowDirection.up),
            ),
            const SizedBox(height: 8),
            card,
          ],
        );
      case ArrowPosition.top:
        return Column(
          children: [
            const SizedBox(height: 120),
            Center(child: _buildArrow(context, direction: _ArrowDirection.up)),
            const SizedBox(height: 8),
            card,
          ],
        );
      case ArrowPosition.center:
        return Center(child: card);
      case ArrowPosition.bottom:
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            card,
            const SizedBox(height: 8),
            Center(
                child: _buildArrow(context, direction: _ArrowDirection.down)),
            const SizedBox(height: 100),
          ],
        );
    }
  }

  Widget _buildArrow(BuildContext context,
      {required _ArrowDirection direction}) {
    return Icon(
      direction == _ArrowDirection.up
          ? Icons.arrow_upward_rounded
          : Icons.arrow_downward_rounded,
      color: Theme.of(context).colorScheme.primary,
      size: 40,
    );
  }
}

enum _ArrowDirection { up, down }
