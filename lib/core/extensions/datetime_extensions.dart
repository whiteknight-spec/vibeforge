import 'package:intl/intl.dart';

/// Extensions on DateTime for VibeForge date formatting and comparisons.
extension DateTimeExtensions on DateTime {
  /// Format as "Sep 9, 2026"
  String get formatted => DateFormat('MMM d, y').format(this);

  /// Format as "09/09/2026"
  String get shortFormatted => DateFormat('dd/MM/y').format(this);

  /// Format as "Tuesday, September 9"
  String get dayFormatted => DateFormat('EEEE, MMMM d').format(this);

  /// Format as "Tuesday"
  String get dayName => DateFormat('EEEE').format(this);

  /// Format as "Tue"
  String get shortDayName => DateFormat('EEE').format(this);

  /// Format as "9:30 PM"
  String get timeFormatted => DateFormat('h:mm a').format(this);

  /// Format as "21:30"
  String get time24Formatted => DateFormat('HH:mm').format(this);

  /// Date key for storage: "2026-09-09"
  String get dateKey => DateFormat('yyyy-MM-dd').format(this);

  /// Week key: "2026-W37"
  String get weekKey {
    final weekNumber = _weekOfYear;
    return '$year-W${weekNumber.toString().padLeft(2, '0')}';
  }

  /// Month key: "2026-09"
  String get monthKey => DateFormat('yyyy-MM').format(this);

  /// Is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Same day comparison
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Start of day (midnight)
  DateTime get startOfDay => DateTime(year, month, day);

  /// End of day (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Start of week (Monday)
  DateTime get startOfWeek {
    final diff = weekday - DateTime.monday;
    return subtract(Duration(days: diff)).startOfDay;
  }

  /// Days ago
  int get daysAgo => DateTime.now().difference(this).inDays;

  /// Relative time string
  String get relative {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatted;
  }

  int get _weekOfYear {
    final jan1 = DateTime(year, 1, 1);
    final dayOfYear = difference(jan1).inDays;
    return ((dayOfYear - weekday + 10) / 7).floor();
  }
}
