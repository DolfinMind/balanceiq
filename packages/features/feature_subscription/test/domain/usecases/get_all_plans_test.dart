import 'package:dartz/dartz.dart';
import 'package:dolfin_core/error/failures.dart';
import 'package:feature_subscription/domain/entities/plan.dart';
import 'package:feature_subscription/domain/usecases/get_all_plans.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  late GetAllPlans getAllPlans;
  late MockSubscriptionRepository mockSubscriptionRepository;

  setUp(() {
    mockSubscriptionRepository = MockSubscriptionRepository();
    getAllPlans = GetAllPlans(mockSubscriptionRepository);
  });

  group('GetAllPlans', () {
    const testFeature = Feature(
      id: 1,
      code: 'FEATURE_1',
      name: 'Feature 1',
      description: 'Test feature',
      category: 'CORE',
      requiresPermission: false,
      isActive: true,
    );

    const testPlans = [
      Plan(
        id: 1,
        name: 'FREE',
        displayName: 'Free Plan',
        description: 'Basic features',
        price: 0.0,
        billingCycle: 'MONTHLY',
        tier: 1,
        maxProjects: 1,
        maxStorageGb: 1,
        maxApiCallsPerMonth: 100,
        maxTeamMembers: 1,
        features: [testFeature],
        isActive: true,
        subscriptionStatus: 'ACTIVE',
      ),
      Plan(
        id: 2,
        name: 'PREMIUM',
        displayName: 'Premium Plan',
        description: 'All features',
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
      ),
    ];

    test('should return list of plans when successful', () async {
      // Arrange
      when(() => mockSubscriptionRepository.getAllPlans())
          .thenAnswer((_) async => const Right(testPlans));

      // Act
      final result = await getAllPlans();

      // Assert
      expect(result, const Right(testPlans));
      verify(() => mockSubscriptionRepository.getAllPlans()).called(1);
    });

    test('should return empty list when no plans available', () async {
      // Arrange
      when(() => mockSubscriptionRepository.getAllPlans())
          .thenAnswer((_) async => const Right(<Plan>[]));

      // Act
      final result = await getAllPlans();

      // Assert
      expect(result, const Right(<Plan>[]));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      when(() => mockSubscriptionRepository.getAllPlans())
          .thenAnswer((_) async => const Left(ServerFailure('Server error')));

      // Act
      final result = await getAllPlans();

      // Assert
      expect(result, const Left(ServerFailure('Server error')));
    });

    test('should return NetworkFailure when no internet', () async {
      // Arrange
      when(() => mockSubscriptionRepository.getAllPlans()).thenAnswer(
          (_) async => const Left(NetworkFailure('No internet connection')));

      // Act
      final result = await getAllPlans();

      // Assert
      expect(result, const Left(NetworkFailure('No internet connection')));
    });
  });
}
