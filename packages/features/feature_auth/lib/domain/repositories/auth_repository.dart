import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import 'package:dolfin_core/error/failures.dart';
import '../../data/models/auth_request_models.dart';

abstract class AuthRepository {
  // OAuth Methods
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, bool>> isSignedIn();

  Future<Either<Failure, UserInfo>> getProfile(String token);

  Future<Either<Failure, void>> updateCurrency(String currency);
  Future<Either<Failure, void>> saveUser(User user);

  // Profile Update
  Future<Either<Failure, UserInfo>> updateProfile({
    String? fullName,
    String? email,
    String? currency,
  });
}
