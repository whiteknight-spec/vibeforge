/// Time-based greeting utility for VibeForge.
/// Returns personalized greetings in English and Tamil based on current hour.
class GreetingUtils {
  GreetingUtils._();

  /// Returns a greeting based on the current time.
  /// [name] is the user's display name.
  /// [isTamil] determines the language.
  static String getGreeting({required String name, bool isTamil = false}) {
    final hour = DateTime.now().hour;

    if (isTamil) {
      return _getTamilGreeting(hour, name);
    }
    return _getEnglishGreeting(hour, name);
  }

  static String _getEnglishGreeting(int hour, String name) {
    if (hour >= 5 && hour < 12) {
      return 'Good morning, $name! ☀️';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon, $name! 🌤️';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening, $name! 🌅';
    } else {
      return 'Hey night owl, $name! 🌙';
    }
  }

  static String _getTamilGreeting(int hour, String name) {
    if (hour >= 5 && hour < 12) {
      return 'காலை வணக்கம், $name! ☀️';
    } else if (hour >= 12 && hour < 17) {
      return 'மதிய வணக்கம், $name! 🌤️';
    } else if (hour >= 17 && hour < 21) {
      return 'மாலை வணக்கம், $name! 🌅';
    } else {
      return 'இரவு வணக்கம், $name! 🌙';
    }
  }

  /// Returns a motivational subtitle based on time and completion.
  static String getSubtitle({
    required double completionRate,
    bool isTamil = false,
  }) {
    if (isTamil) {
      return _getTamilSubtitle(completionRate);
    }
    return _getEnglishSubtitle(completionRate);
  }

  static String _getEnglishSubtitle(double rate) {
    if (rate >= 1.0) return "You're on fire today! 🔥";
    if (rate >= 0.75) return 'Almost there, keep pushing! 💪';
    if (rate >= 0.5) return 'Halfway through, keep going! ⚡';
    if (rate >= 0.25) return 'Great start, keep the momentum! 🚀';
    if (rate > 0) return "You've started, that's what matters! ✨";

    final hour = DateTime.now().hour;
    if (hour < 10) return "Fresh day, fresh goals! Let's go! 🌟";
    if (hour < 14) return "Still plenty of time to crush it! 💫";
    if (hour < 18) return "Afternoon push! You got this! 🏋️";
    return "It's not too late to start! 🌙";
  }

  static String _getTamilSubtitle(double rate) {
    if (rate >= 1.0) return 'இன்று நீங்கள் அசத்துகிறீர்கள்! 🔥';
    if (rate >= 0.75) return 'கிட்டத்தட்ட முடிந்தது, தொடருங்கள்! 💪';
    if (rate >= 0.5) return 'பாதி முடிந்தது, தொடருங்கள்! ⚡';
    if (rate >= 0.25) return 'நல்ல தொடக்கம், வேகத்தைத் தொடருங்கள்! 🚀';
    if (rate > 0) return 'தொடங்கிவிட்டீர்கள், அதுவே முக்கியம்! ✨';

    final hour = DateTime.now().hour;
    if (hour < 10) return 'புதிய நாள், புதிய இலக்குகள்! 🌟';
    if (hour < 14) return 'இன்னும் நிறைய நேரம் இருக்கிறது! 💫';
    if (hour < 18) return 'மதியம் உந்துதல்! உங்களால் முடியும்! 🏋️';
    return 'தொடங்க இன்னும் நேரம் இருக்கிறது! 🌙';
  }
}
