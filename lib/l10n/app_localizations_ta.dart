// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'வைப்ஃபோர்ஜ்';

  @override
  String get appTagline => 'உங்கள் சிறந்த பதிப்பை உருவாக்குங்கள்';

  @override
  String get greeting_morning => 'காலை வணக்கம்';

  @override
  String get greeting_afternoon => 'மதிய வணக்கம்';

  @override
  String get greeting_evening => 'மாலை வணக்கம்';

  @override
  String get greeting_night => 'இரவு வணக்கம்';

  @override
  String get nav_home => 'முகப்பு';

  @override
  String get nav_checklist => 'பட்டியல்';

  @override
  String get nav_analytics => 'பகுப்பாய்வு';

  @override
  String get nav_ai => 'AI பயிற்சியாளர்';

  @override
  String get nav_settings => 'அமைப்புகள்';

  @override
  String get home_title => 'டாஷ்போர்டு';

  @override
  String get home_streak => 'நாள் தொடர்';

  @override
  String get home_todayProgress => 'இன்றைய முன்னேற்றம்';

  @override
  String get home_weeklyGoal => 'வாராந்திர இலக்கு';

  @override
  String get home_completionRate => 'நிறைவு விகிதம்';

  @override
  String get home_transformationPic => 'வாராந்திர செல்ஃபி';

  @override
  String get home_takeSelfie => 'உங்கள் வாராந்திர மாற்ற செல்ஃபி எடுங்கள்';

  @override
  String get home_viewTimeline => 'காலவரிசையைப் பார்';

  @override
  String get checklist_title => 'தினசரி பட்டியல்';

  @override
  String get checklist_addItem => 'உருப்படி சேர்';

  @override
  String get checklist_editItem => 'உருப்படி திருத்து';

  @override
  String get checklist_deleteItem => 'உருப்படி நீக்கு';

  @override
  String get checklist_completed => 'நிறைவு!';

  @override
  String get checklist_allDone => 'அனைத்து பணிகளும் முடிந்தன! 🔥';

  @override
  String get checklist_itemName => 'உருப்படி பெயர்';

  @override
  String get checklist_notes => 'குறிப்புகள்';

  @override
  String get checklist_addPhoto => 'புகைப்படம் சேர்';

  @override
  String get checklist_addVideo => 'வீடியோ சேர்';

  @override
  String get checklist_timeLogged => 'நேரம்';

  @override
  String get checklist_reorder => 'இழுத்து வரிசைப்படுத்துங்கள்';

  @override
  String get checklist_empty =>
      'இன்னும் உருப்படிகள் இல்லை. + தட்டி உங்கள் முதல் இலக்கை சேருங்கள்!';

  @override
  String get checklist_resetDay => 'நாளை மீட்டமை';

  @override
  String get checklist_customItem => 'தனிப்பயன் உருப்படி';

  @override
  String get checklist_category => 'வகை';

  @override
  String get checklist_category_lifestyle => 'வாழ்க்கை முறை';

  @override
  String get checklist_category_diet => 'உணவு';

  @override
  String get checklist_category_growth => 'வளர்ச்சி';

  @override
  String get checklist_category_fitness => 'உடற்தகுதி';

  @override
  String get checklist_category_health => 'ஆரோக்கியம்';

  @override
  String get checklist_category_custom => 'தனிப்பயன்';

  @override
  String get celebration_title => 'அருமை! 🎉';

  @override
  String get celebration_subtitle =>
      'இன்று உங்கள் அனைத்து இலக்குகளையும் நிறைவேற்றினீர்கள்!';

  @override
  String celebration_streak(int count) {
    return '$count நாள் தொடர்!';
  }

  @override
  String get analytics_title => 'பகுப்பாய்வு';

  @override
  String get analytics_daily => 'தினசரி';

  @override
  String get analytics_weekly => 'வாராந்திர';

  @override
  String get analytics_monthly => 'மாதாந்திர';

  @override
  String get analytics_completionRate => 'நிறைவு விகிதம்';

  @override
  String get analytics_streakCalendar => 'தொடர் நாட்காட்டி';

  @override
  String get analytics_weightProgress => 'எடை முன்னேற்றம்';

  @override
  String get analytics_workoutConsistency => 'பயிற்சி நிலைத்தன்மை';

  @override
  String get analytics_measurements => 'உடல் அளவீடுகள்';

  @override
  String get analytics_waist => 'இடுப்பு (செ.மீ)';

  @override
  String get analytics_weight => 'எடை (கி.கி)';

  @override
  String get analytics_noData =>
      'உங்கள் முன்னேற்றத்தைக் காண கண்காணிக்கத் தொடங்குங்கள்!';

  @override
  String get analytics_addMeasurement => 'அளவீடு சேர்';

  @override
  String get ai_title => 'AI பயிற்சியாளர்';

  @override
  String get ai_motivation => 'தினசரி ஊக்கம்';

  @override
  String get ai_workout => 'பயிற்சி பரிந்துரை';

  @override
  String get ai_diet => 'உணவு பரிந்துரை';

  @override
  String get ai_photoAnalysis => 'புகைப்பட பகுப்பாய்வு';

  @override
  String get ai_weeklySummary => 'வாராந்திர சுருக்கம்';

  @override
  String get ai_voiceLog => 'குரல் பதிவு';

  @override
  String get ai_voicePrompt => 'உங்கள் செயல்பாட்டைப் பேசுங்கள்...';

  @override
  String get ai_disclaimer => 'AI மதிப்பீடு மட்டுமே — மருத்துவ ஆலோசனை அல்ல';

  @override
  String get ai_generating => 'உருவாக்குகிறது...';

  @override
  String get ai_error => 'பதில் உருவாக்க இயலவில்லை. பின்னர் முயற்சிக்கவும்.';

  @override
  String get ai_disabled =>
      'AI அம்சங்கள் முடக்கப்பட்டுள்ளன. அமைப்புகளில் இயக்கவும்.';

  @override
  String get ai_chatPlaceholder =>
      'உங்கள் உடற்பயிற்சி பயணத்தைப் பற்றி எதையும் கேளுங்கள்...';

  @override
  String get ai_send => 'அனுப்பு';

  @override
  String get media_takePhoto => 'புகைப்படம் எடு';

  @override
  String get media_chooseGallery => 'கேலரியிலிருந்து தேர்வு';

  @override
  String get media_recordVideo => 'வீடியோ பதிவு (30 வி அதிகபட்சம்)';

  @override
  String get media_uploading => 'பதிவேற்றுகிறது...';

  @override
  String get media_uploadSuccess => 'பதிவேற்றம் வெற்றி!';

  @override
  String get media_uploadFailed =>
      'பதிவேற்றம் தோல்வி. ஆன்லைனில் மீண்டும் முயற்சிக்கும்.';

  @override
  String get media_encrypted => 'மறைகுறியாக்கப்பட்டது & பாதுகாப்பானது';

  @override
  String get media_front => 'முன்';

  @override
  String get media_side => 'பக்கம்';

  @override
  String get media_back => 'பின்';

  @override
  String get transformation_title => 'மாற்றம்';

  @override
  String get transformation_weekly => 'வாராந்திர செல்ஃபி';

  @override
  String get transformation_timeline => 'காலவரிசை';

  @override
  String get transformation_beforeAfter => 'முன் / பின்';

  @override
  String get transformation_takeNow => 'உங்கள் வாராந்திர செல்ஃபி எடுங்கள்';

  @override
  String get transformation_noPhotos =>
      'உங்கள் முதல் புகைப்படத்துடன் மாற்ற பயணத்தைத் தொடங்குங்கள்!';

  @override
  String get recap_title => 'வாராந்திர சுருக்கம்';

  @override
  String recap_day(int number) {
    return 'நாள் $number';
  }

  @override
  String recap_completed(int count) {
    return '$count பணிகள் நிறைவு';
  }

  @override
  String get recap_bestDay => 'சிறந்த நாள்';

  @override
  String get recap_totalStreak => 'மொத்த தொடர்';

  @override
  String get settings_title => 'அமைப்புகள்';

  @override
  String get settings_language => 'மொழி';

  @override
  String get settings_theme => 'தீம்';

  @override
  String get settings_darkMode => 'இருள் பயன்முறை';

  @override
  String get settings_lightMode => 'ஒளி பயன்முறை';

  @override
  String get settings_cloudBackup => 'கிளவுட் காப்புப்பிரதி';

  @override
  String get settings_cloudBackupDesc =>
      'உங்கள் தரவை Firebase-க்கு ஒத்திசைக்கவும் (மறைகுறியாக்கப்பட்டது)';

  @override
  String get settings_aiFeatures => 'AI அம்சங்கள்';

  @override
  String get settings_aiFeaturesDesc =>
      'AI இயக்கப்படும் பரிந்துரைகள் மற்றும் பகுப்பாய்வை இயக்கவும்';

  @override
  String get settings_privacy => 'தனியுரிமைக் கொள்கை';

  @override
  String get settings_about => 'வைப்ஃபோர்ஜ் பற்றி';

  @override
  String get settings_signOut => 'வெளியேறு';

  @override
  String get settings_deleteAccount => 'கணக்கை நீக்கு';

  @override
  String settings_version(String version) {
    return 'பதிப்பு $version';
  }

  @override
  String get privacy_title => 'தனியுரிமை & பாதுகாப்பு';

  @override
  String get privacy_photoPolicy =>
      'நீங்கள் கிளவுட் காப்புப்பிரதியை வெளிப்படையாக இயக்காத வரை உங்கள் புகைப்படங்கள் உங்கள் சாதனத்தை விட்டு வெளியேறாது.';

  @override
  String get privacy_encryptionPolicy =>
      'அனைத்து மீடியாவும் உங்கள் சாதனத்தில் AES-256 மூலம் மறைகுறியாக்கப்படுகிறது.';

  @override
  String get privacy_noThirdParty =>
      'எந்த மூன்றாம் தரப்பு பகுப்பாய்வும் உங்கள் தனிப்பட்ட புகைப்படங்கள் அல்லது தரவைக் கண்காணிக்காது.';

  @override
  String get privacy_firebasePolicy =>
      'கிளவுட் காப்புப்பிரதி இயக்கப்பட்டால், அங்கீகரிக்கப்பட்ட Firebase Storage மூலம் நீங்கள் மட்டுமே உங்கள் தரவை அணுகலாம்.';

  @override
  String get auth_signIn => 'Google மூலம் உள்நுழைக';

  @override
  String get auth_signingIn => 'உள்நுழைகிறது...';

  @override
  String get auth_signInError => 'உள்நுழைவு தோல்வி. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get auth_signOut => 'வெளியேறு';

  @override
  String get auth_welcome => 'வைப்ஃபோர்ஜ்-க்கு வருக';

  @override
  String get auth_tagline => 'உங்கள் தனிப்பட்ட மாற்ற பயணம் இங்கே தொடங்குகிறது';

  @override
  String get onboarding_title1 => 'உங்கள் பழக்கங்களைக் கண்காணியுங்கள்';

  @override
  String get onboarding_desc1 =>
      'அழகான தினசரி பட்டியலுடன் உணவு, உடற்பயிற்சி, கோடிங் மற்றும் வாழ்க்கை முறையில் நிலைத்தன்மையை உருவாக்குங்கள்.';

  @override
  String get onboarding_title2 => 'உங்கள் முன்னேற்றத்தைப் பாருங்கள்';

  @override
  String get onboarding_desc2 =>
      'வாராந்திர செல்ஃபிகள், விளக்கப்படங்கள் மற்றும் தொடர்கள் மூலம் உங்கள் மாற்ற பயணத்தைக் காட்சிப்படுத்துங்கள்.';

  @override
  String get onboarding_title3 => 'AI இயக்கப்படும் பயிற்சி';

  @override
  String get onboarding_desc3 =>
      'AI மூலம் இயக்கப்படும் தனிப்பயனாக்கப்பட்ட பயிற்சி, உணவு மற்றும் ஊக்க பரிந்துரைகளைப் பெறுங்கள்.';

  @override
  String get onboarding_getStarted => 'தொடங்குங்கள்';

  @override
  String get onboarding_next => 'அடுத்து';

  @override
  String get onboarding_skip => 'தவிர்';

  @override
  String get common_save => 'சேமி';

  @override
  String get common_cancel => 'ரத்துசெய்';

  @override
  String get common_delete => 'நீக்கு';

  @override
  String get common_edit => 'திருத்து';

  @override
  String get common_done => 'முடிந்தது';

  @override
  String get common_retry => 'மீண்டும் முயற்சி';

  @override
  String get common_loading => 'ஏற்றுகிறது...';

  @override
  String get common_error => 'ஏதோ தவறு நடந்தது';

  @override
  String get common_offline =>
      'நீங்கள் ஆஃப்லைனில் உள்ளீர்கள். இணைக்கும்போது மாற்றங்கள் ஒத்திசைக்கப்படும்.';

  @override
  String get common_noData => 'தரவு இல்லை';

  @override
  String get common_today => 'இன்று';

  @override
  String get common_yesterday => 'நேற்று';

  @override
  String get common_thisWeek => 'இந்த வாரம்';

  @override
  String get common_thisMonth => 'இந்த மாதம்';
}
