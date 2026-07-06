/// Application-wide constants used across the app.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Travel Planner';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your AI-Powered Travel Companion';

  // API Keys (mock - replace with real keys in production)
  static const String weatherApiKey = 'MOCK_WEATHER_API_KEY';
  static const String mapsApiKey = 'MOCK_MAPS_API_KEY';

  // Hive Box Names
  static const String tripsBox = 'trips_box';
  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String expensesBox = 'expenses_box';

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const Duration slowAnimation = Duration(milliseconds: 600);
  static const Duration splashDuration = Duration(seconds: 3);

  // UI Constants
  static const double cardRadius = 16.0;
  static const double buttonRadius = 14.0;
  static const double inputRadius = 12.0;
  static const double bottomSheetRadius = 24.0;
  static const double maxContentWidth = 600.0;

  // Budget Categories
  static const List<String> budgetCategories = [
    'Accommodation',
    'Transport',
    'Food & Dining',
    'Activities',
    'Shopping',
    'Miscellaneous',
  ];

  // Interest Tags
  static const List<String> interestTags = [
    '🍕 Food',
    '⚡ Adventure',
    '🏛️ Culture',
    '🎉 Nightlife',
    '🌿 Nature',
    '🛍️ Shopping',
    '📸 Photography',
    '🧘 Wellness',
    '🎨 Art',
    '🏖️ Beach',
    '⛰️ Mountains',
    '🏙️ Urban',
  ];

  // Mood Types
  static const List<String> moods = [
    'Relaxed 🌿',
    'Adventure ⚡',
    'Luxury 💎',
    'Social 🎉',
  ];
}
