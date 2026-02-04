// Request and response models for authentication API endpoints

/// Login API Response (SSO)
/// POST /api/sso/google
class LoginResponse {
  final bool success;
  final String message;
  final LoginData? data;

  LoginResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? LoginData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LoginData {
  final String accessToken;
  final String refreshToken;
  final UserInfo user;
  final String appCode;
  final bool isNewUser;

  LoginData({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.appCode,
    required this.isNewUser,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken:
          json['token'] as String? ?? json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      user: UserInfo(
        id: json['userId']?.toString() ?? json['user']?['id']?.toString() ?? '',
        email:
            json['email'] as String? ?? json['user']?['email'] as String? ?? '',
        fullName: json['fullName'] as String? ??
            json['user']?['fullName'] as String? ??
            '',
        avatarUrl: json['avatarUrl'] as String? ??
            json['user']?['avatarUrl'] as String?,
        authProvider: json['authProvider'] as String? ??
            json['user']?['authProvider'] as String?,
        currency:
            json['currency'] as String? ?? json['user']?['currency'] as String?,
        isEmailVerified: json['isEmailVerified'] as bool? ??
            json['user']?['isEmailVerified'] as bool? ??
            false,
      ),
      appCode: json['appCode'] as String? ??
          'FINANCE_GURU', // Default as it's missing in response
      isNewUser: json['isNewUser'] as bool? ?? false,
    );
  }
}

/// User profile information
class UserInfo {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String? authProvider;
  final String? currency;
  final bool isEmailVerified;

  UserInfo({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.authProvider,
    this.currency,
    this.isEmailVerified = false,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      authProvider: json['authProvider'] as String?,
      currency: json['currency'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'authProvider': authProvider,
      'currency': currency,
      'isEmailVerified': isEmailVerified,
    };
  }
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}

class RefreshTokenResponse {
  final bool success;
  final String message;
  final RefreshTokenData? data;

  RefreshTokenResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? RefreshTokenData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class RefreshTokenData {
  final String accessToken;
  final String refreshToken;

  RefreshTokenData({
    required this.accessToken,
    required this.refreshToken,
  });

  factory RefreshTokenData.fromJson(Map<String, dynamic> json) {
    return RefreshTokenData(
      accessToken:
          json['token'] as String? ?? json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }
}

/// Update Profile Request
/// PUT /api/auth/profile
class UpdateProfileRequest {
  final String? fullName;
  final String? email;
  final String? currency;

  UpdateProfileRequest({
    this.fullName,
    this.email,
    this.currency,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (fullName != null) data['fullName'] = fullName;
    if (email != null) data['email'] = email;
    if (currency != null) data['currency'] = currency;
    return data;
  }
}

/// Update Profile Response
/// PUT /api/auth/profile
class UpdateProfileResponse {
  final bool success;
  final String message;
  final UserInfo? data;

  UpdateProfileResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? UserInfo.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
