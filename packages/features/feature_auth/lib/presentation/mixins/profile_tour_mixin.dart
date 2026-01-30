import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:dolfin_core/tour/product_tour_cubit.dart';
import 'package:dolfin_core/tour/product_tour_state.dart';
import 'package:dolfin_core/tour/tour_widget_factory.dart';
import 'package:feature_auth/presentation/pages/profile_page.dart';
import 'package:get_it/get_it.dart';

mixin ProfileTourMixin on State<ProfilePage> {
  TutorialCoachMark? _tutorialCoachMark;

  bool _subscriptionTourShown = false;

  final GlobalKey subscriptionCardKey = GlobalKey();

  void checkAndShowTour() {
    if (!mounted) return;

    final tourCubit = context.read<ProductTourCubit>();
    final tourState = tourCubit.state;

    if (tourState is TourActive) {
      if (tourState.currentStep == TourStep.profileSubscription) {
        showSubscriptionTour();
      }
    }
  }

  void showSubscriptionTour() {
    if (_subscriptionTourShown) return;
    if (subscriptionCardKey.currentContext == null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) showSubscriptionTour();
      });
      return;
    }

    _subscriptionTourShown = true;
    final tourCubit = context.read<ProductTourCubit>();

    final targets = [
      TargetFocus(
        identify: 'subscription',
        keyTarget: subscriptionCardKey,
        alignSkip: Alignment.bottomRight,
        enableOverlayTab: false,
        enableTargetTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 20,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return GetIt.instance<TourWidgetFactory>().createTooltip(
                icon: Icons.card_membership_outlined,
                title: 'Choose a Plan',
                description:
                    'Subscribe to start tracking your finances. We have a free plan to get you started!',
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

    _showTutorial(targets, tourCubit);
  }

  void _showTutorial(List<TargetFocus> targets, ProductTourCubit tourCubit) {
    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.8,
      hideSkip: true,
      onClickOverlay: (target) {},
      onFinish: () {},
      onSkip: () {
        tourCubit.skipTour();
        return true;
      },
    );

    _tutorialCoachMark!.show(context: context);
  }

  void disposeTour() {
    _tutorialCoachMark?.finish();
  }
}
