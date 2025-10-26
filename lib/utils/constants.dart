import 'package:flutter/material.dart';
import 'environment_config.dart';

class AppConstants {
  // API Configuration
  // Dynamic baseUrl based on environment
  // Change environment in environment_config.dart
  static String get baseUrl => EnvironmentConfig.baseUrl;
  static const String apiToken = '_jE@20RIC!25\$\$';

  // For cloud testing platforms (Appetize.io, BrowserStack, etc.)
  // Set Environment.demo in environment_config.dart to use mock data
  static bool get isDemoMode => EnvironmentConfig.isDemoMode;

  // API Endpoints
  static const String loginEndpoint = 'app.login.php';
  static const String registrationEndpoint = 'app.registration.php';
  static const String dashboardEndpoint = 'pages/model/m.dashboard.php';
  static const String dtrEndpoint = 'pages/model/m.dtr.php';
  static const String enrollEndpoint = 'pages/model/m.enroll.php';
  static const String notificationEndpoint = 'pages/model/m.notification.php';
  static const String attendanceEndpoint = 'pages/model/m.attendance.php';

  // App Colors (Gym Theme)
  static const Color primaryColor = Color(0xFF1E3A8A); // Deep Blue
  static const Color accentColor = Color(0xFFEF4444); // Red
  static const Color backgroundColor = Color(0xFFF3F4F6);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  // Shared Preferences Keys
  static const String keyToken = 'user_token';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';
  static const String keyRememberMe = 'remember_me';
  static const String keySavedUsername = 'saved_username';
}
