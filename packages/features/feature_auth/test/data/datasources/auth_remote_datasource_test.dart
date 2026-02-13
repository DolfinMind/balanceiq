import 'package:dio/dio.dart';
import 'package:dolfin_core/constants/api_endpoints.dart';
import 'package:dolfin_core/constants/app_constants.dart';
import 'package:dolfin_core/error/app_exception.dart';
import 'package:dolfin_core/storage/secure_storage_service.dart';
import 'package:feature_auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockResponse extends Mock implements Response {}

class MockAppConstants extends Mock implements AppConstants {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockDio mockDio;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockSecureStorageService mockSecureStorage;
  late MockAppConstants mockAppConstants;

  setUp(() {
    mockDio = MockDio();
    mockGoogleSignIn = MockGoogleSignIn();
    mockSecureStorage = MockSecureStorageService();
    mockAppConstants = MockAppConstants();

    GetIt.instance.registerSingleton<AppConstants>(mockAppConstants);
    when(() => mockAppConstants.apiTimeout)
        .thenReturn(const Duration(milliseconds: 1000));

    dataSource = AuthRemoteDataSourceImpl(
      dio: mockDio,
      googleSignIn: mockGoogleSignIn,
      secureStorage: mockSecureStorage,
    );
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  group('updateCurrency', () {
    const tCurrency = 'USD';

    test('should perform a PATCH request to the update currency endpoint',
        () async {
      // Arrange
      when(() => mockDio.patch(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => MockResponse());

      // Act
      await dataSource.updateCurrency(tCurrency);

      // Assert
      verify(() => mockDio.patch(
            ApiEndpoints.updateCurrency,
            data: {'currency': tCurrency},
            options: any(named: 'options'),
          )).called(1);
    });

    test('should throw ServerException when the call is unsuccessful',
        () async {
      // Arrange
      when(() => mockDio.patch(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        error: 'Server Error',
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      ));

      // Act
      final call = dataSource.updateCurrency;

      // Assert
      expect(() => call(tCurrency), throwsA(isA<ServerException>()));
    });
  });

  group('signOut', () {
    test('should perform a POST request to the logout endpoint', () async {
      // Arrange
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
      when(() => mockSecureStorage.clearAllTokens())
          .thenAnswer((_) async => null);

      when(() => mockDio.post(
            any(),
            options: any(named: 'options'),
          )).thenAnswer((_) async => MockResponse());

      // Act
      await dataSource.signOut();

      // Assert
      verify(() => mockDio.post(
            ApiEndpoints.logout,
            options: any(named: 'options'),
          )).called(1);
    });

    test('should suppress backend errors and complete successfully', () async {
      // Arrange
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
      when(() => mockSecureStorage.clearAllTokens())
          .thenAnswer((_) async => null);

      when(() => mockDio.post(
            any(),
            options: any(named: 'options'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        error: 'Server Error',
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      ));

      // Act
      final call = dataSource.signOut;

      // Assert
      await expectLater(call(), completes);
      verify(() => mockGoogleSignIn.signOut()).called(1);
      verify(() => mockSecureStorage.clearAllTokens()).called(1);
    });
  });
}
