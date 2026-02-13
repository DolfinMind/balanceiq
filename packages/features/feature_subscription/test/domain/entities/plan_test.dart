import 'package:feature_subscription/domain/entities/plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Plan Entity', () {
    const testFeature = Feature(
      id: 1,
      code: 'FEATURE_1',
      name: 'Feature 1',
      description: 'Test feature',
      category: 'CORE',
      requiresPermission: false,
      isActive: true,
    );

    group('formattedPrice', () {
      test('should format price with 2 decimal places', () {
        // Arrange
        const plan = Plan(
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
          features: [testFeature],
          isActive: true,
          subscriptionStatus: 'ACTIVE',
        );

        // Act & Assert
        expect(plan.formattedPrice, '\$9.99');
      });

      test('should format whole number price with .00', () {
        // Arrange
        const plan = Plan(
          id: 1,
          name: 'BASIC',
          displayName: 'Basic Plan',
          description: 'Basic subscription',
          price: 5.0,
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

        // Act & Assert
        expect(plan.formattedPrice, '\$5.00');
      });

      test('should format price over 100', () {
        // Arrange
        const plan = Plan(
          id: 3,
          name: 'ENTERPRISE',
          displayName: 'Enterprise Plan',
          description: 'Enterprise subscription',
          price: 199.99,
          billingCycle: 'YEARLY',
          tier: 3,
          maxProjects: 100,
          maxStorageGb: 1000,
          maxApiCallsPerMonth: 100000,
          maxTeamMembers: 50,
          features: [testFeature],
          isActive: true,
          subscriptionStatus: 'ACTIVE',
        );

        // Act & Assert
        expect(plan.formattedPrice, '\$199.99');
      });
    });

    group('isMonthly', () {
      test('should return true when billingCycle is MONTHLY', () {
        // Arrange
        const plan = Plan(
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
          features: [testFeature],
          isActive: true,
          subscriptionStatus: 'ACTIVE',
        );

        // Act & Assert
        expect(plan.isMonthly, true);
      });

      test('should return false when billingCycle is YEARLY', () {
        // Arrange
        const plan = Plan(
          id: 1,
          name: 'PREMIUM_YEARLY',
          displayName: 'Premium Yearly Plan',
          description: 'Premium yearly subscription',
          price: 99.99,
          billingCycle: 'YEARLY',
          tier: 2,
          maxProjects: 10,
          maxStorageGb: 100,
          maxApiCallsPerMonth: 10000,
          maxTeamMembers: 5,
          features: [testFeature],
          isActive: true,
          subscriptionStatus: 'ACTIVE',
        );

        // Act & Assert
        expect(plan.isMonthly, false);
      });

      test('should return false for other billing cycles', () {
        // Arrange
        const plan = Plan(
          id: 1,
          name: 'WEEKLY',
          displayName: 'Weekly Plan',
          description: 'Weekly subscription',
          price: 2.99,
          billingCycle: 'WEEKLY',
          tier: 1,
          maxProjects: 5,
          maxStorageGb: 50,
          maxApiCallsPerMonth: 5000,
          maxTeamMembers: 2,
          features: [testFeature],
          isActive: true,
          subscriptionStatus: 'ACTIVE',
        );

        // Act & Assert
        expect(plan.isMonthly, false);
      });
    });

    group('isYearly', () {
      test('should return true when billingCycle is YEARLY', () {
        // Arrange
        const plan = Plan(
          id: 1,
          name: 'PREMIUM_YEARLY',
          displayName: 'Premium Yearly',
          description: 'Premium yearly subscription',
          price: 99.99,
          billingCycle: 'YEARLY',
          tier: 2,
          maxProjects: 10,
          maxStorageGb: 100,
          maxApiCallsPerMonth: 10000,
          maxTeamMembers: 5,
          features: [testFeature],
          isActive: true,
          subscriptionStatus: 'ACTIVE',
        );

        // Act & Assert
        expect(plan.isYearly, true);
      });

      test('should return false when billingCycle is MONTHLY', () {
        // Arrange
        const plan = Plan(
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
          features: [testFeature],
          isActive: true,
          subscriptionStatus: 'ACTIVE',
        );

        // Act & Assert
        expect(plan.isYearly, false);
      });
    });

    group('isComingSoon', () {
      test('should return true when subscriptionStatus is COMING_SOON', () {
        // Arrange
        const plan = Plan(
          id: 1,
          name: 'FUTURE_PLAN',
          displayName: 'Future Plan',
          description: 'Future subscription',
          price: 99.99,
          billingCycle: 'MONTHLY',
          tier: 3,
          maxProjects: 10,
          maxStorageGb: 100,
          maxApiCallsPerMonth: 10000,
          maxTeamMembers: 5,
          features: [testFeature],
          isActive: true,
          subscriptionStatus: 'COMING_SOON',
        );

        // Act & Assert
        expect(plan.isComingSoon, true);
      });

      test('should return false when subscriptionStatus is ACTIVE', () {
        // Arrange
        const plan = Plan(
          id: 1,
          name: 'Current Plan',
          displayName: 'Current Plan',
          description: 'Current subscription',
          price: 9.99,
          billingCycle: 'MONTHLY',
          tier: 1,
          maxProjects: 10,
          maxStorageGb: 100,
          maxApiCallsPerMonth: 10000,
          maxTeamMembers: 5,
          features: [testFeature],
          isActive: true,
          subscriptionStatus: 'ACTIVE',
        );

        // Act & Assert
        expect(plan.isComingSoon, false);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        const plan1 = Plan(
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
          features: [testFeature],
          isActive: true,
          subscriptionStatus: 'ACTIVE',
        );

        const plan2 = Plan(
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
          features: [testFeature],
          isActive: true,
          subscriptionStatus: 'ACTIVE',
        );

        // Act & Assert
        expect(plan1, equals(plan2));
        expect(plan1.hashCode, equals(plan2.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        const plan1 = Plan(
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
          features: [testFeature],
          isActive: true,
          subscriptionStatus: 'ACTIVE',
        );

        const plan2 = Plan(
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

        // Act & Assert
        expect(plan1, isNot(equals(plan2)));
      });

      test('should not be equal when price differs', () {
        // Arrange
        const plan1 = Plan(
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
          features: [testFeature],
          isActive: true,
          subscriptionStatus: 'ACTIVE',
        );

        const plan2 = Plan(
          id: 1,
          name: 'PREMIUM',
          displayName: 'Premium Plan',
          description: 'Premium subscription',
          price: 14.99,
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

        // Act & Assert
        expect(plan1, isNot(equals(plan2)));
      });
    });
  });

  group('Feature Entity', () {
    group('Equatable', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        const feature1 = Feature(
          id: 1,
          code: 'FEATURE_1',
          name: 'Feature 1',
          description: 'Test feature',
          category: 'CORE',
          requiresPermission: false,
          isActive: true,
        );

        const feature2 = Feature(
          id: 1,
          code: 'FEATURE_1',
          name: 'Feature 1',
          description: 'Test feature',
          category: 'CORE',
          requiresPermission: false,
          isActive: true,
        );

        // Act & Assert
        expect(feature1, equals(feature2));
        expect(feature1.hashCode, equals(feature2.hashCode));
      });

      test('should not be equal when code differs', () {
        // Arrange
        const feature1 = Feature(
          id: 1,
          code: 'FEATURE_1',
          name: 'Feature 1',
          description: 'Test feature',
          category: 'CORE',
          requiresPermission: false,
          isActive: true,
        );

        const feature2 = Feature(
          id: 1,
          code: 'FEATURE_2',
          name: 'Feature 1',
          description: 'Test feature',
          category: 'CORE',
          requiresPermission: false,
          isActive: true,
        );

        // Act & Assert
        expect(feature1, isNot(equals(feature2)));
      });
    });
  });
}
