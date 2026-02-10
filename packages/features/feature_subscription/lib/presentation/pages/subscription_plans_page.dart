import 'package:get_it/get_it.dart';
import 'package:dolfin_core/constants/core_strings.dart';
import 'package:feature_subscription/constants/subscription_strings.dart';
import 'package:dolfin_core/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:dolfin_ui_kit/theme/app_typography.dart';
import 'package:dolfin_core/tour/product_tour_cubit.dart';
import 'package:dolfin_core/tour/product_tour_state.dart';

import 'package:feature_chat/presentation/pages/chat_page.dart';
import 'package:feature_auth/presentation/pages/webview_page.dart';
import 'package:feature_subscription/domain/entities/plan.dart';
import 'package:feature_subscription/presentation/cubit/subscription_cubit.dart';
import 'package:feature_subscription/presentation/cubit/subscription_state.dart';
import 'package:feature_auth/presentation/widgets/profile/profile_shimmer.dart';

class SubscriptionPlansPage extends StatelessWidget {
  const SubscriptionPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SubscriptionCubit>(
      create: (_) => GetIt.instance<SubscriptionCubit>()..loadPlansAndStatus(),
      child: const _SubscriptionPlansView(),
    );
  }
}

class _SubscriptionPlansView extends StatelessWidget {
  const _SubscriptionPlansView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        final showAppBar = state is! CreatingSubscription;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: showAppBar
              ? AppBar(
                  leading: IconButton(
                    icon: Icon(
                      LucideIcons.arrowLeft,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    GetIt.I<SubscriptionStrings>().choosePlanTitle,
                    style: AppTypography.titleXLargeSemiBold.copyWith(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                )
              : null,
          body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
            listener: (context, state) {
              if (state is SubscriptionCreated) {
                // Check if tour is active at subscription step
                final tourCubit = context.read<ProductTourCubit>();
                if (tourCubit.isAtStep(TourStep.profileSubscription)) {
                  // Advance tour and navigate to chat
                  tourCubit.onSubscriptionCreated();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatPage(
                        botId: "nai kichu",
                        botName: 'Dolfin AI',
                      ),
                    ),
                  );
                } else {
                  // Check if we should return to chat page
                  final args = ModalRoute.of(context)?.settings.arguments;
                  final returnToChat = args is Map<String, dynamic> &&
                      args['returnToChat'] == true;

                  if (returnToChat) {
                    // Pop back to chat page so .then() callback reloads chat
                    Navigator.pop(context);
                  } else {
                    // Navigate back to profile page
                    Navigator.popUntil(
                        context,
                        (route) =>
                            route.settings.name == '/profile' || route.isFirst);
                  }
                }
              } else if (state is SubscriptionError) {
                if (context.mounted) {
                  SnackbarUtils.showError(context, state.message);
                }
                // Reload plans after error
                context.read<SubscriptionCubit>().loadPlansAndStatus();
              }
            },
            builder: (context, state) {
              if (state is PlansLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is CreatingSubscription) {
                return const ProfileShimmer();
              }

              if (state is PlansLoaded) {
                return _buildPlansContent(context, state.plans,
                    state.subscriptionStatus?.subscription?.plan?.name);
              }

              if (state is SubscriptionError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.circleX,
                          size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context
                            .read<SubscriptionCubit>()
                            .loadPlansAndStatus(),
                        child: Text(GetIt.I<CoreStrings>().common.retry),
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      },
    );
  }

  Widget _buildPlansContent(
      BuildContext context, List<Plan> plans, String? currentPlanName) {
    // Sort plans by tier
    final sortedPlans = List<Plan>.from(plans)
      ..sort((a, b) => a.tier.compareTo(b.tier));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Plan Cards
          ...sortedPlans.map((plan) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildPlanCard(
                  context,
                  plan: plan,
                  isCurrentPlan: plan.name == currentPlanName,
                  isPopular: plan.tier == 2, // Pro plan is typically tier 2
                ),
              )),
          const SizedBox(height: 12),
          // Footer Links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewPage(
                        title: GetIt.I<SubscriptionStrings>().termsOfService,
                        url: 'https://dolfinmind.com/terms-of-service',
                      ),
                    ),
                  );
                },
                child: Text(
                  GetIt.I<SubscriptionStrings>().termsOfService,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewPage(
                        title: GetIt.I<SubscriptionStrings>().privacyPolicy,
                        url: 'https://dolfinmind.com/privacy-policy',
                      ),
                    ),
                  );
                },
                child: Text(
                  GetIt.I<SubscriptionStrings>().privacyPolicy,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildPlanCard(
    BuildContext context, {
    required Plan plan,
    required bool isCurrentPlan,
    required bool isPopular,
  }) {
    final displayPrice = plan.price;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPopular
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPopular
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: isPopular ? 48 : 24,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  plan.displayName,
                  style: AppTypography.headlineMediumBold.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  plan.description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 16),
                // Price
                if (!plan.isComingSoon) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${displayPrice.toStringAsFixed(0)}',
                        style: AppTypography.displayLarge.copyWith(
                          color:
                              Theme.of(context).textTheme.displayLarge?.color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          GetIt.I<SubscriptionStrings>().perMonth,
                          style: AppTypography.bodyLarge.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                // Features
                ...plan.features.take(4).map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.circleCheck,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature.name,
                              style: AppTypography.bodyLarge.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan || plan.isComingSoon
                        ? null
                        : () {
                            context
                                .read<SubscriptionCubit>()
                                .createSubscription(
                                  planName: plan.name,
                                  autoRenew: true,
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan || plan.isComingSoon
                          ? Theme.of(context).disabledColor
                          : isPopular
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isCurrentPlan
                          ? GetIt.I<SubscriptionStrings>().currentPlan
                          : plan.isComingSoon
                              ? 'Coming Soon'
                              : GetIt.I<SubscriptionStrings>().subscribeButton,
                      style: AppTypography.buttonMedium.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Popular Badge
          if (isPopular)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Text(
                  GetIt.I<SubscriptionStrings>().mostPopular,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMediumSemiBold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          // Current Plan Badge
          if (isCurrentPlan)
            Positioned(
              top: isPopular ? 40 : 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  GetIt.I<SubscriptionStrings>().active,
                  style: AppTypography.captionSemiBold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
