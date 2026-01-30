import 'package:equatable/equatable.dart';

/// Feature entity representing a plan feature
class Feature extends Equatable {
  final int id;
  final String code;
  final String name;
  final String description;
  final String category;
  final bool requiresPermission;
  final bool isActive;

  const Feature({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.category,
    required this.requiresPermission,
    required this.isActive,
  });

  @override
  List<Object?> get props =>
      [id, code, name, description, category, requiresPermission, isActive];
}

/// Subscription Plan entity
class Plan extends Equatable {
  final int id;
  final String name;
  final String displayName;
  final String description;
  final double price;
  final String billingCycle;
  final int tier;
  final int maxProjects;
  final int maxStorageGb;
  final int maxApiCallsPerMonth;
  final int maxTeamMembers;
  final List<Feature> features;
  final bool isActive;
  final String subscriptionStatus;

  const Plan({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.price,
    required this.billingCycle,
    required this.tier,
    required this.maxProjects,
    required this.maxStorageGb,
    required this.maxApiCallsPerMonth,
    required this.maxTeamMembers,
    required this.features,
    required this.isActive,
    required this.subscriptionStatus,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        displayName,
        description,
        price,
        billingCycle,
        tier,
        maxProjects,
        maxStorageGb,
        maxApiCallsPerMonth,
        maxTeamMembers,
        features,
        isActive,
        subscriptionStatus,
      ];

  /// Format price with currency symbol
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  /// Check if plan is monthly
  bool get isMonthly => billingCycle == 'MONTHLY';

  /// Check if plan is yearly
  bool get isYearly => billingCycle == 'YEARLY';

  /// Check if plan is coming soon
  bool get isComingSoon => subscriptionStatus == 'COMING_SOON';
}
