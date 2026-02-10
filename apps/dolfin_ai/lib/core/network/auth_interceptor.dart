import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:feature_auth/data/models/auth_request_models.dart';
import "package:dolfin_core/constants/api_endpoints.dart";
import "package:dolfin_core/constants/app_constants.dart";
import '../navigation/navigator_service.dart';
import "package:dolfin_core/storage/secure_storage_service.dart";
import "package:dolfin_core/utils/app_logger.dart";

class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService secureStorage;
  final Dio dio; // This should be the main Dio instance to retry the request

  // Flag to prevent infinite refresh loops
  bool _isRefreshing = false;

  AuthInterceptor({
    required this.secureStorage,
    required this.dio,
  });

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Add the access token to the header if available
    final token = await secureStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    if (kDebugMode) {
      AppLogger.debug('🔐 Request: ${options.method} ${options.path}',
          name: 'AuthInterceptor');
      AppLogger.debug('🔐 Has token: ${token != null}',
          name: 'AuthInterceptor');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      AppLogger.debug(
          '🔐 Error: ${err.response?.statusCode} for ${err.requestOptions.path}',
          name: 'AuthInterceptor');
    }

    // Only handle 401 errors and prevent infinite refresh loops
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      // Skip refresh for auth endpoints to prevent loops
      final requestPath = err.requestOptions.path;
      if (requestPath.contains('/auth/login') ||
          requestPath.contains('/auth/signup') ||
          requestPath.contains('/auth/refresh-token')) {
        AppLogger.debug('🔐 Skipping refresh for auth endpoint: $requestPath',
            name: 'AuthInterceptor');
        return handler.next(err);
      }

      // If we haven't tried to refresh yet, try now
      if (!_isRefreshing) {
        AppLogger.debug('🔐 Got 401, attempting token refresh...',
            name: 'AuthInterceptor');

        _isRefreshing = true;

        try {
          // Create a new Dio instance to avoid circular dependency and interceptor loops
          final tokenDio = Dio();
          tokenDio.options.headers['Content-Type'] = 'application/json';
          tokenDio.options.sendTimeout =
              GetIt.instance<AppConstants>().apiTimeout;
          tokenDio.options.receiveTimeout =
              GetIt.instance<AppConstants>().apiTimeout;

          AppLogger.debug(
              '🔐 Calling refresh token endpoint: ${ApiEndpoints.refreshToken}',
              name: 'AuthInterceptor');

          final refreshToken = await secureStorage.getRefreshToken();
          if (refreshToken == null) {
            AppLogger.debug('🔐 No refresh token found, cannot refresh.',
                name: 'AuthInterceptor');
            _isRefreshing = false;
            await _handleRefreshFailure();
            return handler.reject(err);
          }

          final response = await tokenDio.post(
            ApiEndpoints.refreshToken,
            data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
          );

          AppLogger.debug('🔐 Refresh response status: ${response.statusCode}',
              name: 'AuthInterceptor');

          if (response.statusCode == 200) {
            final refreshResponse =
                RefreshTokenResponse.fromJson(response.data);

            if (refreshResponse.success && refreshResponse.data != null) {
              AppLogger.debug('🔐 Token refresh successful! Updating tokens...',
                  name: 'AuthInterceptor');

              // Update the stored tokens
              if (refreshResponse.data != null) {
                await secureStorage
                    .saveToken(refreshResponse.data!.accessToken);
                await secureStorage
                    .saveRefreshToken(refreshResponse.data!.refreshToken);
              }

              _isRefreshing = false;

              // Retry the original request with the new token
              final opts = err.requestOptions;
              opts.headers['Authorization'] =
                  'Bearer ${refreshResponse.data!.accessToken}';

              AppLogger.debug(
                  '🔐 Retrying original request: ${opts.method} ${opts.path}',
                  name: 'AuthInterceptor');

              // Use a fresh Dio without the interceptor to avoid loops
              final retryDio = Dio();
              retryDio.options.baseUrl = dio.options.baseUrl;

              // Determine the URL to use - if path is already absolute, use it directly
              final requestUrl = opts.path.startsWith('http')
                  ? opts.path
                  : opts.uri.toString();

              final clonedRequest = await retryDio.request(
                requestUrl,
                options: Options(
                  method: opts.method,
                  headers: opts.headers,
                  contentType: opts.contentType,
                  responseType: opts.responseType,
                  followRedirects: opts.followRedirects,
                  validateStatus: opts.validateStatus,
                  receiveTimeout: opts.receiveTimeout,
                  sendTimeout: opts.sendTimeout,
                  extra: opts.extra,
                ),
                data: opts.data,
                queryParameters: opts.queryParameters,
              );

              return handler.resolve(clonedRequest);
            } else {
              AppLogger.warning(
                  '🔐 Refresh response unsuccessful: ${refreshResponse.message}',
                  name: 'AuthInterceptor');
              // Refresh response indicated failure
              _isRefreshing = false;
              await _handleRefreshFailure();
              return handler.reject(err);
            }
          }

          // If we get here, refresh was unsuccessful (non-200)
          AppLogger.warning(
              '🔐 Refresh returned non-200 status: ${response.statusCode}',
              name: 'AuthInterceptor');
          _isRefreshing = false;
          await _handleRefreshFailure();
          return handler.reject(err);
        } catch (e) {
          // Refresh failed, clear tokens and navigate to login
          _isRefreshing = false;
          AppLogger.error('🔐 Token refresh failed with exception: $e',
              name: 'AuthInterceptor');
          await _handleRefreshFailure();
          return handler.reject(err);
        }
      }
    }

    // For non-401 errors, pass through
    return handler.next(err);
  }

  /// Handles token refresh failure by clearing tokens and navigating to login
  Future<void> _handleRefreshFailure() async {
    // Clear stored tokens
    await secureStorage.clearAllTokens();
    await secureStorage.delete(key: 'user_id');

    AppLogger.debug(
        '🔐 Session expired. Tokens cleared. Navigating to login screen.',
        name: 'AuthInterceptor');

    // Navigate to login screen with error message
    navigateToLogin(
        errorMessage: 'Your session has expired. Please log in again.');
  }
}
