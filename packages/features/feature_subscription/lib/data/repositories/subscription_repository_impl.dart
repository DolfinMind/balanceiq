import 'package:dartz/dartz.dart';
import 'package:dolfin_core/error/failures.dart';
import '../../domain/entities/plan.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_datasource.dart';
import '../models/create_subscription_request.dart';
import '../models/plan_dto.dart';
import '../models/subscription_dto.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionDataSource remoteDataSource;

  SubscriptionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Plan>>> getAllPlans() async {
    try {
      final planDtos = await remoteDataSource.getAllPlans();
      final plans = planDtos.map(_mapPlanDtoToEntity).toList();
      return Right(plans);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, SubscriptionStatus>> getSubscriptionStatus() async {
    try {
      final statusDto = await remoteDataSource.getSubscriptionStatus();
      final status = SubscriptionStatus(
        hasActiveSubscription: statusDto.hasActiveSubscription,
        subscription: statusDto.subscription != null
            ? _mapSubscriptionDtoToEntity(statusDto.subscription!)
            : null,
      );
      return Right(status);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Subscription>> createSubscription({
    required String planName,
    required bool autoRenew,
  }) async {
    try {
      final request = CreateSubscriptionRequest(
        planName: planName,
        autoRenew: autoRenew,
      );
      final subscriptionDto =
          await remoteDataSource.createSubscription(request);
      final subscription = _mapSubscriptionDtoToEntity(subscriptionDto);
      return Right(subscription);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Subscription>> cancelSubscription({
    String? reason,
  }) async {
    try {
      final subscriptionDto =
          await remoteDataSource.cancelSubscription(reason: reason);
      final subscription = _mapSubscriptionDtoToEntity(subscriptionDto);
      return Right(subscription);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  Plan _mapPlanDtoToEntity(PlanDto dto) {
    return Plan(
      id: dto.id,
      name: dto.name,
      displayName: dto.displayName,
      description: dto.description,
      price: dto.price,
      billingCycle: dto.billingCycle,
      tier: dto.tier,
      maxProjects: dto.maxProjects,
      maxStorageGb: dto.maxStorageGb,
      maxApiCallsPerMonth: dto.maxApiCallsPerMonth,
      maxTeamMembers: dto.maxTeamMembers,
      features: dto.features
          .map((f) => Feature(
                id: f.id,
                code: f.code,
                name: f.name,
                description: f.description,
                category: f.category,
                requiresPermission: f.requiresPermission,
                isActive: f.isActive,
              ))
          .toList(),
      isActive: dto.isActive,
      subscriptionStatus: dto.subscriptionStatus,
    );
  }

  Subscription _mapSubscriptionDtoToEntity(SubscriptionDto dto) {
    return Subscription(
      userId: dto.userId,
      plan: dto.plan != null ? _mapPlanDtoToEntity(dto.plan!) : null,
      startDate: dto.startDate,
      endDate: dto.endDate,
      isActive: dto.isActive,
      daysRemaining: dto.daysRemaining,
    );
  }

  Failure _mapErrorToFailure(dynamic e) {
    final errorMessage = e.toString();

    if (errorMessage.contains('Authentication required') ||
        errorMessage.contains('Unauthorized')) {
      return const AuthFailure('Please login to access subscription features');
    } else if (errorMessage.contains('No internet') ||
        errorMessage.contains('Connection') ||
        errorMessage.contains('Network error')) {
      return const NetworkFailure(
          'No internet connection. Please check your network.');
    } else if (errorMessage.contains('timeout')) {
      return const ServerFailure('Request timed out. Please try again.');
    } else if (errorMessage.contains('Conflict') ||
        errorMessage.contains('already exists')) {
      return const ServerFailure('Active subscription already exists.');
    } else if (errorMessage.contains('not found') ||
        errorMessage.contains('Resource not found')) {
      return const NotFoundFailure('Subscription or plan not found.');
    } else if (errorMessage.contains('Access denied') ||
        errorMessage.contains('permission')) {
      return const PermissionFailure(
          'You do not have permission for this action.');
    } else {
      return ServerFailure('Failed: $errorMessage');
    }
  }
}
