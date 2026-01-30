import 'package:feature_auth/data/models/auth_request_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginResponse', () {
    test('fromJson should parse successful response with new structure', () {
      // Arrange
      final json = {
        'success': true,
        'message': 'Login successful',
        'data': {
          'accessToken': 'jwt_token',
          'refreshToken': 'refresh_token',
          'appCode': 'ECHO_MEMORY',
          'isNewUser': true,
          'user': {
            'id': '1',
            'username': 'testuser',
            'email': 'test@example.com',
            'fullName': 'Test User',
            'avatarUrl': 'https://example.com/photo.jpg',
            'authProvider': 'google',
            'currency': 'USD',
            'isEmailVerified': true,
          }
        },
      };

      // Act
      final result = LoginResponse.fromJson(json);

      // Assert
      expect(result.success, true);
      expect(result.message, 'Login successful');
      expect(result.data, isNotNull);
      expect(result.data!.accessToken, 'jwt_token');
      expect(result.data!.refreshToken, 'refresh_token');
      expect(result.data!.appCode, 'ECHO_MEMORY');
      expect(result.data!.isNewUser, true);
      expect(result.data!.user.id, '1');
      expect(result.data!.user.email, 'test@example.com');
    });

    test('fromJson should handle null data', () {
      // Arrange
      final json = {
        'success': false,
        'message': 'Login failed',
      };

      // Act
      final result = LoginResponse.fromJson(json);

      // Assert
      expect(result.success, false);
      expect(result.message, 'Login failed');
      expect(result.data, isNull);
    });
  });

  group('UserInfo', () {
    test('fromJson should parse user info correctly', () {
      // Arrange
      final json = {
        'id': '1',
        'username': 'testuser',
        'email': 'test@example.com',
        'fullName': 'Test User',
        'avatarUrl': 'https://example.com/photo.jpg',
        'authProvider': 'google',
        'currency': 'USD',
        'isEmailVerified': true,
      };

      // Act
      final result = UserInfo.fromJson(json);

      // Assert
      expect(result.id, '1');
      expect(result.email, 'test@example.com');
      expect(result.fullName, 'Test User');
      expect(result.avatarUrl, 'https://example.com/photo.jpg');
      expect(result.authProvider, 'google');
      expect(result.currency, 'USD');
      expect(result.isEmailVerified, true);
    });

    test('toJson should return correct map', () {
      // Arrange
      final userInfo = UserInfo(
        id: '1',
        email: 'test@example.com',
        fullName: 'Test User',
        avatarUrl: 'https://example.com/photo.jpg',
        authProvider: 'google',
        currency: 'USD',
        isEmailVerified: true,
      );

      // Act
      final result = userInfo.toJson();

      // Assert
      expect(result['id'], '1');
      expect(result['email'], 'test@example.com');
      expect(result['fullName'], 'Test User');
      expect(result['avatarUrl'], 'https://example.com/photo.jpg');
      expect(result['authProvider'], 'google');
      expect(result['currency'], 'USD');
      expect(result['isEmailVerified'], true);
    });
  });

  group('RefreshTokenRequest', () {
    test('toJson should return correct map', () {
      // Arrange
      final request = RefreshTokenRequest(refreshToken: 'refresh_token_123');

      // Act
      final result = request.toJson();

      // Assert
      expect(result['refreshToken'], 'refresh_token_123');
    });
  });

  group('RefreshTokenResponse', () {
    test('fromJson should parse successful response', () {
      // Arrange
      final json = {
        'success': true,
        'message': 'Token refreshed',
        'data': {
          'accessToken': 'new_jwt_token',
          'refreshToken': 'new_refresh_token',
        },
      };

      // Act
      final result = RefreshTokenResponse.fromJson(json);

      // Assert
      expect(result.success, true);
      expect(result.data, isNotNull);
      expect(result.data!.accessToken, 'new_jwt_token');
      expect(result.data!.refreshToken, 'new_refresh_token');
    });
  });

  group('UpdateProfileRequest', () {
    test('toJson should return correct map', () {
      final request =
          UpdateProfileRequest(fullName: 'New Name', currency: 'EUR');
      final json = request.toJson();
      expect(json['fullName'], 'New Name');
      expect(json['currency'], 'EUR');
    });
  });

  group('UpdateProfileResponse', () {
    test('fromJson should parse success response', () {
      final json = {
        'success': true,
        'message': 'Updated',
        'data': {
          'id': '1',
          'email': 'test@example.com',
          'fullName': 'New Name',
          'currency': 'EUR'
        }
      };
      final result = UpdateProfileResponse.fromJson(json);
      expect(result.success, true);
      expect(result.data!.fullName, 'New Name');
    });
  });
}
