import 'package:dartz/dartz.dart';
import 'package:dolfin_core/error/failures.dart';
import 'package:feature_auth/domain/entities/user.dart';
import 'package:feature_auth/domain/usecases/sign_in_with_google.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  late SignInWithGoogle signInWithGoogle;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signInWithGoogle = SignInWithGoogle(mockAuthRepository);
  });

  group('SignInWithGoogle', () {
    final tUser = User(
      id: '1',
      email: 'test@example.com',
      name: 'Test User',
      photoUrl: 'https://example.com/photo.jpg',
      authProvider: 'google',
      createdAt: DateTime(
          2023), // Note: Exact equality might fail on DateTime if not careful, but we are checking fields now.
      isEmailVerified: true,
    );

    test('should return User when Google sign in is successful', () async {
      // Arrange
      when(() => mockAuthRepository.signInWithGoogle())
          .thenAnswer((_) async => Right((user: tUser, isNewUser: false)));

      // Act
      final result = await signInWithGoogle();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('test failed'),
        (r) {
          expect(r.user.email, tUser.email);
          expect(r.user.name, tUser.name);
          expect(r.user.authProvider, tUser.authProvider);
        },
      );
      verify(() => mockAuthRepository.signInWithGoogle()).called(1);
    });

    test('should return AuthFailure when Google sign in is cancelled',
        () async {
      // Arrange
      when(() => mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => const Left(AuthFailure('Sign in cancelled by user')));

      // Act
      final result = await signInWithGoogle();

      // Assert
      expect(result, const Left(AuthFailure('Sign in cancelled by user')));
    });

    test('should return AuthFailure when Google account not found', () async {
      // Arrange
      when(() => mockAuthRepository.signInWithGoogle())
          .thenAnswer((_) async => const Left(AuthFailure('No account found')));

      // Act
      final result = await signInWithGoogle();

      // Assert
      expect(result, const Left(AuthFailure('No account found')));
    });

    test('should return ServerFailure when server validation fails', () async {
      // Arrange
      when(() => mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => const Left(ServerFailure('Server validation failed')));

      // Act
      final result = await signInWithGoogle();

      // Assert
      expect(result, const Left(ServerFailure('Server validation failed')));
    });

    test('should return NetworkFailure when no internet', () async {
      // Arrange
      when(() => mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => const Left(NetworkFailure('No internet connection')));

      // Act
      final result = await signInWithGoogle();

      // Assert
      expect(result, const Left(NetworkFailure('No internet connection')));
    });

    test('should return AuthFailure when Google Play Services not available',
        () async {
      // Arrange
      when(() => mockAuthRepository.signInWithGoogle()).thenAnswer((_) async =>
          const Left(AuthFailure('Google Play Services not available')));

      // Act
      final result = await signInWithGoogle();

      // Assert
      expect(result,
          const Left(AuthFailure('Google Play Services not available')));
    });
  });
}
