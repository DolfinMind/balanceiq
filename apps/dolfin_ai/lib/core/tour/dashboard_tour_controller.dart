import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:dolfin_core/tour/product_tour_cubit.dart';
import 'package:dolfin_core/tour/product_tour_state.dart';
import 'package:dolfin_core/tour/tour_widget_factory.dart';
import 'package:get_it/get_it.dart';
import 'package:balance_iq/core/strings/dashboard_strings.dart';

/// Controller for managing the dashboard tour.
///
/// Encapsulates all tour-related logic that was previously in [_DashboardViewState].
class DashboardTourController {
  final BuildContext context;
  final GlobalKey profileIconKey;

  TutorialCoachMark? _tutorialCoachMark;
  bool _tourShown = false;

  bool _isDisposing = false; // Add this flag

  DashboardTourController({
    required this.context,
    required this.profileIconKey,
  });

  /// Show the profile icon tour if conditions are met.
  void showProfileIconTour() {
    if (_tourShown || _isDisposing) return; // Check flag

    if (profileIconKey.currentContext == null) {
      if (_isDisposing) return; // Check flag before delayed task
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_isDisposing) showProfileIconTour(); // Check flag
      });
      return;
    }

    _tourShown = true;
    final tourCubit = context.read<ProductTourCubit>();

    final targets = [
      TargetFocus(
        identify: 'profile_icon',
        keyTarget: profileIconKey,
        alignSkip: Alignment.bottomRight,
        enableOverlayTab: false,
        enableTargetTab: true,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return GetIt.instance<TourWidgetFactory>().createTooltip(
                icon: Icons.person_outline_rounded,
                title: GetIt.I<DashboardStrings>().completeProfile,
                description: GetIt.I<DashboardStrings>().verifyEmailSetup,
                buttonText: 'Got it',
                onButtonPressed: () {
                  controller.next();
                },
                showSkip: true,
                onSkip: () {
                  tourCubit.skipTour();
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
    ];

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.8,
      hideSkip: true,
      onClickOverlay: (target) {},
      onClickTarget: (target) {
        tourCubit.onProfileIconTapped();
        Navigator.pushNamed(context, '/profile');
      },
      onFinish: () {
        // Prevent navigation if controller is disposing (e.g. logout)
        if (_isDisposing) return;
        tourCubit.onProfileIconTapped();
        Navigator.pushNamed(context, '/profile');
      },
      onSkip: () {
        tourCubit.skipTour();
        return true;
      },
    );

    if (!_isDisposing) {
      _tutorialCoachMark!.show(context: context);
    }
  }

  /// Check initial dashboard state and trigger tour if needed.
  void checkAndTriggerTour({
    required bool isOnboarded,
    required VoidCallback onTourCheckDone,
  }) {
    final tourCubit = context.read<ProductTourCubit>();
    tourCubit.checkAndStartTourIfNeeded(isOnboarded: isOnboarded);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_isDisposing && tourCubit.isAtStep(TourStep.dashboardProfileIcon)) {
        showProfileIconTour();
      }
    });

    onTourCheckDone();
  }

  /// Dispose of the tutorial coach mark.
  void dispose() {
    _isDisposing = true;
    _tutorialCoachMark?.finish();
  }
}
