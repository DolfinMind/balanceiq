import 'package:feature_subscription/data/datasources/subscription_datasource.dart';
import 'package:feature_subscription/data/models/create_subscription_request.dart';
import 'package:feature_subscription/data/models/plan_dto.dart';
import 'package:feature_subscription/data/models/subscription_dto.dart';
import 'package:feature_subscription/data/repositories/subscription_repository_impl.dart';
import 'package:feature_subscription/domain/entities/plan.dart';
import 'package:feature_subscription/domain/entities/subscription.dart';
import 'package:feature_subscription/domain/entities/subscription_status.dart';
import 'package:feature_subscription/domain/usecases/create_subscription.dart';
import 'package:feature_subscription/domain/usecases/get_all_plans.dart';
import 'package:feature_subscription/domain/usecases/get_subscription_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

/// Integration tests for subscription feature
/// Tests the complete flow from datasource → repository → use case
void main() {
  late SubscriptionDataSource dataSource;
  late SubscriptionRepositoryImpl repository;
  late GetAllPlans getAllPlansUseCase;
  late GetSubscriptionStatus getSubscriptionStatusUseCase;
  late CreateSubscription createSubscriptionUseCase;

  setUp(() {
    dataSource = MockSubscriptionDataSource();
    repository = SubscriptionRepositoryImpl(remoteDataSource: dataSource);
    getAllPlansUseCase = GetAllPlans(repository);
    getSubscriptionStatusUseCase = GetSubscriptionStatus(repository);
    createSubscriptionUseCase = CreateSubscription(repository);
  });

  setUpAll(() {
    registerFallbackValue(
      CreateSubscriptionRequest(planName: 'PREMIUM', autoRenew: true),
    );
  });

  group('Subscription Feature Integration Tests', () {
    final testFeatureDto = FeatureDto(
      id: 1,
      code: 'FEATURE_1',
      name: 'Feature 1',
      description: 'Test feature',
      category: 'CORE',
      requiresPermission: false,
      isActive: true,
      subscriptionStatus: 'ACTIVE',
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
      subscriptionStatus: 'ACTIVE',
      daysRemaining: 31,
    );

    group('Complete User Flow: Browse Plans → Create Subscription', () {
      test('should complete full subscription creation flow', () async {
        // Step 1: User loads available plans
        when(() => dataSource.getAllPlans())
            .thenAnswer((_) async => [testPlanDto]);

        final plansResult = await getAllPlansUseCase();

        expect(plansResult.isRight(), true);
        plansResult.fold(
          (failure) => fail('Should not fail'),
          (plans) {
            expect(plans.length, 1);
            expect(plans[0].name, 'PREMIUM');
            expect(plans[0].price, 9.99);
          },
        );

        // Step 2: User checks subscription status (no active subscription)
        when(() => dataSource.getSubscriptionStatus()).thenAnswer(
          (_) async => SubscriptionStatusDto(
            hasActiveSubscription: false,
            subscription: null,
          ),
        );

        final statusResult = await getSubscriptionStatusUseCase();

        expect(statusResult.isRight(), true);
        statusResult.fold(
          (failure) => fail('Should not fail'),
          (status) {
            expect(status.hasActiveSubscription, false);
            expect(status.subscription, isNull);
          },
        );

        // Step 3: User creates a subscription
        when(() => dataSource.createSubscription(any()))
            .thenAnswer((_) async => testSubscriptionDto);

        final createResult = await createSubscriptionUseCase(
          planName: 'PREMIUM',
          autoRenew: true,
        );

        expect(createResult.isRight(), true);
        createResult.fold(
          (failure) => fail('Should not fail'),
          (subscription) {
            expect(subscription.userId, 1);
            expect(subscription.plan!.name, 'PREMIUM');
            expect(subscription.isActive, true);
          },
        );

        // Step 4: Verify subscription status after creation
        when(() => dataSource.getSubscriptionStatus()).thenAnswer(
          (_) async => SubscriptionStatusDto(
            hasActiveSubscription: true,
            subscription: testSubscriptionDto,
          ),
        );

        final finalStatusResult = await getSubscriptionStatusUseCase();

        expect(finalStatusResult.isRight(), true);
        finalStatusResult.fold(
          (failure) => fail('Should not fail'),
          (status) {
            expect(status.hasActiveSubscription, true);
            expect(status.subscription, isNotNull);
            expect(status.subscription!.plan!.name, 'PREMIUM');
          },
        );

        // Verify all interactions
        verify(() => dataSource.getAllPlans()).called(1);
        verify(() => dataSource.getSubscriptionStatus()).called(2);
        verify(() => dataSource.createSubscription(any())).called(1);
      });
    });

    group('Error Propagation Through Layers', () {
      test('should propagate auth error from datasource to use case', () async {
        // Arrange - datasource throws auth error
        when(() => dataSource.getAllPlans()).thenThrow(
          Exception('Authentication required. Please login.'),
        );

        // Act - error flows through repository to use case
        final result = await getAllPlansUseCase();

        // Assert - use case returns AuthFailure
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, contains('login')),
          (plans) => fail('Should not succeed'),
        );
      });

      test('should propagate network error from datasource to use case',
          () async {
        // Arrange
        when(() => dataSource.getAllPlans()).thenThrow(
          Exception('No internet connection'),
        );

        // Act
        final result = await getAllPlansUseCase();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, contains('internet')),
          (plans) => fail('Should not succeed'),
        );
      });
    });

    group('Data Transformation Through Layers', () {
      test('should correctly transform DTO to entity', () async {
        // Arrange - datasource returns DTO
        when(() => dataSource.getAllPlans())
            .thenAnswer((_) async => [testPlanDto]);

        // Act - repository transforms to entity
        final result = await getAllPlansUseCase();

        // Assert - use case receives clean entity
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail'),
          (plans) {
            final plan = plans[0];
            expect(plan, isA<Plan>()); // Not PlanDto
            expect(plan.id, testPlanDto.id);
            expect(plan.name, testPlanDto.name);
            expect(plan.price, testPlanDto.price);
            expect(plan.features.length, testPlanDto.features.length);
            expect(plan.formattedPrice, '\$9.99'); // Computed property works
            expect(plan.isMonthly, true); // Computed property works
          },
        );
      });

      test('should handle Subscription DTO to entity transformation', () async {
        // Arrange
        when(() => dataSource.getSubscriptionStatus()).thenAnswer(
          (_) async => SubscriptionStatusDto(
            hasActiveSubscription: true,
            subscription: testSubscriptionDto,
          ),
        );

        // Act
        final result = await getSubscriptionStatusUseCase();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail'),
          (status) {
            expect(status, isA<SubscriptionStatus>()); // Not DTO
            expect(status.subscription, isA<Subscription>()); // Not DTO
            expect(status.subscription!.userId, 1);
            expect(status.subscription!.isExpired, false); // Computed property
          },
        );
      });
    });

    group('Edge Cases Through Complete Flow', () {
      test('should handle empty plans list', () async {
        // Arrange
        when(() => dataSource.getAllPlans()).thenAnswer((_) async => []);

        // Act
        final result = await getAllPlansUseCase();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail'),
          (plans) => expect(plans, isEmpty),
        );
      });

      test('should handle subscription conflict error', () async {
        // Arrange
        when(() => dataSource.createSubscription(any())).thenThrow(
          Exception('Conflict: Active subscription already exists'),
        );

        // Act
        final result = await createSubscriptionUseCase(
          planName: 'PREMIUM',
          autoRenew: true,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) =>
              expect(failure.message, contains('subscription already exists')),
          (subscription) => fail('Should not succeed'),
        );
      });
    });
  });
}
