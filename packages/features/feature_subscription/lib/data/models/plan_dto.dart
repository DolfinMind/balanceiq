/// Feature DTO for API response
class FeatureDto {
  final int id;
  final String code;
  final String name;
  final String description;
  final String category;
  final bool requiresPermission;
  final bool isActive;

  FeatureDto({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.category,
    required this.requiresPermission,
    required this.isActive,
  });

  factory FeatureDto.fromJson(Map<String, dynamic> json) {
    return FeatureDto(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      requiresPermission: json['requiresPermission'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

/// Plan DTO for API response
/// Maps to: GET /api/plans
class PlanDto {
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
  final List<FeatureDto> features;
  final bool isActive;
  final String subscriptionStatus;

  PlanDto({
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

  factory PlanDto.fromJson(Map<String, dynamic> json) {
    return PlanDto(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      billingCycle: json['billingCycle'] as String? ?? 'MONTHLY',
      tier: json['tier'] as int? ?? 0,
      maxProjects: json['maxProjects'] as int? ?? 0,
      maxStorageGb: json['maxStorageGb'] as int? ?? 0,
      maxApiCallsPerMonth: json['maxApiCallsPerMonth'] as int? ?? 0,
      maxTeamMembers: json['maxTeamMembers'] as int? ?? 0,
      features: (json['features'] as List<dynamic>?)
              ?.map((f) => FeatureDto.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? true,
      subscriptionStatus: json['subscriptionStatus'] as String? ?? 'ACTIVE',
    );
  }
}
