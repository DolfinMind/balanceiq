import 'package:dolfin_ui_kit/theme/app_palette.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dolfin_core/utils/app_logger.dart';

import 'package:balance_iq/core/config/app_network_config.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

import 'core/di/injection_container.dart' as di;
import 'core/navigation/navigator_service.dart';
import 'core/widgets/app_lock_wrapper.dart';
import 'package:get_it/get_it.dart';
import 'package:dolfin_ui_kit/theme/app_theme.dart';
import 'package:dolfin_ui_kit/theme/theme_cubit.dart';
import 'package:dolfin_ui_kit/theme/theme_state.dart';
import 'core/tour/tour.dart';
import 'package:feature_auth/presentation/cubit/session/session_cubit.dart';
import 'package:feature_auth/presentation/cubit/login/login_cubit.dart';
import 'package:feature_auth/presentation/cubit/signup/signup_cubit.dart';
import 'package:feature_auth/presentation/cubit/password/password_cubit.dart';
import 'package:dolfin_core/currency/currency_cubit.dart';

// Pages
import "package:feature_auth/presentation/pages/change_password_page.dart";
import "package:feature_auth/presentation/pages/email_verification_page.dart";
import "package:feature_auth/presentation/pages/forgot_password_page.dart";
import 'package:feature_auth/presentation/pages/loading_page.dart';
import "package:feature_auth/presentation/pages/login_page.dart";
import 'package:feature_auth/presentation/pages/splash_page.dart';
import "package:feature_auth/presentation/pages/onboarding_page.dart";
import "package:feature_auth/presentation/pages/signup_page.dart";
import 'package:feature_auth/presentation/pages/interactive_onboarding/interactive_onboarding_page.dart';
import "package:feature_auth/presentation/pages/profile_page.dart";
import "package:feature_auth/presentation/pages/reset_password_page.dart";
import "package:feature_auth/presentation/pages/verification_success_page.dart";
import 'features/home/presentation/cubit/dashboard_cubit.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/pages/transactions_page.dart';
import 'package:feature_subscription/presentation/pages/manage_subscription_page.dart';
import 'package:feature_subscription/presentation/pages/subscription_plans_page.dart';
import 'package:feature_auth/presentation/pages/update_profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  AppNetworkConfig.init();

  // 1. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await di.init();

  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    FlutterError.presentError(details);
    AppLogger.error(
      'Flutter Error',
      error: details.exception,
      stackTrace: details.stack,
      name: 'GlobalErrorHandler',
    );
  };

  // Handle async platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    AppLogger.error(
      'Platform Error',
      error: error,
      stackTrace: stack,
      name: 'GlobalErrorHandler',
    );
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: GetIt.instance<AppPalette>().backgroundLight,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: GetIt.instance<AppPalette>().error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: GetIt.instance<AppPalette>().textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  details.exceptionAsString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: GetIt.instance<AppPalette>().textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // SessionCubit replaces AuthCubit for global auth state
        BlocProvider<SessionCubit>(
          create: (context) => di.sl<SessionCubit>()..checkAuthStatus(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => di.sl<ThemeCubit>(),
        ),
        BlocProvider<DashboardCubit>(
          create: (context) => di.sl<DashboardCubit>(),
        ),
        BlocProvider<ProductTourCubit>(
          create: (context) => di.sl<ProductTourCubit>(),
        ),
        BlocProvider<CurrencyCubit>(
          create: (context) => di.sl<CurrencyCubit>(),
        ),
      ],
      child: BlocListener<SessionCubit, SessionState>(
        listener: (context, state) {
          if (state is Authenticated && state.user.currency != null) {
            context
                .read<CurrencyCubit>()
                .setCurrencyByCode(state.user.currency!);
          }
        },
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            final themeMode = themeState is ThemeLoaded
                ? themeState.themeMode
                : ThemeMode.system;

            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'Dolfin AI',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: themeMode,
              builder: (context, child) =>
                  AppLockWrapper(child: child ?? const SizedBox()),
              home: const SplashPage(),
              routes: {
                '/onboarding': (context) => const OnboardingPage(),
                '/interactive-onboarding': (context) =>
                    const InteractiveOnboardingPage(),
                '/login': (context) => BlocProvider<LoginCubit>(
                      create: (context) => di.sl<LoginCubit>(),
                      child: const LoginPage(),
                    ),
                '/signup': (context) => BlocProvider<SignupCubit>(
                      create: (context) => di.sl<SignupCubit>(),
                      child: const SignUpPage(),
                    ),
                '/verification-success': (context) =>
                    const VerificationSuccessPage(),
                '/loading': (context) => const LoadingPage(),
                '/home': (context) => const HomePage(),
                '/forgot-password': (context) => BlocProvider<PasswordCubit>(
                      create: (context) => di.sl<PasswordCubit>(),
                      child: const ForgotPasswordPage(),
                    ),
                '/change-password': (context) => BlocProvider<PasswordCubit>(
                      create: (context) => di.sl<PasswordCubit>(),
                      child: const ChangePasswordPage(),
                    ),
                '/profile': (context) => const ProfilePage(),
                '/subscription-plans': (context) =>
                    const SubscriptionPlansPage(),
                '/manage-subscription': (context) =>
                    const ManageSubscriptionPage(),
                '/transactions': (context) => const TransactionsPage(),
                '/update-profile': (context) => const UpdateProfilePage(),
              },
              onGenerateRoute: (settings) {
                if (settings.name == '/email-verification') {
                  final email =
                      settings.arguments as String? ?? 'user@example.com';
                  return MaterialPageRoute(
                    builder: (context) => BlocProvider<SignupCubit>(
                      create: (context) => di.sl<SignupCubit>(),
                      child: EmailVerificationPage(email: email),
                    ),
                  );
                }
                if (settings.name == '/reset-password') {
                  final token = settings.arguments as String? ?? '';
                  return MaterialPageRoute(
                    builder: (context) => BlocProvider<PasswordCubit>(
                      create: (context) => di.sl<PasswordCubit>(),
                      child: ResetPasswordPage(token: token),
                    ),
                  );
                }
                return null;
              },
            );
          },
        ),
      ),
    );
  }
}
