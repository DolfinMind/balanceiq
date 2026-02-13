import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dolfin_core/constants/api_endpoints.dart';
import 'package:dolfin_core/constants/app_constants.dart';
import 'package:get_it/get_it.dart';
import 'package:dolfin_core/error/app_exception.dart';
import 'package:dolfin_core/error/error_handler.dart';
import 'package:dolfin_core/storage/secure_storage_service.dart';
import '../models/auth_request_models.dart';

abstract class AuthRemoteDataSource {
  // OAuth Methods
  Future<LoginResponse> signInWithGoogle();
  Future<void> signOut();
  Future<RefreshTokenResponse> refreshToken(String refreshToken);

  // Profile Methods
  Future<UserInfo> getProfile(String token);
  Future<UpdateProfileResponse> updateProfile(UpdateProfileRequest request);
  Future<void> updateCurrency(String currency);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GoogleSignIn googleSignIn;
  final Dio dio;
  final SecureStorageService secureStorage;

  AuthRemoteDataSourceImpl({
    required this.googleSignIn,
    required this.dio,
    required this.secureStorage,
  });

  @override
  Future<LoginResponse> signInWithGoogle() async {
    GoogleSignInAccount? account;
    try {
      // 1. Trigger Google Sign-In Flow
      account = await googleSignIn.signIn();

      if (account == null) {
        throw const UnknownException('Google sign in was cancelled');
      }

      // 2. Get the idToken from Google authentication
      final GoogleSignInAuthentication googleAuth =
          await account.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        // Sign out so user can try with different account
        await googleSignIn.signOut();
        throw const AuthException('Failed to retrieve Google ID Token');
      }

      // 3. Send idToken to backend SSO endpoint
      final response = await dio.post(
        ApiEndpoints.googleOAuth,
        data: {
          'idToken': idToken,
          'appCode': 'FINANCE_GURU',
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: GetIt.instance<AppConstants>().apiTimeout,
          receiveTimeout: GetIt.instance<AppConstants>().apiTimeout,
        ),
      );

      if (response.statusCode == 200) {
        var loginResponse = LoginResponse.fromJson(response.data);

        // Inject photoUrl from Google account if missing from backend
        if (loginResponse.data != null && account.photoUrl != null) {
          final userData = loginResponse.data!.user;
          if (userData.avatarUrl == null || userData.avatarUrl!.isEmpty) {
            final updatedUser = UserInfo(
              id: userData.id,
              email: userData.email,
              fullName: userData.fullName,
              avatarUrl: account.photoUrl,
              authProvider: userData.authProvider,
              currency: userData.currency,
              isEmailVerified: userData.isEmailVerified,
            );

            final updatedData = LoginData(
              accessToken: loginResponse.data!.accessToken,
              refreshToken: loginResponse.data!.refreshToken,
              user: updatedUser,
              appCode: loginResponse.data!.appCode,
              isNewUser: loginResponse.data!.isNewUser,
            );

            loginResponse = LoginResponse(
              success: loginResponse.success,
              message: loginResponse.message,
              data: updatedData,
            );
          }
        }

        // Store the tokens in SecureStorage
        if (loginResponse.data != null) {
          await secureStorage.saveToken(loginResponse.data!.accessToken);
          await secureStorage
              .saveRefreshToken(loginResponse.data!.refreshToken);
          // Also save user ID if available, ensuring string compatibility
          await secureStorage.saveUserId(loginResponse.data!.user.id);
        }

        return loginResponse;
      } else {
        // Backend failed - sign out so user can try different account
        await googleSignIn.signOut();
        throw ServerException(
            'Backend authentication failed: ${response.statusCode}',
            statusCode: response.statusCode);
      }
    } catch (e) {
      if (account != null) {
        await googleSignIn.signOut();
      }
      throw ErrorHandler.handle(e, source: 'signInWithGoogle');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await googleSignIn.signOut();

      // Call Backend Logout API if exists
      // Assuming logout endpoint clears server session
      try {
        await dio.post(
          ApiEndpoints.logout,
          options: Options(
            headers: {'Content-Type': 'application/json'},
            sendTimeout: GetIt.instance<AppConstants>().apiTimeout,
            receiveTimeout: GetIt.instance<AppConstants>().apiTimeout,
          ),
        );
      } catch (_) {
        // Ignore backend logout errors during local sign out
      }

      // Clear all cached tokens
      await secureStorage.clearAllTokens();
    } catch (e) {
      throw ErrorHandler.handle(e, source: 'signOut');
    }
  }

  @override
  Future<RefreshTokenResponse> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: GetIt.instance<AppConstants>().apiTimeout,
          receiveTimeout: GetIt.instance<AppConstants>().apiTimeout,
        ),
      );

      final refreshResponse = RefreshTokenResponse.fromJson(response.data);
      if (refreshResponse.data != null) {
        await secureStorage.saveToken(refreshResponse.data!.accessToken);
        await secureStorage
            .saveRefreshToken(refreshResponse.data!.refreshToken);
      }
      return refreshResponse;
    } catch (e) {
      throw ErrorHandler.handle(e, source: 'refreshToken');
    }
  }

  @override
  Future<UserInfo> getProfile(String token) async {
    try {
      final response = await dio.get(
        ApiEndpoints.getProfile,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          sendTimeout: GetIt.instance<AppConstants>().apiTimeout,
          receiveTimeout: GetIt.instance<AppConstants>().apiTimeout,
        ),
      );

      // Handle wrapped response { success: true, data: { ... } }
      final json = response.data;
      if (json is Map<String, dynamic> && json.containsKey('data')) {
        return UserInfo.fromJson(json['data']);
      }

      return UserInfo.fromJson(response.data);
    } catch (e) {
      throw ErrorHandler.handle(e, source: 'getProfile');
    }
  }

  @override
  Future<void> updateCurrency(String currency) async {
    try {
      await dio.patch(
        ApiEndpoints.updateCurrency,
        data: {'currency': currency},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: GetIt.instance<AppConstants>().apiTimeout,
          receiveTimeout: GetIt.instance<AppConstants>().apiTimeout,
        ),
      );
    } catch (e) {
      throw ErrorHandler.handle(e, source: 'updateCurrency');
    }
  }

  @override
  Future<UpdateProfileResponse> updateProfile(
      UpdateProfileRequest request) async {
    try {
      final response = await dio.put(
        ApiEndpoints.updateProfile,
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: GetIt.instance<AppConstants>().apiTimeout,
          receiveTimeout: GetIt.instance<AppConstants>().apiTimeout,
        ),
      );

      return UpdateProfileResponse.fromJson(response.data);
    } catch (e) {
      throw ErrorHandler.handle(e, source: 'updateProfile');
    }
  }
}
