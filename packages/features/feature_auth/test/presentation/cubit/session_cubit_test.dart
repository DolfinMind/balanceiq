import 'package:bloc_test/bloc_test.dart';
import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:dolfin_core/error/failures.dart';
import 'package:dolfin_core/storage/secure_storage_service.dart';
import 'package:feature_auth/data/models/auth_request_models.dart';
import 'package:feature_auth/domain/entities/user.dart';
import 'package:feature_auth/domain/usecases/update_currency.dart';
import 'package:feature_auth/presentation/cubit/session/session_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../mocks.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockCacheManager extends Mock implements BaseCacheManager {}

class MockUpdateCurrency extends Mock implements UpdateCurrency {}

class FakeUser extends Fake implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeUser());
  });

  late SessionCubit cubit;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockSignOut mockSignOut;
  late MockGetProfile mockGetProfile;
  late MockUpdateCurrency mockUpdateCurrency;
  late MockUpdateProfile mockUpdateProfile;
  late MockSaveUser mockSaveUser;
  late MockCurrencyCubit mockCurrencyCubit;
  late MockSecureStorageService mockSecureStorageService;
  late MockCacheManager mockCacheManager;

  setUp(() {
    mockGetCurrentUser = MockGetCurrentUser();
    mockSignOut = MockSignOut();
    mockGetProfile = MockGetProfile();
    mockUpdateCurrency = MockUpdateCurrency();
    mockUpdateProfile = MockUpdateProfile();
    mockSaveUser = MockSaveUser();
    mockCurrencyCubit = MockCurrencyCubit();
    mockSecureStorageService = MockSecureStorageService();
    mockCacheManager = MockCacheManager();
    when(() => mockCacheManager.emptyCache()).thenAnswer((_) async {});
    when(() => mockSecureStorageService.deleteAll()).thenAnswer((_) async {});

    final currencyState =
        const CurrencyState(currencyCode: 'USD', currencySymbol: '\$');
    when(() => mockCurrencyCubit.state).thenReturn(currencyState);
    when(() => mockCurrencyCubit.stream)
        .thenAnswer((_) => Stream.value(currencyState));
    when(() => mockCurrencyCubit.reset()).thenAnswer((_) async {});

    cubit = SessionCubit(
      getCurrentUser: mockGetCurrentUser,
      signOutUseCase: mockSignOut,
      getProfile: mockGetProfile,
      updateCurrencyUseCase: mockUpdateCurrency,
      updateProfileUseCase: mockUpdateProfile,
      saveUser: mockSaveUser,
      currencyCubit: mockCurrencyCubit,
      secureStorage: mockSecureStorageService,
      cacheManager: mockCacheManager,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('SessionCubit', () {
    final testUser = User(
      id: '1',
      email: 'test@example.com',
      name: 'Test User',
      photoUrl: null,
      authProvider: 'email',
      createdAt: DateTime.now(),
      isEmailVerified: true,
    );

    final testUserInfo = UserInfo(
      id: '1',
      email: 'test@example.com',
      fullName: 'Test User',
      isEmailVerified: true,
    );

    test('initial state is SessionInitial', () {
      expect(cubit.state, isA<SessionInitial>());
    });

    group('checkAuthStatus', () {
      blocTest<SessionCubit, SessionState>(
        'emits [SessionLoading, Authenticated] when user is logged in',
        build: () {
          when(() => mockGetCurrentUser())
              .thenAnswer((_) async => Right(testUser));
          when(() => mockSecureStorageService.getToken())
              .thenAnswer((_) async => 'valid_token');
          when(() => mockGetProfile(any()))
              .thenAnswer((_) async => Right(testUserInfo));
          when(() => mockSaveUser(any()))
              .thenAnswer((_) async => const Right(null));
          return cubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          isA<SessionLoading>(),
          isA<Authenticated>().having((s) => s.user, 'user', testUser),
          // After refreshUserProfile
          isA<SessionLoading>(),
          isA<Authenticated>(),
        ],
        verify: (_) {
          verify(() => mockGetCurrentUser()).called(1);
        },
      );

      blocTest<SessionCubit, SessionState>(
        'emits [SessionLoading, Unauthenticated] when user is not logged in',
        build: () {
          when(() => mockGetCurrentUser())
              .thenAnswer((_) async => const Right(null));
          return cubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          isA<SessionLoading>(),
          isA<Unauthenticated>(),
        ],
      );

      blocTest<SessionCubit, SessionState>(
        'emits [SessionLoading, Unauthenticated] when getCurrentUser fails',
        build: () {
          when(() => mockGetCurrentUser()).thenAnswer(
            (_) async => const Left(CacheFailure('No cached user')),
          );
          return cubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          isA<SessionLoading>(),
          isA<Unauthenticated>(),
        ],
      );
    });

    group('logout', () {
      blocTest<SessionCubit, SessionState>(
        'emits [SessionLoading, Unauthenticated] when logout succeeds',
        build: () {
          when(() => mockSignOut()).thenAnswer((_) async => const Right(null));
          return cubit;
        },
        act: (cubit) => cubit.logout(),
        expect: () => [
          isA<SessionLoading>(),
          isA<Unauthenticated>(),
        ],
        verify: (_) {
          verify(() => mockSignOut()).called(1);
        },
      );

      blocTest<SessionCubit, SessionState>(
        'emits [SessionLoading, SessionError] when logout fails',
        build: () {
          when(() => mockSignOut()).thenAnswer(
            (_) async => const Left(ServerFailure('Logout failed')),
          );
          return cubit;
        },
        act: (cubit) => cubit.logout(),
        expect: () => [
          isA<SessionLoading>(),
          isA<SessionError>()
              .having((s) => s.message, 'message', 'Logout failed'),
        ],
      );
    });

    group('refreshUserProfile', () {
      blocTest<SessionCubit, SessionState>(
        'emits [Authenticated] with updated user when profile refresh succeeds',
        seed: () => Authenticated(testUser),
        build: () {
          when(() => mockSecureStorageService.getToken())
              .thenAnswer((_) async => 'valid_token');
          when(() => mockGetProfile(any()))
              .thenAnswer((_) async => Right(testUserInfo));
          when(() => mockSaveUser(any()))
              .thenAnswer((_) async => const Right(null));
          return cubit;
        },
        act: (cubit) => cubit.refreshUserProfile(),
        expect: () => [
          isA<SessionLoading>(),
          isA<Authenticated>()
              .having((s) => s.user.name, 'name', 'Test User')
              .having((s) => s.user.email, 'email', 'test@example.com'),
        ],
        verify: (_) {
          verify(() => mockGetProfile('valid_token')).called(1);
          verify(() => mockSaveUser(any())).called(1);
        },
      );

      blocTest<SessionCubit, SessionState>(
        'emits [Authenticated] with current user when no token available',
        seed: () => Authenticated(testUser),
        build: () {
          when(() => mockSecureStorageService.getToken())
              .thenAnswer((_) async => null);
          return cubit;
        },
        act: (cubit) => cubit.refreshUserProfile(),
        expect: () => [
          isA<SessionLoading>(),
          isA<Authenticated>().having((s) => s.user, 'user', testUser),
        ],
      );

      blocTest<SessionCubit, SessionState>(
        'emits [Authenticated] with current user when profile refresh fails',
        seed: () => Authenticated(testUser),
        build: () {
          when(() => mockSecureStorageService.getToken())
              .thenAnswer((_) async => 'valid_token');
          when(() => mockGetProfile(any())).thenAnswer(
            (_) async => const Left(ServerFailure('Profile fetch failed')),
          );
          return cubit;
        },
        act: (cubit) => cubit.refreshUserProfile(),
        expect: () => [
          isA<SessionLoading>(),
          isA<Authenticated>().having((s) => s.user, 'user', testUser),
        ],
      );

      blocTest<SessionCubit, SessionState>(
        'does nothing when not authenticated',
        build: () {
          when(() => mockSecureStorageService.getToken())
              .thenAnswer((_) async => null);
          return cubit;
        },
        act: (cubit) => cubit.refreshUserProfile(),
        expect: () => [],
      );
    });

    group('updateUser', () {
      final updatedUser = User(
        id: '1',
        email: 'updated@example.com',
        name: 'Updated User',
        photoUrl: 'https://example.com/photo.jpg',
        authProvider: 'email',
        createdAt: DateTime.now(),
        isEmailVerified: true,
      );

      blocTest<SessionCubit, SessionState>(
        'emits [Authenticated] with new user',
        build: () => cubit,
        act: (cubit) => cubit.updateUser(updatedUser),
        expect: () => [
          isA<Authenticated>().having((s) => s.user, 'user', updatedUser),
        ],
      );
    });

    group('updateUserCurrency', () {
      const tCurrency = 'EUR';

      blocTest<SessionCubit, SessionState>(
        'calls updateCurrencyUseCase',
        build: () {
          when(() => mockUpdateCurrency(any()))
              .thenAnswer((_) async => const Right(null));
          return cubit;
        },
        act: (cubit) => cubit.updateUserCurrency(tCurrency),
        expect: () => [],
        verify: (_) {
          verify(() => mockUpdateCurrency(tCurrency)).called(1);
        },
      );
    });
  });
}
