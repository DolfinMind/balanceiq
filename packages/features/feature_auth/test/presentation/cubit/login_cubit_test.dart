import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:dolfin_core/error/failures.dart';
import 'package:feature_auth/domain/entities/user.dart';
import 'package:feature_auth/presentation/cubit/login/login_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';
import 'package:dolfin_core/storage/secure_storage_service.dart';
import 'package:dolfin_core/currency/currency_cubit.dart';

class FakeUser extends Fake implements User {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUser());
  });

  late LoginCubit cubit;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockGetProfile mockGetProfile;
  late MockSaveUser mockSaveUser;
  late MockCurrencyCubit mockCurrencyCubit;
  late MockSecureStorageService mockSecureStorageService;
  late MockAnalyticsService mockAnalyticsService;

  setUp(() {
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockGetProfile = MockGetProfile();
    mockSaveUser = MockSaveUser();
    mockCurrencyCubit = MockCurrencyCubit();
    mockSecureStorageService = MockSecureStorageService();
    mockAnalyticsService = MockAnalyticsService();

    final currencyState =
        const CurrencyState(currencyCode: 'USD', currencySymbol: '\$');
    when(() => mockCurrencyCubit.state).thenReturn(currencyState);
    when(() => mockCurrencyCubit.stream)
        .thenAnswer((_) => Stream.value(currencyState));

    when(() => mockAnalyticsService.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        )).thenAnswer((_) async {});

    when(() => mockAnalyticsService.setUserId(any())).thenAnswer((_) async {});

    cubit = LoginCubit(
      signInWithGoogle: mockSignInWithGoogle,
      getProfile: mockGetProfile,
      saveUser: mockSaveUser,
      currencyCubit: mockCurrencyCubit,
      secureStorage: mockSecureStorageService,
      analyticsService: mockAnalyticsService,
    );
  });

  blocTest<LoginCubit, LoginState>(
    'emits [LoginLoading, LoginError] when Google sign in fails',
    build: () {
      when(() => mockSignInWithGoogle()).thenAnswer(
        (_) async => const Left(AuthFailure('Google sign in cancelled')),
      );
      return cubit;
    },
    act: (cubit) => cubit.signInGoogle(),
    expect: () => [
      isA<LoginLoading>(),
      isA<LoginError>()
          .having((s) => s.message, 'message', 'Google sign in cancelled'),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'emits [LoginLoading, LoginError] on network error during Google sign in',
    build: () {
      when(() => mockSignInWithGoogle()).thenAnswer(
        (_) async => const Left(NetworkFailure('Network unavailable')),
      );
      return cubit;
    },
    act: (cubit) => cubit.signInGoogle(),
    expect: () => [
      isA<LoginLoading>(),
      isA<LoginError>()
          .having((s) => s.message, 'message', 'Network unavailable'),
    ],
  );

  tearDown(() {});
}
