import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:dolfin_core/services/biometric_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:feature_auth/constants/auth_strings.dart';
import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:dolfin_core/tour/product_tour_cubit.dart';
import 'package:dolfin_core/tour/product_tour_state.dart';
import 'package:dolfin_core/tour/email_sent_modal.dart';
import 'package:dolfin_core/utils/snackbar_utils.dart';
import 'package:feature_subscription/presentation/cubit/subscription_cubit.dart';
import 'package:feature_subscription/presentation/cubit/subscription_state.dart';
import "package:feature_auth/presentation/cubit/session/session_cubit.dart";

import 'package:dolfin_ui_kit/theme/theme_cubit.dart';
import 'package:dolfin_ui_kit/theme/theme_state.dart';
import '../widgets/profile/profile_widgets.dart';
import '../widgets/profile/currency_selector_sheet.dart';
import '../mixins/profile_tour_mixin.dart';
import '../widgets/profile/subscription_card_states.dart';
import 'webview_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with ProfileTourMixin, WidgetsBindingObserver {
  bool _hasOpenedCurrencyPicker = false;

  // App Lock Logic
  bool _isAppLockEnabled = false;
  final _biometricService = GetIt.instance<BiometricAuthService>();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<SessionCubit>().refreshUserProfile();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndShowTour();
      _checkBiometrics();
    });
  }

  Future<void> _checkBiometrics() async {
    final available = await _biometricService.isBiometricAvailable;
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('is_app_lock_enabled') ?? false;

    if (mounted) {
      setState(() {
        _canCheckBiometrics = available;
        _isAppLockEnabled = enabled;
      });
    }
  }

  Future<void> _toggleAppLock(bool value) async {
    if (value) {
      // Enabling: Require auth
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Authenticate to enable App Lock',
      );
      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_app_lock_enabled', true);
        setState(() => _isAppLockEnabled = true);
        SnackbarUtils.showSuccess(context, 'App Lock Enabled');
      }
    } else {
      // Disabling: Require auth
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Authenticate to disable App Lock',
      );
      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_app_lock_enabled', false);
        setState(() => _isAppLockEnabled = false);
        SnackbarUtils.showSuccess(context, 'App Lock Disabled');
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disposeTour();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh user profile when app resumes to check if email was verified
    if (state == AppLifecycleState.resumed) {
      context.read<SessionCubit>().refreshUserProfile();
    }
  }

  void _showEmailSentModal() {
    final tourCubit = context.read<ProductTourCubit>();

    EmailSentModal.show(
      context,
      onContinue: () {
        Navigator.of(context).pop(); // Close modal
        tourCubit.acknowledgeEmailSent();
        // Show subscription tour after a delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) showSubscriptionTour();
        });
      },
    );
  }

  void _checkAndShowCurrencyPicker() {
    if (_hasOpenedCurrencyPicker) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['action'] == 'open_currency_selector') {
      _hasOpenedCurrencyPicker = true;
      final returnToChat = args['returnToChat'] == true;
      _showCurrencyPicker(context, returnToChat: returnToChat);
    }
  }

  void _showCurrencyPicker(BuildContext context, {bool returnToChat = false}) {
    CurrencySelectorSheet.show(
      context,
      onSelect: (Currency currency) {
        GetIt.instance<CurrencyCubit>().setCurrency(currency);
        // Sync with backend
        context.read<SessionCubit>().updateUserCurrency(currency.code);

        SnackbarUtils.showSuccess(
          context,
          'Currency changed to ${currency.symbol} ${currency.name}',
        );

        // If navigated from chat, return after selection
        if (returnToChat) {
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check for arguments after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowCurrencyPicker();
    });

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              GetIt.instance<SubscriptionCubit>()..loadSubscriptionStatus(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<SessionCubit, SessionState>(
            listener: (context, state) {
              if (state is Unauthenticated) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              } else if (state is SessionError) {
                SnackbarUtils.showError(context, state.message);
              }
            },
          ),
          BlocListener<ProductTourCubit, ProductTourState>(
            listener: (context, tourState) {
              if (tourState is TourActive && !tourState.isTransitioning) {
                if (tourState.currentStep == TourStep.profileSubscription) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showSubscriptionTour();
                  });
                }
              }
            },
          ),
        ],
        child: Scaffold(
          body: BlocBuilder<SessionCubit, SessionState>(
            builder: (context, state) {
              if (state is SessionLoading || state is SessionInitial) {
                return const ProfileShimmer();
              }

              if (state is Authenticated) {
                final user = state.user;
                return _buildProfileContent(context, user);
              }

              return Center(
                child: Text(GetIt.I<AuthStrings>().signingIn),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, dynamic user) {
    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverSafeArea(
              bottom: false,
              sliver: SliverToBoxAdapter(
                child: SizedBox(height: 5),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Email Verification Banner (if not verified)
                    // Email Verification Banner (if not verified) - Removed for SSO
                    /*
                    if (!user.isEmailVerified)
                      Container(
                        key: emailVerifyKey,
                        child: EmailVerificationBanner(
                          user: user,
                          onVerificationClick: () {}, // No longer supported manually
                        ),
                      ),
                    */
                    // Profile Header with dynamic subscription badge
                    BlocBuilder<SubscriptionCubit, SubscriptionState>(
                      builder: (context, subState) {
                        return ProfileHeader(
                          user: user,
                          subscriptionStatus:
                              subState is SubscriptionStatusLoaded
                                  ? subState.status
                                  : null,
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    // Subscription Card with real data
                    Container(
                      key: subscriptionCardKey,
                      child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
                        builder: (context, subState) {
                          if (subState is SubscriptionStatusLoading) {
                            return const SubscriptionCardLoading();
                          }
                          if (subState is SubscriptionStatusLoaded) {
                            return SubscriptionCard(status: subState.status);
                          }
                          if (subState is SubscriptionError) {
                            return SubscriptionCardError(
                                message: subState.message);
                          }
                          return const SubscriptionCardLoading();
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Currency Selector (at top)
                    BlocBuilder<CurrencyCubit, CurrencyState>(
                      bloc: GetIt.instance<CurrencyCubit>(),
                      builder: (context, currencyState) {
                        return ProfileMenuItem(
                          icon: LucideIcons.circleDollarSign,
                          title: GetIt.I<AuthStrings>().profile.currency,
                          subtitle: currencyState.isCurrencySet
                              ? '${currencyState.currencySymbol} ${currencyState.currencyName}'
                              : 'Select Currency',
                          onTap: () => _showCurrencyPicker(context),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Account Details (Expandable)
                    ExpandableProfileMenuItem(
                      icon: LucideIcons.user,
                      title: GetIt.I<AuthStrings>().profile.accountDetails,
                      subItems: [
                        ProfileSubMenuItem(
                          icon: LucideIcons.userPen,
                          title: GetIt.I<AuthStrings>()
                              .profile
                              .updateAccountDetails,
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                                context, '/update-profile');
                            if (result == true && context.mounted) {
                              context.read<SessionCubit>().refreshUserProfile();
                            }
                          },
                        ),
                        ProfileSubMenuItem(
                          icon: LucideIcons.trash2,
                          title: GetIt.I<AuthStrings>().profile.deleteAccount,
                          iconColor: Theme.of(context).colorScheme.error,
                          titleColor: Theme.of(context).colorScheme.error,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewPage(
                                  title: GetIt.I<AuthStrings>()
                                      .profile
                                      .deleteAccount,
                                  url: 'https://dolfinmind.com/delete-account',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Security (Expandable)
                    ExpandableProfileMenuItem(
                      icon: LucideIcons.lock,
                      title: GetIt.I<AuthStrings>().profile.security,
                      subItems: [
                        // ADDED APP LOCK HERE (during restoration to save a step)
                        if (_canCheckBiometrics)
                          ProfileSubMenuItem(
                            icon: Icons.fingerprint,
                            title: 'App Lock',
                            onTap: () => _toggleAppLock(!_isAppLockEnabled),
                            trailing: Switch(
                              value: _isAppLockEnabled,
                              onChanged: (val) => _toggleAppLock(val),
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Appearance (Expandable)
                    BlocBuilder<ThemeCubit, ThemeState>(
                      builder: (context, themeState) {
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        return ExpandableProfileMenuItem(
                          icon: LucideIcons.palette,
                          title: GetIt.I<AuthStrings>().profile.appearance,
                          subItems: [
                            ProfileSubMenuItem(
                              icon: isDark ? LucideIcons.sun : LucideIcons.moon,
                              title: isDark
                                  ? 'Switch to Light Mode'
                                  : 'Switch to Dark Mode',
                              onTap: () {
                                context.read<ThemeCubit>().toggleTheme();
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Legal (Expandable)
                    ExpandableProfileMenuItem(
                      icon: LucideIcons.scale,
                      title: 'Legal',
                      subItems: [
                        ProfileSubMenuItem(
                          icon: LucideIcons.shieldCheck,
                          title: GetIt.I<AuthStrings>().profile.privacyPolicy,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewPage(
                                  title: GetIt.I<AuthStrings>()
                                      .profile
                                      .privacyPolicy,
                                  url: 'https://dolfinmind.com/privacy-policy',
                                ),
                              ),
                            );
                          },
                        ),
                        ProfileSubMenuItem(
                          icon: LucideIcons.fileText,
                          title: GetIt.I<AuthStrings>().profile.termsOfService,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewPage(
                                  title: GetIt.I<AuthStrings>()
                                      .profile
                                      .termsOfService,
                                  url:
                                      'https://dolfinmind.com/terms-of-service',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Log Out Button
                    const LogOutButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                LucideIcons.arrowLeft,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }
}
