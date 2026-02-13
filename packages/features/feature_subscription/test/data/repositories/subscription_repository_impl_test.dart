import 'package:dio/dio.dart';
import 'package:dolfin_core/error/failures.dart';
import 'package:feature_subscription/data/models/create_subscription_request.dart';
import 'package:feature_subscription/data/models/plan_dto.dart';
import 'package:feature_subscription/data/models/subscription_dto.dart';
import 'package:feature_subscription/data/repositories/subscription_repository_impl.dart';
import 'package:feature_subscription/domain/entities/plan.dart';
import 'package:feature_subscription/domain/entities/subscription.dart';
import 'package:feature_subscription/domain/entities/subscription_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  late SubscriptionRepositoryImpl repository;
  late MockSubscriptionDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockSubscriptionDataSource();
    repository = SubscriptionRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('SubscriptionRepositoryImpl', () {
    final testFeatureDto = FeatureDto(
      id: 1,
      code: 'FEATURE_1',
      name: 'Feature 1',
      description: 'Test feature',
      category: 'CORE',
      requiresPermission: false,
      isActive: true,
    );

    final testPlanDto = PlanDto(
      id: 1,
      name: 'PREMIUM',
      displayName: 'Premium Plan',
      description: 'Premium subscription',
      price: 9.99,
      billingCycle: 'MONTHLY',
      tier: 2,
      maxProjects: 10,
      maxStorageGb: 100,
      maxApiCallsPerMonth: 10000,
      maxTeamMembers: 5,
      features: [testFeatureDto],
      isActive: true,
      subscriptionStatus: 'ACTIVE',
    );

    final testSubscriptionDto = SubscriptionDto(
      userId: 1,
      plan: testPlanDto,
      startDate: DateTime.parse('2024-01-01'),
      endDate: DateTime.parse('2024-02-01'),
      isActive: true,
      daysRemaining: 31,
    );

    group('getAllPlans', () {
      test('should return list of Plan entities when successful', () async {
        // Arrange
        when(() => mockDataSource.getAllPlans())
            .thenAnswer((_) async => [testPlanDto]);

        // Act
        final result = await repository.getAllPlans();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (plans) {
            expect(plans, isA<List<Plan>>());
            expect(plans.length, 1);
            expect(plans[0].name, 'PREMIUM');
            expect(plans[0].price, 9.99);
          },
        );
        verify(() => mockDataSource.getAllPlans()).called(1);
      });

      test('should return empty list when no plans available', () async {
        // Arrange
        when(() => mockDataSource.getAllPlans()).thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllPlans();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (plans) => expect(plans, isEmpty),
        );
      });

      test('should return AuthFailure when authentication fails', () async {
        // Arrange
        when(() => mockDataSource.getAllPlans()).thenThrow(
          Exception('Authentication required. Please login.'),
        );

        // Act
        final result = await repository.getAllPlans();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('login'));
          },
          (plans) => fail('Should not return success'),
        );
      });

      test('should return NetworkFailure on connection error', () async {
        // Arrange
        when(() => mockDataSource.getAllPlans()).thenThrow(
          Exception('No internet connection'),
        );

        // Act
        final result = await repository.getAllPlans();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, contains('internet'));
          },
          (plans) => fail('Should not return success'),
        );
      });

      test('should return NetworkFailure on timeout', () async {
        // Arrange
        when(() => mockDataSource.getAllPlans()).thenThrow(
          Exception('Connection timeout'),
        );

        // Act
        final result = await repository.getAllPlans();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, contains('internet'));
          },
          (plans) => fail('Should not return success'),
        );
      });

      test('should return ServerFailure on server error', () async {
        // Arrange
        when(() => mockDataSource.getAllPlans()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/plans'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/plans'),
              statusCode: 500,
            ),
          ),
        );

        // Act
        final result = await repository.getAllPlans();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (plans) => fail('Should not return success'),
        );
      });
    });

    group('getSubscriptionStatus', () {
      test('should return SubscriptionStatus with active subscription',
          () async {
        // Arrange
        final statusDto = SubscriptionStatusDto(
          hasActiveSubscription: true,
          subscription: testSubscriptionDto,
        );
        when(() => mockDataSource.getSubscriptionStatus())
            .thenAnswer((_) async => statusDto);

        // Act
        final result = await repository.getSubscriptionStatus();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (status) {
            expect(status, isA<SubscriptionStatus>());
            expect(status.hasActiveSubscription, true);
            expect(status.subscription, isNotNull);
            expect(status.subscription!.userId, 1);
          },
        );
        verify(() => mockDataSource.getSubscriptionStatus()).called(1);
      });

      test('should return SubscriptionStatus without active subscription',
          () async {
        // Arrange
        final statusDto = SubscriptionStatusDto(
          hasActiveSubscription: false,
          subscription: null,
        );
        when(() => mockDataSource.getSubscriptionStatus())
            .thenAnswer((_) async => statusDto);

        // Act
        final result = await repository.getSubscriptionStatus();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (status) {
            expect(status.hasActiveSubscription, false);
            expect(status.subscription, isNull);
          },
        );
      });

      test('should return AuthFailure when not authenticated', () async {
        // Arrange
        when(() => mockDataSource.getSubscriptionStatus()).thenThrow(
          Exception('Unauthorized. Please login again.'),
        );

        // Act
        final result = await repository.getSubscriptionStatus();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('login'));
          },
          (status) => fail('Should not return success'),
        );
      });

      test('should return ServerFailure on connection error', () async {
        // Arrange
        when(() => mockDataSource.getSubscriptionStatus()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/subscriptions/status'),
            type: DioExceptionType.connectionError,
          ),
        );

        // Act
        final result = await repository.getSubscriptionStatus();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (status) => fail('Should not return success'),
        );
      });
    });

    group('createSubscription', () {
      setUpAll(() {
        registerFallbackValue(
          CreateSubscriptionRequest(planName: 'PREMIUM', autoRenew: true),
        );
      });

      test('should return Subscription when creation is successful', () async {
        // Arrange
        when(() => mockDataSource.createSubscription(any()))
            .thenAnswer((_) async => testSubscriptionDto);

        // Act
        final result = await repository.createSubscription(
          planName: 'PREMIUM',
          autoRenew: true,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (subscription) {
            expect(subscription, isA<Subscription>());
            expect(subscription.userId, 1);
            expect(subscription.plan!.name, 'PREMIUM');
            expect(subscription.isActive, true);
          },
        );
        verify(() => mockDataSource.createSubscription(any())).called(1);
      });

      test('should return ServerFailure when subscription already exists',
          () async {
        // Arrange
        when(() => mockDataSource.createSubscription(any())).thenThrow(
          Exception('Conflict: Active subscription already exists'),
        );

        // Act
        final result = await repository.createSubscription(
          planName: 'PREMIUM',
          autoRenew: true,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('subscription already exists'));
          },
          (subscription) => fail('Should not return success'),
        );
      });

      test('should return AuthFailure when not authenticated', () async {
        // Arrange
        when(() => mockDataSource.createSubscription(any())).thenThrow(
          Exception('Authentication required. Please login.'),
        );

        // Act
        final result = await repository.createSubscription(
          planName: 'PREMIUM',
          autoRenew: false,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('login'));
          },
          (subscription) => fail('Should not return success'),
        );
      });

      test('should return NotFoundFailure when plan not found', () async {
        // Arrange
        when(() => mockDataSource.createSubscription(any())).thenThrow(
          Exception('Resource not found'),
        );

        // Act
        final result = await repository.createSubscription(
          planName: 'INVALID_PLAN',
          autoRenew: true,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<NotFoundFailure>());
          },
          (subscription) => fail('Should not return success'),
        );
      });

      test('should return PermissionFailure when access denied', () async {
        // Arrange
        when(() => mockDataSource.createSubscription(any())).thenThrow(
          Exception('Access denied. You do not have permission.'),
        );

        // Act
        final result = await repository.createSubscription(
          planName: 'PREMIUM',
          autoRenew: true,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<PermissionFailure>());
            expect(failure.message, contains('permission'));
          },
          (subscription) => fail('Should not return success'),
        );
      });

      test('should return ServerFailure on generic error', () async {
        // Arrange
        when(() => mockDataSource.createSubscription(any())).thenThrow(
          Exception('Something went wrong'),
        );

        // Act
        final result = await repository.createSubscription(
          planName: 'PREMIUM',
          autoRenew: true,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
          },
          (subscription) => fail('Should not return success'),
        );
      });
    });
  });
}
