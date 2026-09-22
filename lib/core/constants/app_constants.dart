/// VibeForge app-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'VibeForge';
  static const String appVersion = '1.0.0';

  /// Default checklist items seeded on first launch.
  static const List<Map<String, String>> defaultChecklistItems = [
    {'id': 'wake_up', 'title': 'Wake Up Early', 'titleTa': 'சீக்கிரம் எழுந்திரு', 'icon': '🌅', 'category': 'lifestyle'},
    {'id': 'breakfast', 'title': 'High-Protein Breakfast', 'titleTa': 'உயர் புரத காலை உணவு', 'icon': '🥚', 'category': 'diet'},
    {'id': 'study', 'title': 'Study / Coding', 'titleTa': 'படிப்பு / கோடிங்', 'icon': '💻', 'category': 'growth'},
    {'id': 'exercise', 'title': 'Exercise', 'titleTa': 'உடற்பயிற்சி', 'icon': '💪', 'category': 'fitness'},
    {'id': 'lunch', 'title': 'Healthy Lunch', 'titleTa': 'ஆரோக்கிய மதிய உணவு', 'icon': '🥗', 'category': 'diet'},
    {'id': 'walk', 'title': 'Walk / Steps', 'titleTa': 'நடை / அடிகள்', 'icon': '🚶', 'category': 'fitness'},
    {'id': 'water', 'title': 'Drink Water (3L+)', 'titleTa': 'தண்ணீர் குடி (3 லிட்டர்+)', 'icon': '💧', 'category': 'health'},
    {'id': 'dinner', 'title': 'Light Dinner', 'titleTa': 'லேசான இரவு உணவு', 'icon': '🍽️', 'category': 'diet'},
    {'id': 'sleep', 'title': 'Sleep by 11 PM', 'titleTa': '11 மணிக்கு தூக்கம்', 'icon': '😴', 'category': 'lifestyle'},
  ];

  static const List<int> streakMilestones = [3, 7, 14, 21, 30, 50, 75, 100, 150, 200, 365];

  // Hive box names
  static const String hiveChecklistBox = 'checklist_box';
  static const String hiveDailyLogBox = 'daily_log_box';
  static const String hiveSettingsBox = 'settings_box';
  static const String hiveUserBox = 'user_box';
  static const String hiveAnalyticsBox = 'analytics_box';
  static const String hiveProgressPhotosBox = 'progress_photos_box';

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
}
