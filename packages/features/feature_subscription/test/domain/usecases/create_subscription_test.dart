import 'package:dartz/dartz.dart';
import 'package:dolfin_core/error/failures.dart';
import 'package:feature_subscription/domain/entities/plan.dart';
import 'package:feature_subscription/domain/entities/subscription.dart';
import 'package:feature_subscription/domain/usecases/create_subscription.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  late CreateSubscription createSubscription;
  late MockSubscriptionRepository mockSubscriptionRepository;

  setUp(() {
    mockSubscriptionRepository = MockSubscriptionRepository();
    createSubscription = CreateSubscription(mockSubscriptionRepository);
  });

  group('CreateSubscription', () {
    const testFeature = Feature(
      id: 1,
      code: 'FEATURE_1',
      name: 'Feature 1',
      description: 'Test feature',
      category: 'CORE',
      requiresPermission: false,
      isActive: true,
    );

    const testPlan = Plan(
      id: 2,
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
      features: [testFeature],
      isActive: true,
      subscriptionStatus: 'ACTIVE',
    );

    final testSubscription = Subscription(
      userId: 1,
      plan: testPlan,
      startDate: DateTime.parse('2024-01-01'),
      endDate: DateTime.parse('2024-02-01'),
      isActive: true,
      daysRemaining: 31,
    );

    test('should return Subscription when creation is successful', () async {
      // Arrange
      when(() => mockSubscriptionRepository.createSubscription(
            planName: any(named: 'planName'),
            autoRenew: any(named: 'autoRenew'),
          )).thenAnswer((_) async => Right(testSubscription));

      // Act
      final result = await createSubscription(
        planName: 'PREMIUM',
        autoRenew: true,
      );

      // Assert
      expect(result, Right(testSubscription));
      verify(() => mockSubscriptionRepository.createSubscription(
            planName: 'PREMIUM',
            autoRenew: true,
          )).called(1);
    });

    test('should return Subscription with different plan', () async {
      // Arrange
      const basicPlan = Plan(
        id: 1,
        name: 'BASIC',
        displayName: 'Basic Plan',
        description: 'Basic subscription',
        price: 4.99,
        billingCycle: 'MONTHLY',
        tier: 1,
        maxProjects: 5,
        maxStorageGb: 50,
        maxApiCallsPerMonth: 5000,
        maxTeamMembers: 2,
        features: [testFeature],
        isActive: true,
        subscriptionStatus: 'ACTIVE',
      );

      final basicSubscription = Subscription(
        userId: 1,
        plan: basicPlan,
        startDate: DateTime.parse('2024-01-01'),
        endDate: DateTime.parse('2024-02-01'),
        isActive: true,
        daysRemaining: 31,
      );

      when(() => mockSubscriptionRepository.createSubscription(
            planName: any(named: 'planName'),
            autoRenew: any(named: 'autoRenew'),
          )).thenAnswer((_) async => Right(basicSubscription));

      // Act
      final result = await createSubscription(
        planName: 'BASIC',
        autoRenew: false,
      );

      // Assert
      expect(result, Right(basicSubscription));
      verify(() => mockSubscriptionRepository.createSubscription(
            planName: 'BASIC',
            autoRenew: false,
          )).called(1);
    });

    test('should return ServerFailure when payment processing fails', () async {
      // Arrange
      when(() => mockSubscriptionRepository.createSubscription(
                planName: any(named: 'planName'),
                autoRenew: any(named: 'autoRenew'),
              ))
          .thenAnswer((_) async =>
              const Left(ServerFailure('Payment processing failed')));

      // Act
      final result = await createSubscription(
        planName: 'PREMIUM',
        autoRenew: true,
      );

      // Assert
      expect(result, const Left(ServerFailure('Payment processing failed')));
    });

    test('should return AuthFailure when not authenticated', () async {
      // Arrange
      when(() => mockSubscriptionRepository.createSubscription(
            planName: any(named: 'planName'),
            autoRenew: any(named: 'autoRenew'),
          )).thenAnswer((_) async => const Left(AuthFailure('Unauthorized')));

      // Act
      final result = await createSubscription(
        planName: 'PREMIUM',
        autoRenew: true,
      );

      // Assert
      expect(result, const Left(AuthFailure('Unauthorized')));
    });

    test('should return ValidationFailure for invalid plan', () async {
      // Arrange
      when(() => mockSubscriptionRepository.createSubscription(
                planName: any(named: 'planName'),
                autoRenew: any(named: 'autoRenew'),
              ))
          .thenAnswer(
              (_) async => const Left(ValidationFailure('Invalid plan name')));

      // Act
      final result = await createSubscription(
        planName: 'INVALID_PLAN',
        autoRenew: true,
      );

      // Assert
      expect(result, const Left(ValidationFailure('Invalid plan name')));
    });
  });
}
