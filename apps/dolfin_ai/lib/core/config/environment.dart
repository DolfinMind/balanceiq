enum AppEnvironment { dev, staging, prod }

class EnvironmentConfig {
  static const appEnv = String.fromEnvironment('ENV', defaultValue: 'dev');

  static AppEnvironment get currentEnv {
    switch (appEnv) {
      case 'staging':
        return AppEnvironment.staging;
      case 'prod':
        return AppEnvironment.prod;
      default:
        return AppEnvironment.dev;
    }
  }

  static String get fileName {
    switch (currentEnv) {
      case AppEnvironment.staging:
        return ".env.staging";
      case AppEnvironment.prod:
        return ".env.prod";
      default:
        return ".env";
    }
  }

  static bool get isStaging => currentEnv == AppEnvironment.staging;
  static bool get isProd => currentEnv == AppEnvironment.prod;
  static bool get isDev => currentEnv == AppEnvironment.dev;
}
