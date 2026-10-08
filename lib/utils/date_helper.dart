import 'package:intl/intl.dart';

/// Helper methods for dates, times, and attendance statistics
class DateHelper {
  static final DateFormat _dbFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _dayOfWeekFormat = DateFormat('EEEE');
  static final DateFormat _shortDayOfWeekFormat = DateFormat('EEE');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy • hh:mm a');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  /// Formats date for SQLite storage: yyyy-MM-dd
  static String formatDbDate(DateTime date) {
    return _dbFormat.format(date);
  }

  /// Parses date from SQLite string yyyy-MM-dd
  static DateTime parseDbDate(String dateStr) {
    try {
      return _dbFormat.parse(dateStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Formats date for human display: e.g. "Oct 08, 2026"
  static String formatDisplay(DateTime date) {
    return _displayFormat.format(date);
  }

  /// Formats date string from DB to human display
  static String formatDbToDisplay(String dateStr) {
    return formatDisplay(parseDbDate(dateStr));
  }

  /// Formats time: e.g. "02:30 PM"
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Formats date and time: e.g. "Oct 08, 2026 • 02:30 PM"
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Returns full day name: e.g. "Thursday"
  static String getDayOfWeek(DateTime date) {
    return _dayOfWeekFormat.format(date);
  }

  /// Returns short day name: e.g. "Thu"
  static String getShortDayOfWeek(DateTime date) {
    return _shortDayOfWeekFormat.format(date);
  }

  /// Returns month and year: e.g. "October 2026"
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Checks if given date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Checks if two dates fall on the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Calculates attendance percentage with 1 decimal place, safe against zero division
  static double calculatePercentage(int presentDays, int totalDays) {
    if (totalDays <= 0) return 0.0;
    if (presentDays <= 0) return 0.0;
    if (presentDays >= totalDays) return 100.0;
    final percentage = (presentDays / totalDays) * 100.0;
    return double.parse(percentage.toStringAsFixed(1));
  }

  /// Returns list of all days in given month
  static List<DateTime> getDaysInMonth(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return List.generate(lastDay, (index) => DateTime(year, month, index + 1));
  }
}
