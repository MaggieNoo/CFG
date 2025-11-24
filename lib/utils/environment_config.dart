import 'package:flutter/foundation.dart';

enum Environment {
  development, // Local XAMPP
  staging, // Cloud testing server
  production, // Live production server
  demo, // Mock/Demo mode for testing without backend
}

class EnvironmentConfig {
  // Default to production for release builds, development for debug builds
  static Environment _currentEnvironment =
      kReleaseMode ? Environment.production : Environment.development;

  // Toggle this to switch environments easily
  static Environment get currentEnvironment => _currentEnvironment;

  static void setEnvironment(Environment env) {
    _currentEnvironment = env;
  }

  // Base URLs for different environments
  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        // Local XAMPP server
        return 'http://192.168.8.46/mobile/';

      case Environment.staging:
        // TODO: Replace with your cloud server URL when deployed
        // Options: Railway.app, Render.com, InfinityFree.net (all free)
        return 'https://your-app.railway.app/mobile/';

      case Environment.production:
        // Your production server
        return 'https://v2.camaligfitnessgym.com/mobile/';

      case Environment.demo:
        // Demo mode - uses mock data, no actual server
        return 'demo://localhost/';
    }
  }

  static bool get isDemoMode => _currentEnvironment == Environment.demo;
  static bool get isProduction => _currentEnvironment == Environment.production;
  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;

  // Debug info
  static String get environmentName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'Development (Local XAMPP)';
      case Environment.staging:
        return 'Staging (Cloud Testing)';
      case Environment.production:
        return 'Production';
      case Environment.demo:
        return 'Demo Mode (No Server)';
    }
  }

  // For debugging in development builds
  static void printConfig() {
    if (kDebugMode) {
      print('=== Environment Configuration ===');
      print('Environment: $environmentName');
      print('Base URL: $baseUrl');
      print('Demo Mode: $isDemoMode');
      print('================================');
    }
  }
}
