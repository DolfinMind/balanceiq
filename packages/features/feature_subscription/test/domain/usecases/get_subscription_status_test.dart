import 'package:dartz/dartz.dart';
import 'package:dolfin_core/error/failures.dart';
import 'package:feature_subscription/domain/entities/plan.dart';
import 'package:feature_subscription/domain/entities/subscription.dart';
import 'package:feature_subscription/domain/entities/subscription_status.dart';
import 'package:feature_subscription/domain/usecases/get_subscription_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  late GetSubscriptionStatus getSubscriptionStatus;
  late MockSubscriptionRepository mockSubscriptionRepository;

  setUp(() {
    mockSubscriptionRepository = MockSubscriptionRepository();
    getSubscriptionStatus = GetSubscriptionStatus(mockSubscriptionRepository);
  });

  group('GetSubscriptionStatus', () {
    const testFeature = Feature(
      id: 1,
      code: 'FEATURE_1',
      name: 'Feature 1',
      description: 'Test feature',
      category: 'CORE',
      requiresPermission: false,
      isActive: true,
      subscriptionStatus: 'ACTIVE',
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
      subscriptionStatus: 'ACTIVE',
      daysRemaining: 31,
    );

    final testSubscriptionStatus = SubscriptionStatus(
      hasActiveSubscription: true,
      subscription: testSubscription,
    );

    const testNoSubscriptionStatus = SubscriptionStatus(
      hasActiveSubscription: false,
      subscription: null,
    );

    test('should return SubscriptionStatus with active subscription', () async {
      // Arrange
      when(() => mockSubscriptionRepository.getSubscriptionStatus())
          .thenAnswer((_) async => Right(testSubscriptionStatus));

      // Act
      final result = await getSubscriptionStatus();

      // Assert
      expect(result, Right(testSubscriptionStatus));
      verify(() => mockSubscriptionRepository.getSubscriptionStatus())
          .called(1);
    });

    test('should return SubscriptionStatus without active subscription',
        () async {
      // Arrange
      when(() => mockSubscriptionRepository.getSubscriptionStatus())
          .thenAnswer((_) async => const Right(testNoSubscriptionStatus));

      // Act
      final result = await getSubscriptionStatus();

      // Assert
      expect(result, const Right(testNoSubscriptionStatus));
    });

    test('should return AuthFailure when not authenticated', () async {
      // Arrange
      when(() => mockSubscriptionRepository.getSubscriptionStatus())
          .thenAnswer((_) async => const Left(AuthFailure('Unauthorized')));

      // Act
      final result = await getSubscriptionStatus();

      // Assert
      expect(result, const Left(AuthFailure('Unauthorized')));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      when(() => mockSubscriptionRepository.getSubscriptionStatus())
          .thenAnswer((_) async => const Left(ServerFailure('Server error')));

      // Act
      final result = await getSubscriptionStatus();

      // Assert
      expect(result, const Left(ServerFailure('Server error')));
    });
  });
}
