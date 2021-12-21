import 'package:flutter_scaffold/enums/theme_mode.dart';

class AppSettings {
  final String language;
  final bool unitIsMetric;
  final ScaffoldThemeMode scaffoldThemeMode;
  // final String batterySavings;
  // final String privacy;
  // final String private;
  Map<String, dynamic> notification;
  // final String emailNotification;
  // final String notificationRadius;

  AppSettings({
    this.language,
    this.unitIsMetric,
    this.scaffoldThemeMode,
    // this.batterySavings,
    // this.privacy,
    // this.private,
    this.notification,
    // this.emailNotification,
    // this.notificationRadius,
  });
}

class DefaultSettings {
  Map<String, bool> defaultSettings = {
    'rumored_florist': true,
    'confirmed_florist': true,
    'cleared_florist': true,
    'rumored_traffic': false,
    'confirmed_traffic': false,
    'cleared_traffic': false,
    'rumored_crash': false,
    'confirmed_crash': false,
    'cleared_crash': false,
    'rumored_hotel': true,
    'confirmed_hotel': true,
    'cleared_hotel': true,
    'rumored_hazard': false,
    'confirmed_hazard': false,
    'cleared_hazard': false,
    'rumored_library': false,
    'confirmed_library': false,
    'cleared_library': false,
    'all': true,
  };
}
