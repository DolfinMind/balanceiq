import 'package:dartz/dartz.dart';
import 'package:dolfin_core/error/failures.dart';
import 'package:feature_auth/data/models/auth_request_models.dart';
import 'package:feature_auth/domain/usecases/get_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  late GetProfile getProfile;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    getProfile = GetProfile(mockAuthRepository);
  });

  group('GetProfile', () {
    const testToken = 'test_jwt_token';
    final testUserInfo = UserInfo(
      id: '1',
      email: 'test@example.com',
      fullName: 'Test User',
      avatarUrl: 'https://example.com/photo.jpg',
      currency: 'USD',
      isEmailVerified: true,
    );

    test('should return UserInfo when getProfile is successful', () async {
      // Arrange
      when(() => mockAuthRepository.getProfile(any()))
          .thenAnswer((_) async => Right(testUserInfo));

      // Act
      final result = await getProfile(testToken);

      // Assert
      expect(result, Right(testUserInfo));
      verify(() => mockAuthRepository.getProfile(testToken)).called(1);
    });

    test('should return UserInfo without photo when photoUrl is null',
        () async {
      // Arrange
      final userInfoNoPhoto = UserInfo(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        fullName: 'Test User',
        photoUrl: null,
        roles: ['USER'],
        isEmailVerified: true,
      );

      when(() => mockAuthRepository.getProfile(any()))
          .thenAnswer((_) async => Right(userInfoNoPhoto));

      // Act
      final result = await getProfile(testToken);

      // Assert
      expect(result, Right(userInfoNoPhoto));
    });

    test('should return AuthFailure when token is invalid', () async {
      // Arrange
      when(() => mockAuthRepository.getProfile(any()))
          .thenAnswer((_) async => const Left(AuthFailure('Invalid token')));

      // Act
      final result = await getProfile('invalid_token');

      // Assert
      expect(result, const Left(AuthFailure('Invalid token')));
    });

    test('should return AuthFailure when token is expired', () async {
      // Arrange
      when(() => mockAuthRepository.getProfile(any()))
          .thenAnswer((_) async => const Left(AuthFailure('Token expired')));

      // Act
      final result = await getProfile(testToken);

      // Assert
      expect(result, const Left(AuthFailure('Token expired')));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      when(() => mockAuthRepository.getProfile(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Server error')));

      // Act
      final result = await getProfile(testToken);

      // Assert
      expect(result, const Left(ServerFailure('Server error')));
    });

    test('should return NetworkFailure when no internet', () async {
      // Arrange
      when(() => mockAuthRepository.getProfile(any())).thenAnswer(
          (_) async => const Left(NetworkFailure('No internet connection')));

      // Act
      final result = await getProfile(testToken);

      // Assert
      expect(result, const Left(NetworkFailure('No internet connection')));
    });
  });
}
