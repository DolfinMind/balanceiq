import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:dolfin_core/storage/secure_storage_service.dart';
import 'package:dolfin_core/analytics/analytics_service.dart';

import 'package:feature_auth/domain/auth_config.dart';
import 'package:feature_auth/data/datasources/auth_remote_datasource.dart';
import 'package:feature_auth/data/datasources/auth_mock_datasource.dart';
import 'package:feature_auth/data/datasources/auth_local_datasource.dart';
import 'package:feature_auth/data/repositories/auth_repository_impl.dart';
import 'package:feature_auth/domain/repositories/auth_repository.dart';
import 'package:feature_auth/domain/usecases/sign_in_with_google.dart';
import 'package:feature_auth/domain/usecases/get_current_user.dart';
import 'package:feature_auth/domain/usecases/sign_out.dart';
import 'package:feature_auth/domain/usecases/get_profile.dart';
import 'package:feature_auth/domain/usecases/update_currency.dart';
import 'package:feature_auth/domain/usecases/update_profile.dart';
import 'package:feature_auth/domain/usecases/save_user.dart';

import 'package:feature_auth/presentation/cubit/login/login_cubit.dart';
import 'package:feature_auth/presentation/cubit/session/session_cubit.dart';
import 'package:feature_auth/presentation/cubit/interactive_onboarding/interactive_onboarding_cubit.dart';

// Re-export common types for convenience
export 'package:feature_auth/domain/auth_config.dart';
export 'package:feature_auth/presentation/cubit/session/session_cubit.dart';
export 'package:feature_auth/presentation/cubit/login/login_cubit.dart';
export 'package:feature_auth/presentation/pages/login_page.dart';
export 'package:feature_auth/presentation/pages/splash_page.dart';
export 'package:feature_auth/presentation/pages/profile_page.dart';
export 'package:feature_auth/presentation/pages/onboarding_page.dart';
export 'package:feature_auth/presentation/pages/webview_page.dart';

/// Configuration for initializing the Auth feature.
///
/// All [required] parameters must be provided by the host app.
/// Optional parameters have sensible defaults.
///
/// Example:
/// ```dart
/// await initAuthFeature(sl, AuthFeatureConfig(
///   authConfig: MyAuthConfig(),
///   secureStorage: sl(),
///   sharedPreferences: sl(),
///   dio: sl(),
///   googleSignIn: sl(),
///   useMockDataSource: true, // For testing
/// ));
/// ```
class AuthFeatureConfig {
  /// App-specific auth configuration (navigation callbacks, etc.)
  final AuthConfig authConfig;

  /// Secure storage for tokens and sensitive data
  final SecureStorageService secureStorage;

  /// Shared preferences for user preferences
  final SharedPreferences sharedPreferences;

  /// HTTP client for API calls
  final Dio dio;

  /// Google Sign-In instance for OAuth
  final GoogleSignIn googleSignIn;

  /// UUID generator (required for mock data source)
  /// If null, a default Uuid() will be used
  final Uuid? uuid;

  /// Use mock data source instead of real API (for testing)
  /// Default: false
  final bool useMockDataSource;

  /// Analytics service for tracking events
  final AnalyticsService analyticsService;

  const AuthFeatureConfig({
    required this.authConfig,
    required this.secureStorage,
    required this.sharedPreferences,
    required this.dio,
    required this.googleSignIn,
    this.uuid,
    this.useMockDataSource = false,
    required this.analyticsService,
  });
}

/// Initialize the Auth feature with explicit configuration.
///
/// This registers all auth-related dependencies in GetIt.
/// The caller must ensure all required dependencies are available.
Future<void> initAuthFeature(GetIt sl, AuthFeatureConfig config) async {
  // Config
  sl.registerSingleton<AuthConfig>(config.authConfig);

  // Data Sources
  if (config.useMockDataSource) {
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthMockDataSource(
        sharedPreferences: config.sharedPreferences,
        uuid: config.uuid ?? const Uuid(),
      ),
    );
  } else {
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        googleSignIn: config.googleSignIn,
        dio: config.dio,
        secureStorage: config.secureStorage,
      ),
    );
  }

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      config.sharedPreferences,
      config.secureStorage,
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));

  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateCurrency(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => SaveUser(sl()));

  // Cubits
  sl.registerFactory(() => LoginCubit(
        signInWithGoogle: sl(),
        getProfile: sl(),
        saveUser: sl(),
        currencyCubit: sl(),
        secureStorage: config.secureStorage,
        analyticsService: config.analyticsService,
      ));

  sl.registerFactory(() => SessionCubit(
        getCurrentUser: sl(),
        signOutUseCase: sl(),
        getProfile: sl(),
        updateCurrencyUseCase: sl(),
        updateProfileUseCase: sl(),
        saveUser: sl(),
        secureStorage: config.secureStorage,
        currencyCubit: sl(),
      ));

  sl.registerFactory(() => InteractiveOnboardingCubit());
}
