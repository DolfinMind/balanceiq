import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:dolfin_core/dolfin_core.dart';
import 'package:feature_subscription/domain/entities/plan.dart';
import 'package:feature_subscription/domain/entities/subscription.dart';
import 'package:feature_subscription/domain/entities/subscription_status.dart';
import 'package:feature_subscription/presentation/cubit/subscription_cubit.dart';
import 'package:feature_subscription/presentation/cubit/subscription_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  late SubscriptionCubit subscriptionCubit;
  late MockGetAllPlans mockGetAllPlans;
  late MockGetSubscriptionStatus mockGetSubscriptionStatus;
  late MockCreateSubscription mockCreateSubscription;
  late MockCancelSubscription mockCancelSubscription;
  late MockAnalyticsService mockAnalyticsService;

  setUp(() {
    mockGetAllPlans = MockGetAllPlans();
    mockGetSubscriptionStatus = MockGetSubscriptionStatus();
    mockCreateSubscription = MockCreateSubscription();
    mockCancelSubscription = MockCancelSubscription();
    mockAnalyticsService = MockAnalyticsService();

    when(() => mockAnalyticsService.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        )).thenAnswer((_) async {});

    subscriptionCubit = SubscriptionCubit(
      getAllPlansUseCase: mockGetAllPlans,
      getSubscriptionStatusUseCase: mockGetSubscriptionStatus,
      createSubscriptionUseCase: mockCreateSubscription,
      cancelSubscriptionUseCase: mockCancelSubscription,
      analyticsService: mockAnalyticsService,
    );
  });

  tearDown(() {
    subscriptionCubit.close();
  });

  group('SubscriptionCubit', () {
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

    const testPlans = [testPlan];

    final testSubscription = Subscription(
      userId: 1,
      plan: testPlan,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 2, 1),
      isActive: true,
      daysRemaining: 30,
    );

    final testSubscriptionStatus = SubscriptionStatus(
      hasActiveSubscription: true,
      subscription: testSubscription,
    );

    test('initial state is SubscriptionInitial', () {
      expect(subscriptionCubit.state, isA<SubscriptionInitial>());
    });

    group('loadPlans', () {
      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits [PlansLoading, PlansLoaded] when loadPlans succeeds',
        build: () {
          when(() => mockGetAllPlans())
              .thenAnswer((_) async => const Right(testPlans));
          return subscriptionCubit;
        },
        act: (cubit) => cubit.loadPlans(),
        expect: () => [
          isA<PlansLoading>(),
          isA<PlansLoaded>()
              .having((s) => s.plans, 'plans', testPlans)
              .having((s) => s.subscriptionStatus, 'subscriptionStatus', null),
        ],
        verify: (_) {
          verify(() => mockGetAllPlans()).called(1);
        },
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits [PlansLoading, SubscriptionError] when loadPlans fails',
        build: () {
          when(() => mockGetAllPlans()).thenAnswer(
            (_) async => const Left(ServerFailure('Failed to load plans')),
          );
          return subscriptionCubit;
        },
        act: (cubit) => cubit.loadPlans(),
        expect: () => [
          isA<PlansLoading>(),
          isA<SubscriptionError>()
              .having((s) => s.message, 'message', 'Failed to load plans'),
        ],
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits [PlansLoading, SubscriptionError] on network failure',
        build: () {
          when(() => mockGetAllPlans()).thenAnswer(
            (_) async => const Left(NetworkFailure('No internet')),
          );
          return subscriptionCubit;
        },
        act: (cubit) => cubit.loadPlans(),
        expect: () => [
          isA<PlansLoading>(),
          isA<SubscriptionError>()
              .having((s) => s.message, 'message', 'No internet'),
        ],
      );
    });

    group('loadPlansAndStatus', () {
      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits [PlansLoading, PlansLoaded with status] when both succeed',
        build: () {
          when(() => mockGetAllPlans())
              .thenAnswer((_) async => const Right(testPlans));
          when(() => mockGetSubscriptionStatus())
              .thenAnswer((_) async => Right(testSubscriptionStatus));
          return subscriptionCubit;
        },
        act: (cubit) => cubit.loadPlansAndStatus(),
        expect: () => [
          isA<PlansLoading>(),
          isA<PlansLoaded>().having((s) => s.plans, 'plans', testPlans).having(
              (s) => s.subscriptionStatus,
              'subscriptionStatus',
              testSubscriptionStatus),
        ],
        verify: (_) {
          verify(() => mockGetAllPlans()).called(1);
          verify(() => mockGetSubscriptionStatus()).called(1);
        },
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits [PlansLoading, PlansLoaded without status] when status fails',
        build: () {
          when(() => mockGetAllPlans())
              .thenAnswer((_) async => const Right(testPlans));
          when(() => mockGetSubscriptionStatus()).thenAnswer(
            (_) async => const Left(ServerFailure('Status fetch failed')),
          );
          return subscriptionCubit;
        },
        act: (cubit) => cubit.loadPlansAndStatus(),
        expect: () => [
          isA<PlansLoading>(),
          isA<PlansLoaded>()
              .having((s) => s.plans, 'plans', testPlans)
              .having((s) => s.subscriptionStatus, 'subscriptionStatus', null),
        ],
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits [PlansLoading, SubscriptionError] when plans fail',
        build: () {
          when(() => mockGetAllPlans()).thenAnswer(
            (_) async => const Left(ServerFailure('Plans fetch failed')),
          );
          return subscriptionCubit;
        },
        act: (cubit) => cubit.loadPlansAndStatus(),
        expect: () => [
          isA<PlansLoading>(),
          isA<SubscriptionError>()
              .having((s) => s.message, 'message', 'Plans fetch failed'),
        ],
      );
    });

    group('loadSubscriptionStatus', () {
      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits [SubscriptionStatusLoading, SubscriptionStatusLoaded] when succeeds',
        build: () {
          when(() => mockGetSubscriptionStatus())
              .thenAnswer((_) async => Right(testSubscriptionStatus));
          return subscriptionCubit;
        },
        act: (cubit) => cubit.loadSubscriptionStatus(),
        expect: () => [
          isA<SubscriptionStatusLoading>(),
          isA<SubscriptionStatusLoaded>()
              .having((s) => s.status, 'status', testSubscriptionStatus),
        ],
        verify: (_) {
          verify(() => mockGetSubscriptionStatus()).called(1);
        },
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits [SubscriptionStatusLoading, SubscriptionError] when fails',
        build: () {
          when(() => mockGetSubscriptionStatus()).thenAnswer(
            (_) async => const Left(AuthFailure('Unauthorized')),
          );
          return subscriptionCubit;
        },
        act: (cubit) => cubit.loadSubscriptionStatus(),
        expect: () => [
          isA<SubscriptionStatusLoading>(),
          isA<SubscriptionError>()
              .having((s) => s.message, 'message', 'Unauthorized'),
        ],
      );
    });

    group('createSubscription', () {
      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits [CreatingSubscription, SubscriptionCreated] when succeeds',
        build: () {
          when(() => mockCreateSubscription(
                planName: any(named: 'planName'),
                autoRenew: any(named: 'autoRenew'),
              )).thenAnswer((_) async => Right(testSubscription));
          return subscriptionCubit;
        },
        act: (cubit) => cubit.createSubscription(
          planName: 'PREMIUM',
          autoRenew: true,
        ),
        expect: () => [
          isA<CreatingSubscription>(),
          isA<SubscriptionCreated>()
              .having((s) => s.subscription, 'subscription', testSubscription),
        ],
        verify: (_) {
          verify(() => mockCreateSubscription(
                planName: 'PREMIUM',
                autoRenew: true,
              )).called(1);
        },
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits [CreatingSubscription, SubscriptionError] when fails',
        build: () {
          when(() => mockCreateSubscription(
                planName: any(named: 'planName'),
                autoRenew: any(named: 'autoRenew'),
              )).thenAnswer(
            (_) async => const Left(ServerFailure('Payment processing failed')),
          );
          return subscriptionCubit;
        },
        act: (cubit) => cubit.createSubscription(
          planName: 'PREMIUM',
          autoRenew: true,
        ),
        expect: () => [
          isA<CreatingSubscription>(),
          isA<SubscriptionError>()
              .having((s) => s.message, 'message', 'Payment processing failed'),
        ],
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'uses default autoRenew value of true',
        build: () {
          when(() => mockCreateSubscription(
                planName: any(named: 'planName'),
                autoRenew: any(named: 'autoRenew'),
              )).thenAnswer((_) async => Right(testSubscription));
          return subscriptionCubit;
        },
        act: (cubit) => cubit.createSubscription(planName: 'PREMIUM'),
        verify: (_) {
          verify(() => mockCreateSubscription(
                planName: 'PREMIUM',
                autoRenew: true,
              )).called(1);
        },
      );
    });

    group('reset', () {
      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits [SubscriptionInitial]',
        seed: () => const PlansLoaded(plans: testPlans),
        build: () => subscriptionCubit,
        act: (cubit) => cubit.reset(),
        expect: () => [isA<SubscriptionInitial>()],
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'resets from error state to initial',
        seed: () => const SubscriptionError('Some error'),
        build: () => subscriptionCubit,
        act: (cubit) => cubit.reset(),
        expect: () => [isA<SubscriptionInitial>()],
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'resets from SubscriptionCreated state to initial',
        seed: () => SubscriptionCreated(testSubscription),
        build: () => subscriptionCubit,
        act: (cubit) => cubit.reset(),
        expect: () => [isA<SubscriptionInitial>()],
      );
    });

    group('edge cases', () {
      // Empty plans list
      blocTest<SubscriptionCubit, SubscriptionState>(
        'handles empty plans list',
        build: () {
          when(() => mockGetAllPlans())
              .thenAnswer((_) async => const Right(<Plan>[]));
          return subscriptionCubit;
        },
        act: (cubit) => cubit.loadPlans(),
        expect: () => [
          isA<PlansLoading>(),
          isA<PlansLoaded>()
              .having((s) => s.plans, 'plans', isEmpty)
              .having((s) => s.subscriptionStatus, 'subscriptionStatus', null),
        ],
      );

      // Multiple plans
      blocTest<SubscriptionCubit, SubscriptionState>(
        'handles multiple plans',
        build: () {
          const freePlan = Plan(
            id: 0,
            name: 'FREE',
            displayName: 'Free Plan',
            description: 'Free tier',
            price: 0.0,
            billingCycle: 'MONTHLY',
            tier: 0,
            maxProjects: 1,
            maxStorageGb: 1,
            maxApiCallsPerMonth: 100,
            maxTeamMembers: 1,
            features: [],
            isActive: true,
            subscriptionStatus: 'ACTIVE',
          );
          const multiplePlans = [freePlan, testPlan];
          when(() => mockGetAllPlans())
              .thenAnswer((_) async => const Right(multiplePlans));
          return subscriptionCubit;
        },
        act: (cubit) => cubit.loadPlans(),
        expect: () => [
          isA<PlansLoading>(),
          isA<PlansLoaded>().having((s) => s.plans.length, 'plans length', 2),
        ],
      );

      // No active subscription
      blocTest<SubscriptionCubit, SubscriptionState>(
        'handles no active subscription status',
        build: () {
          const noActiveStatus = SubscriptionStatus(
            hasActiveSubscription: false,
            subscription: null,
          );
          when(() => mockGetSubscriptionStatus())
              .thenAnswer((_) async => const Right(noActiveStatus));
          return subscriptionCubit;
        },
        act: (cubit) => cubit.loadSubscriptionStatus(),
        expect: () => [
          isA<SubscriptionStatusLoading>(),
          isA<SubscriptionStatusLoaded>()
              .having((s) => s.status.hasActiveSubscription,
                  'hasActiveSubscription', false)
              .having((s) => s.status.subscription, 'subscription', null),
        ],
      );

      // createSubscription with autoRenew explicitly false
      blocTest<SubscriptionCubit, SubscriptionState>(
        'createSubscription with autoRenew false',
        build: () {
          when(() => mockCreateSubscription(
                planName: any(named: 'planName'),
                autoRenew: any(named: 'autoRenew'),
              )).thenAnswer((_) async => Right(testSubscription));
          return subscriptionCubit;
        },
        act: (cubit) => cubit.createSubscription(
          planName: 'PREMIUM',
          autoRenew: false,
        ),
        verify: (_) {
          verify(() => mockCreateSubscription(
                planName: 'PREMIUM',
                autoRenew: false,
              )).called(1);
        },
      );

      // Different failure types
      blocTest<SubscriptionCubit, SubscriptionState>(
        'handles CacheFailure on loadPlans',
        build: () {
          when(() => mockGetAllPlans()).thenAnswer(
            (_) async => const Left(CacheFailure('Cache error')),
          );
          return subscriptionCubit;
        },
        act: (cubit) => cubit.loadPlans(),
        expect: () => [
          isA<PlansLoading>(),
          isA<SubscriptionError>()
              .having((s) => s.message, 'message', 'Cache error'),
        ],
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'handles ValidationFailure on createSubscription',
        build: () {
          when(() => mockCreateSubscription(
                planName: any(named: 'planName'),
                autoRenew: any(named: 'autoRenew'),
              )).thenAnswer(
            (_) async => const Left(ValidationFailure('Invalid plan name')),
          );
          return subscriptionCubit;
        },
        act: (cubit) => cubit.createSubscription(planName: 'INVALID'),
        expect: () => [
          isA<CreatingSubscription>(),
          isA<SubscriptionError>()
              .having((s) => s.message, 'message', 'Invalid plan name'),
        ],
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'handles PermissionFailure on loadSubscriptionStatus',
        build: () {
          when(() => mockGetSubscriptionStatus()).thenAnswer(
            (_) async => const Left(PermissionFailure('Access denied')),
          );
          return subscriptionCubit;
        },
        act: (cubit) => cubit.loadSubscriptionStatus(),
        expect: () => [
          isA<SubscriptionStatusLoading>(),
          isA<SubscriptionError>()
              .having((s) => s.message, 'message', 'Access denied'),
        ],
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'handles NotFoundFailure on loadSubscriptionStatus',
        build: () {
          when(() => mockGetSubscriptionStatus()).thenAnswer(
            (_) async => const Left(NotFoundFailure('Subscription not found')),
          );
          return subscriptionCubit;
        },
        act: (cubit) => cubit.loadSubscriptionStatus(),
        expect: () => [
          isA<SubscriptionStatusLoading>(),
          isA<SubscriptionError>()
              .having((s) => s.message, 'message', 'Subscription not found'),
        ],
      );

      // loadPlansAndStatus with no active subscription
      blocTest<SubscriptionCubit, SubscriptionState>(
        'loadPlansAndStatus with no active subscription',
        build: () {
          const noActiveStatus = SubscriptionStatus(
            hasActiveSubscription: false,
            subscription: null,
          );
          when(() => mockGetAllPlans())
              .thenAnswer((_) async => const Right(testPlans));
          when(() => mockGetSubscriptionStatus())
              .thenAnswer((_) async => const Right(noActiveStatus));
          return subscriptionCubit;
        },
        act: (cubit) => cubit.loadPlansAndStatus(),
        expect: () => [
          isA<PlansLoading>(),
          isA<PlansLoaded>().having((s) => s.plans, 'plans', testPlans).having(
              (s) => s.subscriptionStatus?.hasActiveSubscription,
              'hasActiveSubscription',
              false),
        ],
      );

      // Network failure on loadPlansAndStatus
      blocTest<SubscriptionCubit, SubscriptionState>(
        'handles NetworkFailure on loadPlansAndStatus',
        build: () {
          when(() => mockGetAllPlans()).thenAnswer(
            (_) async => const Left(NetworkFailure('No internet connection')),
          );
          return subscriptionCubit;
        },
        act: (cubit) => cubit.loadPlansAndStatus(),
        expect: () => [
          isA<PlansLoading>(),
          isA<SubscriptionError>()
              .having((s) => s.message, 'message', 'No internet connection'),
        ],
      );

      // Network failure on createSubscription
      blocTest<SubscriptionCubit, SubscriptionState>(
        'handles NetworkFailure on createSubscription',
        build: () {
          when(() => mockCreateSubscription(
                planName: any(named: 'planName'),
                autoRenew: any(named: 'autoRenew'),
              )).thenAnswer(
            (_) async => const Left(NetworkFailure('Connection timeout')),
          );
          return subscriptionCubit;
        },
        act: (cubit) => cubit.createSubscription(planName: 'PREMIUM'),
        expect: () => [
          isA<CreatingSubscription>(),
          isA<SubscriptionError>()
              .having((s) => s.message, 'message', 'Connection timeout'),
        ],
      );
    });

    group('state equality', () {
      test('PlansLoaded states with same data are equal', () {
        const state1 = PlansLoaded(plans: testPlans);
        const state2 = PlansLoaded(plans: testPlans);
        expect(state1, equals(state2));
      });

      test('PlansLoaded states with different plans are not equal', () {
        const state1 = PlansLoaded(plans: testPlans);
        const state2 = PlansLoaded(plans: <Plan>[]);
        expect(state1, isNot(equals(state2)));
      });

      test('SubscriptionError states with same message are equal', () {
        const state1 = SubscriptionError('Error');
        const state2 = SubscriptionError('Error');
        expect(state1, equals(state2));
      });

      test('SubscriptionError states with different messages are not equal',
          () {
        const state1 = SubscriptionError('Error 1');
        const state2 = SubscriptionError('Error 2');
        expect(state1, isNot(equals(state2)));
      });

      test('SubscriptionCreated states with same subscription are equal', () {
        final state1 = SubscriptionCreated(testSubscription);
        final state2 = SubscriptionCreated(testSubscription);
        expect(state1, equals(state2));
      });

      test('SubscriptionStatusLoaded states with same status are equal', () {
        final state1 = SubscriptionStatusLoaded(testSubscriptionStatus);
        final state2 = SubscriptionStatusLoaded(testSubscriptionStatus);
        expect(state1, equals(state2));
      });
    });

    group('PlansLoaded copyWith', () {
      test('copyWith creates new instance with updated plans', () {
        const original = PlansLoaded(plans: testPlans);
        const newPlans = <Plan>[];
        final copied = original.copyWith(plans: newPlans);

        expect(copied.plans, equals(newPlans));
        expect(copied.subscriptionStatus, isNull);
      });

      test('copyWith creates new instance with updated subscriptionStatus', () {
        const original = PlansLoaded(plans: testPlans);
        final copied =
            original.copyWith(subscriptionStatus: testSubscriptionStatus);

        expect(copied.plans, equals(testPlans));
        expect(copied.subscriptionStatus, equals(testSubscriptionStatus));
      });

      test('copyWith preserves values when not specified', () {
        final original = PlansLoaded(
          plans: testPlans,
          subscriptionStatus: testSubscriptionStatus,
        );
        final copied = original.copyWith();

        expect(copied.plans, equals(testPlans));
        expect(copied.subscriptionStatus, equals(testSubscriptionStatus));
      });
    });

    group('Subscription entity properties', () {
      test('isExpired returns true when daysRemaining is 0', () {
        final expiredSubscription = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          isActive: false,
          daysRemaining: 0,
        );
        expect(expiredSubscription.isExpired, isTrue);
      });

      test('isExpired returns true when daysRemaining is negative', () {
        final expiredSubscription = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          isActive: false,
          daysRemaining: -5,
        );
        expect(expiredSubscription.isExpired, isTrue);
      });

      test('isExpired returns false when daysRemaining is positive', () {
        expect(testSubscription.isExpired, isFalse);
      });

      test('isExpiringSoon returns true when daysRemaining is 1-7', () {
        final expiringSoonSubscription = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 8),
          isActive: true,
          daysRemaining: 5,
        );
        expect(expiringSoonSubscription.isExpiringSoon, isTrue);
      });

      test('isExpiringSoon returns false when daysRemaining is more than 7',
          () {
        expect(testSubscription.isExpiringSoon, isFalse);
      });

      test('isExpiringSoon returns false when subscription is expired', () {
        final expiredSubscription = Subscription(
          userId: 1,
          plan: testPlan,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          isActive: false,
          daysRemaining: 0,
        );
        expect(expiredSubscription.isExpiringSoon, isFalse);
      });

      test('formattedEndDate returns correct format', () {
        expect(testSubscription.formattedEndDate, equals('February 1, 2024'));
      });
    });

    group('Plan entity properties', () {
      test('formattedPrice returns correct format', () {
        expect(testPlan.formattedPrice, equals('\$9.99'));
      });

      test('isMonthly returns true for MONTHLY billing cycle', () {
        expect(testPlan.isMonthly, isTrue);
      });

      test('isMonthly returns false for non-MONTHLY billing cycle', () {
        const yearlyPlan = Plan(
          id: 2,
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
        expect(yearlyPlan.isMonthly, isFalse);
      });

      test('isYearly returns true for YEARLY billing cycle', () {
        const yearlyPlan = Plan(
          id: 2,
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
        expect(yearlyPlan.isYearly, isTrue);
      });

      test('isYearly returns false for MONTHLY billing cycle', () {
        expect(testPlan.isYearly, isFalse);
      });
    });
  });
}
