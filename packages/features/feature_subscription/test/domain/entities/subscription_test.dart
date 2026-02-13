import 'package:feature_subscription/domain/entities/subscription.dart';
import 'package:feature_subscription/domain/entities/plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Subscription Entity', () {
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

    group('isExpired', () {
      test('should return true when daysRemaining is 0', () {
        // Arrange
        final subscription = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 2, 1),
          isActive: false,
          daysRemaining: 0,
        );

        // Act & Assert
        expect(subscription.isExpired, true);
      });

      test('should return true when daysRemaining is negative', () {
        // Arrange
        final subscription = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 2, 1),
          isActive: false,
          daysRemaining: -5,
        );

        // Act & Assert
        expect(subscription.isExpired, true);
      });

      test('should return false when daysRemaining is positive', () {
        // Arrange
        final subscription = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 2, 1),
          isActive: true,
          daysRemaining: 15,
        );

        // Act & Assert
        expect(subscription.isExpired, false);
      });
    });

    group('isExpiringSoon', () {
      test('should return true when daysRemaining is 1', () {
        // Arrange
        final subscription = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 2, 1),
          isActive: true,
          daysRemaining: 1,
        );

        // Act & Assert
        expect(subscription.isExpiringSoon, true);
      });

      test('should return true when daysRemaining is 7', () {
        // Arrange
        final subscription = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 2, 1),
          isActive: true,
          daysRemaining: 7,
        );

        // Act & Assert
        expect(subscription.isExpiringSoon, true);
      });

      test('should return false when daysRemaining is 0', () {
        // Arrange
        final subscription = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 2, 1),
          isActive: false,
          daysRemaining: 0,
        );

        // Act & Assert
        expect(subscription.isExpiringSoon, false);
      });

      test('should return false when daysRemaining is 8', () {
        // Arrange
        final subscription = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 2, 1),
          isActive: true,
          daysRemaining: 8,
        );

        // Act & Assert
        expect(subscription.isExpiringSoon, false);
      });

      test('should return false when daysRemaining is 30', () {
        // Arrange
        final subscription = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 2, 1),
          isActive: true,
          daysRemaining: 30,
        );

        // Act & Assert
        expect(subscription.isExpiringSoon, false);
      });
    });

    group('formattedEndDate', () {
      test('should format date correctly for January', () {
        // Arrange
        final subscription = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 15),
          isActive: true,
          daysRemaining: 15,
        );

        // Act & Assert
        expect(subscription.formattedEndDate, 'January 15, 2024');
      });

      test('should format date correctly for December', () {
        // Arrange
        final subscription = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 11, 1),
          endDate: DateTime(2024, 12, 31),
          isActive: true,
          daysRemaining: 60,
        );

        // Act & Assert
        expect(subscription.formattedEndDate, 'December 31, 2024');
      });

      test('should format date correctly for different years', () {
        // Arrange
        final subscription = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 12, 1),
          endDate: DateTime(2025, 3, 15),
          isActive: true,
          daysRemaining: 90,
        );

        // Act & Assert
        expect(subscription.formattedEndDate, 'March 15, 2025');
      });
    });

    group('Equatable', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        final subscription1 = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 2, 1),
          isActive: true,
          daysRemaining: 31,
        );

        final subscription2 = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 2, 1),
          isActive: true,
          daysRemaining: 31,
        );

        // Act & Assert
        expect(subscription1, equals(subscription2));
        expect(subscription1.hashCode, equals(subscription2.hashCode));
      });

      test('should not be equal when userId differs', () {
        // Arrange
        final subscription1 = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 2, 1),
          isActive: true,
          daysRemaining: 31,
        );

        final subscription2 = Subscription(
          userId: 2,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 2, 1),
          isActive: true,
          daysRemaining: 31,
        );

        // Act & Assert
        expect(subscription1, isNot(equals(subscription2)));
      });

      test('should not be equal when daysRemaining differs', () {
        // Arrange
        final subscription1 = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 2, 1),
          isActive: true,
          daysRemaining: 31,
        );

        final subscription2 = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 2, 1),
          isActive: true,
          daysRemaining: 15,
        );

        // Act & Assert
        expect(subscription1, isNot(equals(subscription2)));
      });
    });
  });
}
