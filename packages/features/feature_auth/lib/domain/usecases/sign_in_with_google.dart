import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import 'package:dolfin_core/error/failures.dart';

class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<Either<Failure, ({User user, bool isNewUser})>> call() async {
    return await repository.signInWithGoogle();
  }
}
