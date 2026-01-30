import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:dolfin_core/utils/app_logger.dart';
import '../models/auth_request_models.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

/// Mock authentication data source that simulates backend API behavior
class AuthMockDataSource implements AuthRemoteDataSource {
  final SharedPreferences sharedPreferences;
  final Uuid uuid;

  // In-memory storage for mock users
  static final Map<String, _MockUser> _users = {};

  AuthMockDataSource({
    required this.sharedPreferences,
    required this.uuid,
  });

  /// Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(
      Duration(milliseconds: 300 + (DateTime.now().millisecond % 500)),
    );
  }

  @override
  Future<RefreshTokenResponse> refreshToken(String refreshToken) async {
    await _simulateDelay();

    // Validate refresh token
    if (refreshToken.isEmpty ||
        !refreshToken.startsWith('mock_refresh_token_')) {
      throw Exception('Invalid refresh token');
    }

    // Extract user ID from refresh token
    final userId = refreshToken.replaceFirst('mock_refresh_token_', '');

    final newToken = _generateMockToken(userId);
    final newRefreshToken = 'mock_refresh_token_$userId';

    // Store token in SharedPreferences
    await sharedPreferences.setString('auth_token', newToken);
    await sharedPreferences.setString('refresh_token', newRefreshToken);

    return RefreshTokenResponse(
      success: true,
      message: 'Token refreshed successfully',
      data: RefreshTokenData(
        accessToken: newToken,
        refreshToken: newRefreshToken,
      ),
    );
  }

  @override
  Future<UserInfo> getProfile(String token) async {
    await _simulateDelay();

    // Validate token
    if (token.isEmpty) {
      throw Exception('Unauthorized. Please login again.');
    }

    // Extract user ID from token
    final userId = _extractUserIdFromToken(token);

    // Return a mock profile
    return UserInfo(
      id: userId,
      fullName: 'Mock User',
      email: 'mock@example.com',
      avatarUrl: null,
      currency: 'USD',
      isEmailVerified: true,
    );
  }

  @override
  Future<LoginResponse> signInWithGoogle() async {
    await _simulateDelay();

    // Mock Google Sign-In
    final userId = uuid.v4();
    final email = 'mockgoogle@gmail.com';
    final name = 'Mock Google User';

    // Store user in mock database if needed
    _users[userId] = _MockUser(
      id: userId,
      username: 'mockgoogle',
      fullName: name,
      email: email,
      isEmailVerified: true,
    );

    final token = _generateMockToken(userId);

    return LoginResponse(
      success: true,
      message: 'Google Sign In Successful',
      data: LoginData(
        accessToken: token,
        refreshToken: 'mock_refresh_token_$userId',
        appCode: 'ECHO_MEMORY',
        isNewUser: false,
        user: UserInfo(
          id: userId,
          email: email,
          fullName: name,
          avatarUrl: 'https://i.pravatar.cc/150?u=google',
          authProvider: 'google',
          isEmailVerified: true,
          currency: 'USD',
        ),
      ),
    );
  }

  @override
  Future<void> signOut() async {
    await _simulateDelay();

    // Clear stored auth data
    await sharedPreferences.remove('auth_token');
    await sharedPreferences.remove('user_id');
  }

  /// Generate a mock JWT token
  String _generateMockToken(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'mock_token_${userId}_$timestamp';
  }

  /// Extract user ID from mock token
  String _extractUserIdFromToken(String token) {
    if (token.startsWith('mock_token_')) {
      final parts = token.split('_');
      if (parts.length >= 3) {
        return parts[2];
      }
    }
    // Return a default ID if parsing fails in mock
    return 'mock_user_id';
  }

  @override
  Future<void> updateCurrency(String currency) async {
    await _simulateDelay();
    AppLogger.debug('Currency updated to: $currency', name: 'MockAuth');
  }

  @override
  Future<UpdateProfileResponse> updateProfile(
      UpdateProfileRequest request) async {
    await _simulateDelay();

    AppLogger.debug('updateProfile called with: ${request.toJson()}',
        name: 'MockAuth');

    return UpdateProfileResponse(
      success: true,
      message: 'Profile updated successfully',
      data: UserInfo(
        id: '1',
        fullName: request.fullName ?? 'Test User',
        email: 'test@example.com',
        // Note: UpdateProfileRequest in new models has fullName and currency only?
        // Let's assume standard fields.
        currency: request.currency,
        isEmailVerified: true,
      ),
    );
  }
}

/// Internal class to represent a mock user in memory
class _MockUser {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final bool isEmailVerified;

  _MockUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    this.isEmailVerified = false,
  });
}
