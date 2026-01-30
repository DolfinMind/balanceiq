import 'package:dartz/dartz.dart';
import 'package:dolfin_core/error/failures.dart';
import '../../data/models/auth_request_models.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileParams {
  final String? fullName;
  final String? avatarUrl;
  final String? email;
  final String? currency;

  const UpdateProfileParams({
    this.fullName,
    this.avatarUrl,
    this.email,
    this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'fullName': fullName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (email != null) 'email': email,
      if (currency != null) 'currency': currency,
    };
  }
}

class UpdateProfile {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  Future<Either<Failure, UserInfo>> call({
    String? fullName,
    String? email,
    String? currency,
  }) {
    return repository.updateProfile(
      fullName: fullName,
      email: email,
      currency: currency,
    );
  }
}
