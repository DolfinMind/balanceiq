class ApiEndpoints {
  static String _backendBaseUrl = 'http://localhost:8080';
  static String _authBaseUrl = 'http://localhost:8080/api/auth';
  static String _agentBaseUrl = 'http://localhost:8080/api/finance-guru';

  static void init({
    required String backendBaseUrl,
    required String authBaseUrl,
    required String agentBaseUrl,
  }) {
    _backendBaseUrl = backendBaseUrl;
    _authBaseUrl = authBaseUrl;
    _agentBaseUrl = agentBaseUrl;
  }

  static String get backendBaseUrl => _backendBaseUrl;
  static String get authBaseUrl => _authBaseUrl;
  static String get agentBaseUrl => _agentBaseUrl;

  // Authentication APIs
  static String get googleOAuth => '$backendBaseUrl/api/sso/google';
  static String get refreshToken => '$backendBaseUrl/api/sso/refresh-token';
  static String get getProfile =>
      '$authBaseUrl/profile'; // Keeping for now if needed, or remove? Prompt implied only new SSO endpoints. Assuming old auth API is gone.
  // Actually, the prompt says "Removed deprecated endpoints: /api/auth/signup, /api/auth/login, etc."
  // It doesn't explicitly replace /api/auth/profile. But the SSO login returns user info.
  // I will keep updateProfile and updateCurrency for now if they are not explicitly replaced, but point them to where?
  // The prompt "Kept web portal auth flexible for admins" suggests /api/auth might still exist for admins, but for mobile app we use SSO.
  // For safety, I will point updateProfile/Currency to the base URL if they are distinct, but likely they are under /api/auth or similar.
  // Let's assume /api/auth/profile persists for updates, or maybe we don't need it if we only sync from Google.
  // However, user might want to update currency.
  // I'll keep the specialized ones but remove the login/signup ones.

  static String get updateCurrency => '$authBaseUrl/currency';
  static String get updateProfile => '$authBaseUrl/profile';
  static String get logout => '$authBaseUrl/logout';

  // Finance Guru APIs
  static String get dashboard => '$agentBaseUrl/dashboard';
  static String get chat => '$agentBaseUrl/chat';
  static String get chatHistory => '$agentBaseUrl/chat-history';
  static String get transactions => '$agentBaseUrl/transactions';
  static String get messageUsage => '$agentBaseUrl/usage';

  // Chat feedback endpoint (requires message ID)
  static String chatFeedback(int messageId) =>
      '$agentBaseUrl/chat-history/$messageId/feedback';

  // Subscription APIs
  static String get subscriptionsBaseUrl => '$backendBaseUrl/api/subscriptions';
  static String get plansBaseUrl => '$backendBaseUrl/api/plans';

  static String get allPlans => plansBaseUrl;
  static String get subscriptionStatus => '$subscriptionsBaseUrl/status';
  static String get createSubscription => subscriptionsBaseUrl;
  static String get cancelSubscription => '$subscriptionsBaseUrl/cancel';
}
