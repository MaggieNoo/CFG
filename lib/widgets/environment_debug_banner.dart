import 'package:flutter/material.dart';
import '../utils/environment_config.dart';

/// Debug banner that shows current environment configuration
/// Only visible in debug mode
class EnvironmentDebugBanner extends StatelessWidget {
  const EnvironmentDebugBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!const bool.fromEnvironment('dart.vm.product')) {
      return Positioned(
        top: 50,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: _getEnvironmentColor().withOpacity(0.9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${EnvironmentConfig.environmentName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'URL: ${EnvironmentConfig.baseUrl}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Color _getEnvironmentColor() {
    switch (EnvironmentConfig.currentEnvironment) {
      case Environment.development:
        return Colors.orange;
      case Environment.staging:
        return Colors.blue;
      case Environment.production:
        return Colors.green;
      case Environment.demo:
        return Colors.purple;
    }
  }
}
