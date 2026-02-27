import 'package:dolfin_core/error/failures.dart';
import 'package:balance_iq/features/home/domain/entities/dashbaord_summary.dart';
import 'package:balance_iq/features/home/domain/usecase/get_user_dashbaord.dart';
import 'package:balance_iq/features/home/presentation/cubit/dashboard_cubit.dart';
import 'package:balance_iq/features/home/presentation/cubit/dashboard_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetDashboardSummary extends Mock implements GetDashboardSummary {}

void main() {
  late DashboardCubit dashboardCubit;
  late MockGetDashboardSummary mockGetDashboardSummary;

  setUp(() {
    mockGetDashboardSummary = MockGetDashboardSummary();
    dashboardCubit = DashboardCubit(
      getDashboardSummary: mockGetDashboardSummary,
    );
  });

  tearDown(() {
    dashboardCubit.close();
  });

  group('DashboardCubit', () {
    const tDashboardSummary = DashboardSummary(
      totalIncome: 5000.0,
      totalExpense: 3000.0,
      netBalance: 2000.0,
      expenseRatio: 0.6,
      savingsRate: 0.4,
      spendingTrend: [],
      categories: {},
      accountsBreakdown: {},
      biggestExpenseAmount: 500.0,
      biggestExpenseDescription: 'Groceries',
      expenseCategory: 'Food',
      expenseAccount: 'Cash',
      biggestCategoryName: 'Food',
      biggestCategoryAmount: 1000.0,
      biggestIncomeAmount: 2000.0,
      biggestIncomeDescription: 'Salary',
      period: 'January 2025',
      daysRemainingInMonth: 15,
      onboarded: true,
    );

    test('initial state is DashboardInitial', () {
      expect(dashboardCubit.state, isA<DashboardInitial>());
    });

    group('loadDashboard', () {
      blocTest<DashboardCubit, DashboardState>(
        'emits [DashboardLoading, DashboardLoaded] when successful',
        build: () {
          when(() => mockGetDashboardSummary(
                startDate: any(named: 'startDate'),
                endDate: any(named: 'endDate'),
              )).thenAnswer((_) async => const Right(tDashboardSummary));
          return dashboardCubit;
        },
        act: (cubit) => cubit.loadDashboard(
          startDate: '2025-01-01',
          endDate: '2025-01-31',
        ),
        expect: () => [
          isA<DashboardLoading>(),
          isA<DashboardLoaded>()
              .having((s) => s.summary, 'summary', tDashboardSummary),
        ],
        verify: (_) {
          verify(() => mockGetDashboardSummary(
                startDate: '2025-01-01',
                endDate: '2025-01-31',
              )).called(1);
        },
      );

      blocTest<DashboardCubit, DashboardState>(
        'emits [DashboardLoading, DashboardLoaded] with default dates when not provided',
        build: () {
          when(() => mockGetDashboardSummary(
                startDate: any(named: 'startDate'),
                endDate: any(named: 'endDate'),
              )).thenAnswer((_) async => const Right(tDashboardSummary));
          return dashboardCubit;
        },
        act: (cubit) => cubit.loadDashboard(),
        expect: () => [
          isA<DashboardLoading>(),
          isA<DashboardLoaded>()
              .having((s) => s.summary, 'summary', tDashboardSummary),
        ],
        verify: (_) {
          // Verify it was called with some dates (current month)
          verify(() => mockGetDashboardSummary(
                startDate: any(named: 'startDate'),
                endDate: any(named: 'endDate'),
              )).called(1);
        },
      );

      blocTest<DashboardCubit, DashboardState>(
        'emits [DashboardLoading, DashboardError] when usecase fails',
        build: () {
          when(() => mockGetDashboardSummary(
                startDate: any(named: 'startDate'),
                endDate: any(named: 'endDate'),
              )).thenAnswer(
            (_) async => const Left(ServerFailure('Server error')),
          );
          return dashboardCubit;
        },
        act: (cubit) => cubit.loadDashboard(
          startDate: '2025-01-01',
          endDate: '2025-01-31',
        ),
        expect: () => [
          isA<DashboardLoading>(),
          isA<DashboardError>()
              .having((s) => s.message, 'message', 'Server error'),
        ],
      );

      blocTest<DashboardCubit, DashboardState>(
        'emits [DashboardLoading, DashboardError] on network error',
        build: () {
          when(() => mockGetDashboardSummary(
                startDate: any(named: 'startDate'),
                endDate: any(named: 'endDate'),
              )).thenAnswer(
            (_) async => const Left(NetworkFailure('No internet connection')),
          );
          return dashboardCubit;
        },
        act: (cubit) => cubit.loadDashboard(),
        expect: () => [
          isA<DashboardLoading>(),
          isA<DashboardError>()
              .having((s) => s.message, 'message', 'No internet connection'),
        ],
      );
    });

    group('refreshDashboard', () {
      blocTest<DashboardCubit, DashboardState>(
        'calls loadDashboard with provided dates',
        build: () {
          when(() => mockGetDashboardSummary(
                startDate: any(named: 'startDate'),
                endDate: any(named: 'endDate'),
              )).thenAnswer((_) async => const Right(tDashboardSummary));
          return dashboardCubit;
        },
        act: (cubit) => cubit.refreshDashboard(
          startDate: '2025-02-01',
          endDate: '2025-02-28',
        ),
        expect: () => [
          isA<DashboardLoading>(),
          isA<DashboardLoaded>(),
        ],
        verify: (_) {
          verify(() => mockGetDashboardSummary(
                startDate: '2025-02-01',
                endDate: '2025-02-28',
              )).called(1);
        },
      );
    });
  });
}
