import 'package:dolfin_core/error/failures.dart';
import 'package:feature_auth/data/models/user_model.dart';
import 'package:balance_iq/features/home/data/models/dashboard_summary_response.dart';
import 'package:balance_iq/features/home/data/repository/dashboard_repository_impl.dart';
import 'package:balance_iq/features/home/domain/entities/dashbaord_summary.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks/mock_datasources.dart';

void main() {
  late DashboardRepositoryImpl repository;
  late MockDashboardRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockDashboardRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = DashboardRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      authLocalDataSource: mockLocalDataSource,
    );
  });

  final tUserModel = UserModel(
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
    photoUrl: null,
    authProvider: 'email',
    createdAt: DateTime(2023, 1, 1),
    isEmailVerified: true,
  );

  final tDashboardSummary = DashboardSummaryModel(
    totalIncome: 50000,
    totalExpense: 10000,
    netBalance: 40000,
    expenseRatio: 20.0,
    savingsRate: 80.0,
    spendingTrend: [
      SpendingTrendPoint(day: 1, amount: 100, date: DateTime(2025, 12, 1)),
      SpendingTrendPoint(day: 2, amount: 200, date: DateTime(2025, 12, 2)),
    ],
    categories: {'Food': 5000, 'Transport': 3000, 'Shopping': 2000},
    accountsBreakdown: {'Cash': 15000, 'Bank': 25000},
    biggestExpenseAmount: 2000,
    biggestExpenseDescription: 'Restaurant',
    expenseCategory: 'Food',
    expenseAccount: 'Cash',
    biggestCategoryName: 'Food',
    biggestCategoryAmount: 5000,
    biggestIncomeAmount: 50000,
    biggestIncomeDescription: 'Salary',
    period: 'December 2023',
    daysRemainingInMonth: 15,
    onboarded: true,
  );

  group('getDashboardSummary', () {
    test(
        'should return DashboardSummary when user is logged in and remote call succeeds',
        () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedUser())
          .thenAnswer((_) async => tUserModel);
      when(() => mockRemoteDataSource.getDashboardSummary(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => tDashboardSummary);

      // Act
      final result = await repository.getDashboardSummary();

      // Assert
      expect(result, Right(tDashboardSummary));
      verify(() => mockLocalDataSource.getCachedUser()).called(1);
      verify(() => mockRemoteDataSource.getDashboardSummary(
            startDate: null,
            endDate: null,
          )).called(1);
    });

    test('should pass date parameters to remote data source', () async {
      // Arrange
      const startDate = '2023-12-01';
      const endDate = '2023-12-31';
      when(() => mockLocalDataSource.getCachedUser())
          .thenAnswer((_) async => tUserModel);
      when(() => mockRemoteDataSource.getDashboardSummary(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => tDashboardSummary);

      // Act
      final result = await repository.getDashboardSummary(
        startDate: startDate,
        endDate: endDate,
      );

      // Assert
      expect(result, Right(tDashboardSummary));
      verify(() => mockRemoteDataSource.getDashboardSummary(
            startDate: startDate,
            endDate: endDate,
          )).called(1);
    });

    test('should return AuthFailure when user is not logged in', () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedUser())
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getDashboardSummary();

      // Assert
      expect(result, const Left(AuthFailure('User not logged in')));
      verify(() => mockLocalDataSource.getCachedUser()).called(1);
      verifyNever(() => mockRemoteDataSource.getDashboardSummary(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ));
    });

    test('should return ServerFailure when remote throws FormatException',
        () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedUser())
          .thenAnswer((_) async => tUserModel);
      when(() => mockRemoteDataSource.getDashboardSummary(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenThrow(const FormatException('Invalid JSON'));

      // Act
      final result = await repository.getDashboardSummary();

      // Assert
      expect(result,
          const Left(ServerFailure('Invalid data format: Invalid JSON')));
    });

    test('should return ServerFailure for no dashboard data available',
        () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedUser())
          .thenAnswer((_) async => tUserModel);
      when(() => mockRemoteDataSource.getDashboardSummary(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenThrow(Exception('No dashboard data available'));

      // Act
      final result = await repository.getDashboardSummary();

      // Assert
      expect(result, const Left(ServerFailure('No dashboard data available')));
    });

    test('should return ServerFailure for connection timeout', () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedUser())
          .thenAnswer((_) async => tUserModel);
      when(() => mockRemoteDataSource.getDashboardSummary(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenThrow(Exception('Connection timeout'));

      // Act
      final result = await repository.getDashboardSummary();

      // Assert
      expect(
          result,
          const Left(ServerFailure(
              'Connection timeout. Please check your internet connection.')));
    });

    test('should return ServerFailure for no internet connection', () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedUser())
          .thenAnswer((_) async => tUserModel);
      when(() => mockRemoteDataSource.getDashboardSummary(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenThrow(Exception('No internet connection'));

      // Act
      final result = await repository.getDashboardSummary();

      // Assert
      expect(
          result,
          const Left(ServerFailure(
              'No internet connection. Please check your network.')));
    });

    test('should return ServerFailure for server error', () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedUser())
          .thenAnswer((_) async => tUserModel);
      when(() => mockRemoteDataSource.getDashboardSummary(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenThrow(Exception('Server error 500'));

      // Act
      final result = await repository.getDashboardSummary();

      // Assert
      expect(result,
          const Left(ServerFailure('Server error. Please try again later.')));
    });

    test('should return generic ServerFailure for other exceptions', () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedUser())
          .thenAnswer((_) async => tUserModel);
      when(() => mockRemoteDataSource.getDashboardSummary(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenThrow(Exception('Unknown error'));

      // Act
      final result = await repository.getDashboardSummary();

      // Assert
      expect(result, const Left(ServerFailure('Exception: Unknown error')));
    });

    test('should return ServerFailure for unexpected error types', () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedUser())
          .thenAnswer((_) async => tUserModel);
      when(() => mockRemoteDataSource.getDashboardSummary(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenThrow('String error');

      // Act
      final result = await repository.getDashboardSummary();

      // Assert
      expect(result,
          const Left(ServerFailure('Failed to load dashboard: String error')));
    });
  });
}
