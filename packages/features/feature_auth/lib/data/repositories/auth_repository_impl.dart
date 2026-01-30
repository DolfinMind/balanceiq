import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:dolfin_core/error/app_exception.dart';
import 'package:dolfin_core/error/failures.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_request_models.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final loginResponse = await remoteDataSource.signInWithGoogle();

      if (loginResponse.success && loginResponse.data != null) {
        final data = loginResponse.data!;

        // 1. Save Token and Refresh Token
        if (data.accessToken.isNotEmpty) {
          await localDataSource.saveAuthToken(data.accessToken);
        }
        if (data.refreshToken.isNotEmpty) {
          await localDataSource.saveRefreshToken(data.refreshToken);
        }

        // 2. Create User Model
        final userModel = UserModel(
          id: data.user.id,
          email: data.user.email,
          name: data.user.fullName,
          photoUrl: data.user.avatarUrl,
          authProvider: data.user.authProvider ?? 'google',
          createdAt: DateTime.now(),
          isEmailVerified: data.user.isEmailVerified,
          currency: data.user
              .currency, // Add currency if available in UserInfo and UserModel
        );

        // 3. Save User Locally
        await localDataSource.saveUser(userModel);

        // 4. Return Domain User
        return Right(User(
          id: userModel.id,
          email: userModel.email,
          name: userModel.name,
          photoUrl: userModel.photoUrl,
          authProvider: userModel.authProvider,
          createdAt: userModel.createdAt,
          isEmailVerified: userModel.isEmailVerified,
          currency: userModel.currency,
        ));
      } else {
        return Left(AuthFailure(loginResponse.message));
      }
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(AuthFailure('Failed to sign in with Google: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearUser();
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(AuthFailure('Failed to sign out: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } catch (e) {
      return Left(CacheFailure('Failed to get current user: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isSignedIn() async {
    try {
      final isSignedIn = await localDataSource.isSignedIn();
      return Right(isSignedIn);
    } catch (e) {
      return Left(CacheFailure('Failed to check sign in status: $e'));
    }
  }

  @override
  Future<Either<Failure, UserInfo>> getProfile(String token) async {
    try {
      final profile = await remoteDataSource.getProfile(token);
      return Right(profile);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Failed to get profile: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCurrency(String currency) async {
    try {
      await remoteDataSource.updateCurrency(currency);
      // Update local user cache
      final currentUser = await localDataSource.getCachedUser();
      if (currentUser != null) {
        final updatedUser = UserModel(
          id: currentUser.id,
          email: currentUser.email,
          name: currentUser.name,
          photoUrl: currentUser.photoUrl,
          authProvider: currentUser.authProvider,
          createdAt: currentUser.createdAt,
          isEmailVerified: currentUser.isEmailVerified,
          currency: currency,
        );
        await localDataSource.saveUser(updatedUser);
      }
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Failed to update currency: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUser(User user) async {
    try {
      final userModel = UserModel(
        id: user.id,
        email: user.email,
        name: user.name,
        photoUrl: user.photoUrl,
        authProvider: user.authProvider,
        currency: user.currency,
        createdAt: user.createdAt,
        isEmailVerified: user.isEmailVerified,
      );
      await localDataSource.saveUser(userModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save user: $e'));
    }
  }

  @override
  Future<Either<Failure, UserInfo>> updateProfile({
    String? fullName,
    String? email,
    String? currency,
  }) async {
    try {
      final request = UpdateProfileRequest(
        fullName: fullName,
        email: email,
        currency: currency,
      );
      final response = await remoteDataSource.updateProfile(request);

      if (response.success && response.data != null) {
        // Update local user cache with new profile data
        final currentUser = await localDataSource.getCachedUser();
        if (currentUser != null) {
          final updatedUser = UserModel(
            id: currentUser.id,
            email: response.data!.email,
            name: response.data!.fullName,
            photoUrl: response.data!.avatarUrl,
            authProvider:
                response.data!.authProvider ?? currentUser.authProvider,
            currency: response.data!.currency,
            createdAt: currentUser.createdAt,
            isEmailVerified: response.data!.isEmailVerified,
          );
          await localDataSource.saveUser(updatedUser);
        }
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Failed to update profile: $e'));
    }
  }

  Failure _mapExceptionToFailure(AppException exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is AuthException) {
      return AuthFailure(exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    } else {
      return ServerFailure(exception.message);
    }
  }
}
