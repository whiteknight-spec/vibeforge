// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'VibeForge';

  @override
  String get appTagline => 'Forge Your Best Self';

  @override
  String get greeting_morning => 'Good morning';

  @override
  String get greeting_afternoon => 'Good afternoon';

  @override
  String get greeting_evening => 'Good evening';

  @override
  String get greeting_night => 'Hey night owl';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_checklist => 'Checklist';

  @override
  String get nav_analytics => 'Analytics';

  @override
  String get nav_ai => 'AI Coach';

  @override
  String get nav_settings => 'Settings';

  @override
  String get home_title => 'Dashboard';

  @override
  String get home_streak => 'Day Streak';

  @override
  String get home_todayProgress => 'Today\'s Progress';

  @override
  String get home_weeklyGoal => 'Weekly Goal';

  @override
  String get home_completionRate => 'Completion Rate';

  @override
  String get home_transformationPic => 'Weekly Selfie';

  @override
  String get home_takeSelfie => 'Take your weekly transformation selfie';

  @override
  String get home_viewTimeline => 'View Timeline';

  @override
  String get checklist_title => 'Daily Checklist';

  @override
  String get checklist_addItem => 'Add Item';

  @override
  String get checklist_editItem => 'Edit Item';

  @override
  String get checklist_deleteItem => 'Delete Item';

  @override
  String get checklist_completed => 'Completed!';

  @override
  String get checklist_allDone => 'All tasks completed! 🔥';

  @override
  String get checklist_itemName => 'Item Name';

  @override
  String get checklist_notes => 'Notes';

  @override
  String get checklist_addPhoto => 'Add Photo';

  @override
  String get checklist_addVideo => 'Add Video';

  @override
  String get checklist_timeLogged => 'Time';

  @override
  String get checklist_reorder => 'Hold & drag to reorder';

  @override
  String get checklist_empty => 'No items yet. Tap + to add your first goal!';

  @override
  String get checklist_resetDay => 'Reset Day';

  @override
  String get checklist_customItem => 'Custom Item';

  @override
  String get checklist_category => 'Category';

  @override
  String get checklist_category_lifestyle => 'Lifestyle';

  @override
  String get checklist_category_diet => 'Diet';

  @override
  String get checklist_category_growth => 'Growth';

  @override
  String get checklist_category_fitness => 'Fitness';

  @override
  String get checklist_category_health => 'Health';

  @override
  String get checklist_category_custom => 'Custom';

  @override
  String get celebration_title => 'Amazing! 🎉';

  @override
  String get celebration_subtitle => 'You completed all your goals today!';

  @override
  String celebration_streak(int count) {
    return '$count Day Streak!';
  }

  @override
  String get analytics_title => 'Analytics';

  @override
  String get analytics_daily => 'Daily';

  @override
  String get analytics_weekly => 'Weekly';

  @override
  String get analytics_monthly => 'Monthly';

  @override
  String get analytics_completionRate => 'Completion Rate';

  @override
  String get analytics_streakCalendar => 'Streak Calendar';

  @override
  String get analytics_weightProgress => 'Weight Progress';

  @override
  String get analytics_workoutConsistency => 'Workout Consistency';

  @override
  String get analytics_measurements => 'Body Measurements';

  @override
  String get analytics_waist => 'Waist (cm)';

  @override
  String get analytics_weight => 'Weight (kg)';

  @override
  String get analytics_noData => 'Start tracking to see your progress!';

  @override
  String get analytics_addMeasurement => 'Add Measurement';

  @override
  String get ai_title => 'AI Coach';

  @override
  String get ai_motivation => 'Daily Motivation';

  @override
  String get ai_workout => 'Workout Suggestion';

  @override
  String get ai_diet => 'Diet Suggestion';

  @override
  String get ai_photoAnalysis => 'Photo Analysis';

  @override
  String get ai_weeklySummary => 'Weekly Summary';

  @override
  String get ai_voiceLog => 'Voice Log';

  @override
  String get ai_voicePrompt => 'Speak your activity...';

  @override
  String get ai_disclaimer => 'AI estimation only — not medical advice';

  @override
  String get ai_generating => 'Generating...';

  @override
  String get ai_error => 'Couldn\'t generate response. Try again later.';

  @override
  String get ai_disabled => 'AI features are disabled. Enable in Settings.';

  @override
  String get ai_chatPlaceholder =>
      'Ask me anything about your fitness journey...';

  @override
  String get ai_send => 'Send';

  @override
  String get media_takePhoto => 'Take Photo';

  @override
  String get media_chooseGallery => 'Choose from Gallery';

  @override
  String get media_recordVideo => 'Record Video (30s max)';

  @override
  String get media_uploading => 'Uploading...';

  @override
  String get media_uploadSuccess => 'Upload successful!';

  @override
  String get media_uploadFailed => 'Upload failed. Will retry when online.';

  @override
  String get media_encrypted => 'Encrypted & Secure';

  @override
  String get media_front => 'Front';

  @override
  String get media_side => 'Side';

  @override
  String get media_back => 'Back';

  @override
  String get transformation_title => 'Transformation';

  @override
  String get transformation_weekly => 'Weekly Selfie';

  @override
  String get transformation_timeline => 'Timeline';

  @override
  String get transformation_beforeAfter => 'Before / After';

  @override
  String get transformation_takeNow => 'Take Your Weekly Selfie';

  @override
  String get transformation_noPhotos =>
      'Start your transformation journey with your first photo!';

  @override
  String get recap_title => 'Weekly Recap';

  @override
  String recap_day(int number) {
    return 'Day $number';
  }

  @override
  String recap_completed(int count) {
    return '$count tasks completed';
  }

  @override
  String get recap_bestDay => 'Best Day';

  @override
  String get recap_totalStreak => 'Total Streak';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_darkMode => 'Dark Mode';

  @override
  String get settings_lightMode => 'Light Mode';

  @override
  String get settings_cloudBackup => 'Cloud Backup';

  @override
  String get settings_cloudBackupDesc =>
      'Sync your data to Firebase (encrypted)';

  @override
  String get settings_aiFeatures => 'AI Features';

  @override
  String get settings_aiFeaturesDesc =>
      'Enable AI-powered suggestions and analysis';

  @override
  String get settings_privacy => 'Privacy Policy';

  @override
  String get settings_about => 'About VibeForge';

  @override
  String get settings_signOut => 'Sign Out';

  @override
  String get settings_deleteAccount => 'Delete Account';

  @override
  String settings_version(String version) {
    return 'Version $version';
  }

  @override
  String get privacy_title => 'Privacy & Security';

  @override
  String get privacy_photoPolicy =>
      'Your photos never leave your device unless you explicitly enable cloud backup.';

  @override
  String get privacy_encryptionPolicy =>
      'All media is encrypted with AES-256 on your device.';

  @override
  String get privacy_noThirdParty =>
      'No third-party analytics track your personal photos or data.';

  @override
  String get privacy_firebasePolicy =>
      'When cloud backup is enabled, only you can access your data through authenticated Firebase Storage.';

  @override
  String get auth_signIn => 'Sign in with Google';

  @override
  String get auth_signingIn => 'Signing in...';

  @override
  String get auth_signInError => 'Sign in failed. Please try again.';

  @override
  String get auth_signOut => 'Sign Out';

  @override
  String get auth_welcome => 'Welcome to VibeForge';

  @override
  String get auth_tagline => 'Your personal transformation journey starts here';

  @override
  String get onboarding_title1 => 'Track Your Habits';

  @override
  String get onboarding_desc1 =>
      'Build consistency in diet, exercise, coding, and lifestyle with a beautiful daily checklist.';

  @override
  String get onboarding_title2 => 'See Your Progress';

  @override
  String get onboarding_desc2 =>
      'Weekly selfies, charts, and streaks to visualize your transformation journey.';

  @override
  String get onboarding_title3 => 'AI-Powered Coaching';

  @override
  String get onboarding_desc3 =>
      'Get personalized workout, diet, and motivation suggestions powered by AI.';

  @override
  String get onboarding_getStarted => 'Get Started';

  @override
  String get onboarding_next => 'Next';

  @override
  String get onboarding_skip => 'Skip';

  @override
  String get common_save => 'Save';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_done => 'Done';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'Something went wrong';

  @override
  String get common_offline =>
      'You\'re offline. Changes will sync when connected.';

  @override
  String get common_noData => 'No data available';

  @override
  String get common_today => 'Today';

  @override
  String get common_yesterday => 'Yesterday';

  @override
  String get common_thisWeek => 'This Week';

  @override
  String get common_thisMonth => 'This Month';
}
