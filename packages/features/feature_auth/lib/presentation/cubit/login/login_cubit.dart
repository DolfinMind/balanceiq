import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/sign_in_with_google.dart';
import '../../../domain/usecases/get_profile.dart';
import '../../../domain/usecases/save_user.dart';
import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:dolfin_core/storage/secure_storage_service.dart';
import 'package:dolfin_core/analytics/analytics_service.dart';

// States
abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final User user;
  const LoginSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class LoginCubit extends Cubit<LoginState> {
  final SignInWithGoogle signInWithGoogle;
  final GetProfile getProfile;
  final SaveUser saveUser;
  final CurrencyCubit currencyCubit;
  final SecureStorageService secureStorage;
  final AnalyticsService analyticsService;

  LoginCubit({
    required this.signInWithGoogle,
    required this.getProfile,
    required this.saveUser,
    required this.currencyCubit,
    required this.secureStorage,
    required this.analyticsService,
  }) : super(LoginInitial());

  Future<void> signInGoogle() async {
    emit(LoginLoading());
    final result = await signInWithGoogle();

    await result.fold(
      (failure) async => emit(LoginError(failure.message)),
      (googleUser) async {
        // Log login event
        await analyticsService.logEvent(
          name: 'login',
          parameters: {'method': 'google'},
        );
        await analyticsService.setUserId(googleUser.id);

        // Fetch full profile (though Google Sign In might return enough info,
        // we might want additional backend data like currency or roles)
        final token = await secureStorage.getToken();
        if (token != null) {
          final profileResult = await getProfile(token);

          await profileResult.fold((failure) {
            // If profile fetch fails, still proceed with googleUser
            // but maybe log the error
            emit(LoginSuccess(googleUser));
          }, (userInfo) async {
            // Sync currency
            if (userInfo.currency != null && userInfo.currency!.isNotEmpty) {
              await currencyCubit.setCurrencyByCode(userInfo.currency!);
            }

            final fullUser = User(
              id: userInfo.id.toString(),
              email: userInfo.email,
              name: userInfo.fullName,
              photoUrl: userInfo.avatarUrl,
              currency: userInfo.currency,
              authProvider: googleUser.authProvider,
              createdAt: googleUser.createdAt,
              isEmailVerified: userInfo.isEmailVerified,
            );

            await saveUser(fullUser);
            emit(LoginSuccess(fullUser));
          });
        } else {
          emit(LoginSuccess(googleUser));
        }
      },
    );
  }
}
