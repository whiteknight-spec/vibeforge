import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'VibeForge'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Forge Your Best Self'**
  String get appTagline;

  /// No description provided for @greeting_morning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greeting_morning;

  /// No description provided for @greeting_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greeting_afternoon;

  /// No description provided for @greeting_evening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greeting_evening;

  /// No description provided for @greeting_night.
  ///
  /// In en, this message translates to:
  /// **'Hey night owl'**
  String get greeting_night;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_checklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get nav_checklist;

  /// No description provided for @nav_analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get nav_analytics;

  /// No description provided for @nav_ai.
  ///
  /// In en, this message translates to:
  /// **'AI Coach'**
  String get nav_ai;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @home_title.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get home_title;

  /// No description provided for @home_streak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get home_streak;

  /// No description provided for @home_todayProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get home_todayProgress;

  /// No description provided for @home_weeklyGoal.
  ///
  /// In en, this message translates to:
  /// **'Weekly Goal'**
  String get home_weeklyGoal;

  /// No description provided for @home_completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get home_completionRate;

  /// No description provided for @home_transformationPic.
  ///
  /// In en, this message translates to:
  /// **'Weekly Selfie'**
  String get home_transformationPic;

  /// No description provided for @home_takeSelfie.
  ///
  /// In en, this message translates to:
  /// **'Take your weekly transformation selfie'**
  String get home_takeSelfie;

  /// No description provided for @home_viewTimeline.
  ///
  /// In en, this message translates to:
  /// **'View Timeline'**
  String get home_viewTimeline;

  /// No description provided for @checklist_title.
  ///
  /// In en, this message translates to:
  /// **'Daily Checklist'**
  String get checklist_title;

  /// No description provided for @checklist_addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get checklist_addItem;

  /// No description provided for @checklist_editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get checklist_editItem;

  /// No description provided for @checklist_deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get checklist_deleteItem;

  /// No description provided for @checklist_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed!'**
  String get checklist_completed;

  /// No description provided for @checklist_allDone.
  ///
  /// In en, this message translates to:
  /// **'All tasks completed! 🔥'**
  String get checklist_allDone;

  /// No description provided for @checklist_itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get checklist_itemName;

  /// No description provided for @checklist_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get checklist_notes;

  /// No description provided for @checklist_addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get checklist_addPhoto;

  /// No description provided for @checklist_addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get checklist_addVideo;

  /// No description provided for @checklist_timeLogged.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get checklist_timeLogged;

  /// No description provided for @checklist_reorder.
  ///
  /// In en, this message translates to:
  /// **'Hold & drag to reorder'**
  String get checklist_reorder;

  /// No description provided for @checklist_empty.
  ///
  /// In en, this message translates to:
  /// **'No items yet. Tap + to add your first goal!'**
  String get checklist_empty;

  /// No description provided for @checklist_resetDay.
  ///
  /// In en, this message translates to:
  /// **'Reset Day'**
  String get checklist_resetDay;

  /// No description provided for @checklist_customItem.
  ///
  /// In en, this message translates to:
  /// **'Custom Item'**
  String get checklist_customItem;

  /// No description provided for @checklist_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get checklist_category;

  /// No description provided for @checklist_category_lifestyle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get checklist_category_lifestyle;

  /// No description provided for @checklist_category_diet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get checklist_category_diet;

  /// No description provided for @checklist_category_growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get checklist_category_growth;

  /// No description provided for @checklist_category_fitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get checklist_category_fitness;

  /// No description provided for @checklist_category_health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get checklist_category_health;

  /// No description provided for @checklist_category_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get checklist_category_custom;

  /// No description provided for @celebration_title.
  ///
  /// In en, this message translates to:
  /// **'Amazing! 🎉'**
  String get celebration_title;

  /// No description provided for @celebration_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You completed all your goals today!'**
  String get celebration_subtitle;

  /// No description provided for @celebration_streak.
  ///
  /// In en, this message translates to:
  /// **'{count} Day Streak!'**
  String celebration_streak(int count);

  /// No description provided for @analytics_title.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics_title;

  /// No description provided for @analytics_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get analytics_daily;

  /// No description provided for @analytics_weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get analytics_weekly;

  /// No description provided for @analytics_monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get analytics_monthly;

  /// No description provided for @analytics_completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get analytics_completionRate;

  /// No description provided for @analytics_streakCalendar.
  ///
  /// In en, this message translates to:
  /// **'Streak Calendar'**
  String get analytics_streakCalendar;

  /// No description provided for @analytics_weightProgress.
  ///
  /// In en, this message translates to:
  /// **'Weight Progress'**
  String get analytics_weightProgress;

  /// No description provided for @analytics_workoutConsistency.
  ///
  /// In en, this message translates to:
  /// **'Workout Consistency'**
  String get analytics_workoutConsistency;

  /// No description provided for @analytics_measurements.
  ///
  /// In en, this message translates to:
  /// **'Body Measurements'**
  String get analytics_measurements;

  /// No description provided for @analytics_waist.
  ///
  /// In en, this message translates to:
  /// **'Waist (cm)'**
  String get analytics_waist;

  /// No description provided for @analytics_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get analytics_weight;

  /// No description provided for @analytics_noData.
  ///
  /// In en, this message translates to:
  /// **'Start tracking to see your progress!'**
  String get analytics_noData;

  /// No description provided for @analytics_addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add Measurement'**
  String get analytics_addMeasurement;

  /// No description provided for @ai_title.
  ///
  /// In en, this message translates to:
  /// **'AI Coach'**
  String get ai_title;

  /// No description provided for @ai_motivation.
  ///
  /// In en, this message translates to:
  /// **'Daily Motivation'**
  String get ai_motivation;

  /// No description provided for @ai_workout.
  ///
  /// In en, this message translates to:
  /// **'Workout Suggestion'**
  String get ai_workout;

  /// No description provided for @ai_diet.
  ///
  /// In en, this message translates to:
  /// **'Diet Suggestion'**
  String get ai_diet;

  /// No description provided for @ai_photoAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Photo Analysis'**
  String get ai_photoAnalysis;

  /// No description provided for @ai_weeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get ai_weeklySummary;

  /// No description provided for @ai_voiceLog.
  ///
  /// In en, this message translates to:
  /// **'Voice Log'**
  String get ai_voiceLog;

  /// No description provided for @ai_voicePrompt.
  ///
  /// In en, this message translates to:
  /// **'Speak your activity...'**
  String get ai_voicePrompt;

  /// No description provided for @ai_disclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI estimation only — not medical advice'**
  String get ai_disclaimer;

  /// No description provided for @ai_generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get ai_generating;

  /// No description provided for @ai_error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t generate response. Try again later.'**
  String get ai_error;

  /// No description provided for @ai_disabled.
  ///
  /// In en, this message translates to:
  /// **'AI features are disabled. Enable in Settings.'**
  String get ai_disabled;

  /// No description provided for @ai_chatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about your fitness journey...'**
  String get ai_chatPlaceholder;

  /// No description provided for @ai_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get ai_send;

  /// No description provided for @media_takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get media_takePhoto;

  /// No description provided for @media_chooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get media_chooseGallery;

  /// No description provided for @media_recordVideo.
  ///
  /// In en, this message translates to:
  /// **'Record Video (30s max)'**
  String get media_recordVideo;

  /// No description provided for @media_uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get media_uploading;

  /// No description provided for @media_uploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Upload successful!'**
  String get media_uploadSuccess;

  /// No description provided for @media_uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Will retry when online.'**
  String get media_uploadFailed;

  /// No description provided for @media_encrypted.
  ///
  /// In en, this message translates to:
  /// **'Encrypted & Secure'**
  String get media_encrypted;

  /// No description provided for @media_front.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get media_front;

  /// No description provided for @media_side.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get media_side;

  /// No description provided for @media_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get media_back;

  /// No description provided for @transformation_title.
  ///
  /// In en, this message translates to:
  /// **'Transformation'**
  String get transformation_title;

  /// No description provided for @transformation_weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly Selfie'**
  String get transformation_weekly;

  /// No description provided for @transformation_timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get transformation_timeline;

  /// No description provided for @transformation_beforeAfter.
  ///
  /// In en, this message translates to:
  /// **'Before / After'**
  String get transformation_beforeAfter;

  /// No description provided for @transformation_takeNow.
  ///
  /// In en, this message translates to:
  /// **'Take Your Weekly Selfie'**
  String get transformation_takeNow;

  /// No description provided for @transformation_noPhotos.
  ///
  /// In en, this message translates to:
  /// **'Start your transformation journey with your first photo!'**
  String get transformation_noPhotos;

  /// No description provided for @recap_title.
  ///
  /// In en, this message translates to:
  /// **'Weekly Recap'**
  String get recap_title;

  /// No description provided for @recap_day.
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String recap_day(int number);

  /// No description provided for @recap_completed.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks completed'**
  String recap_completed(int count);

  /// No description provided for @recap_bestDay.
  ///
  /// In en, this message translates to:
  /// **'Best Day'**
  String get recap_bestDay;

  /// No description provided for @recap_totalStreak.
  ///
  /// In en, this message translates to:
  /// **'Total Streak'**
  String get recap_totalStreak;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settings_darkMode;

  /// No description provided for @settings_lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get settings_lightMode;

  /// No description provided for @settings_cloudBackup.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup'**
  String get settings_cloudBackup;

  /// No description provided for @settings_cloudBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Sync your data to Firebase (encrypted)'**
  String get settings_cloudBackupDesc;

  /// No description provided for @settings_aiFeatures.
  ///
  /// In en, this message translates to:
  /// **'AI Features'**
  String get settings_aiFeatures;

  /// No description provided for @settings_aiFeaturesDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable AI-powered suggestions and analysis'**
  String get settings_aiFeaturesDesc;

  /// No description provided for @settings_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacy;

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About VibeForge'**
  String get settings_about;

  /// No description provided for @settings_signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settings_signOut;

  /// No description provided for @settings_deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settings_deleteAccount;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settings_version(String version);

  /// No description provided for @privacy_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacy_title;

  /// No description provided for @privacy_photoPolicy.
  ///
  /// In en, this message translates to:
  /// **'Your photos never leave your device unless you explicitly enable cloud backup.'**
  String get privacy_photoPolicy;

  /// No description provided for @privacy_encryptionPolicy.
  ///
  /// In en, this message translates to:
  /// **'All media is encrypted with AES-256 on your device.'**
  String get privacy_encryptionPolicy;

  /// No description provided for @privacy_noThirdParty.
  ///
  /// In en, this message translates to:
  /// **'No third-party analytics track your personal photos or data.'**
  String get privacy_noThirdParty;

  /// No description provided for @privacy_firebasePolicy.
  ///
  /// In en, this message translates to:
  /// **'When cloud backup is enabled, only you can access your data through authenticated Firebase Storage.'**
  String get privacy_firebasePolicy;

  /// No description provided for @auth_signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get auth_signIn;

  /// No description provided for @auth_signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get auth_signingIn;

  /// No description provided for @auth_signInError.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please try again.'**
  String get auth_signInError;

  /// No description provided for @auth_signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get auth_signOut;

  /// No description provided for @auth_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to VibeForge'**
  String get auth_welcome;

  /// No description provided for @auth_tagline.
  ///
  /// In en, this message translates to:
  /// **'Your personal transformation journey starts here'**
  String get auth_tagline;

  /// No description provided for @onboarding_title1.
  ///
  /// In en, this message translates to:
  /// **'Track Your Habits'**
  String get onboarding_title1;

  /// No description provided for @onboarding_desc1.
  ///
  /// In en, this message translates to:
  /// **'Build consistency in diet, exercise, coding, and lifestyle with a beautiful daily checklist.'**
  String get onboarding_desc1;

  /// No description provided for @onboarding_title2.
  ///
  /// In en, this message translates to:
  /// **'See Your Progress'**
  String get onboarding_title2;

  /// No description provided for @onboarding_desc2.
  ///
  /// In en, this message translates to:
  /// **'Weekly selfies, charts, and streaks to visualize your transformation journey.'**
  String get onboarding_desc2;

  /// No description provided for @onboarding_title3.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Coaching'**
  String get onboarding_title3;

  /// No description provided for @onboarding_desc3.
  ///
  /// In en, this message translates to:
  /// **'Get personalized workout, diet, and motivation suggestions powered by AI.'**
  String get onboarding_desc3;

  /// No description provided for @onboarding_getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboarding_getStarted;

  /// No description provided for @onboarding_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_next;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get common_error;

  /// No description provided for @common_offline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Changes will sync when connected.'**
  String get common_offline;

  /// No description provided for @common_noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get common_noData;

  /// No description provided for @common_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get common_today;

  /// No description provided for @common_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get common_yesterday;

  /// No description provided for @common_thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get common_thisWeek;

  /// No description provided for @common_thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get common_thisMonth;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
