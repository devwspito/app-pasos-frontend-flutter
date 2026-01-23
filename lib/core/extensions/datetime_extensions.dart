import 'package:intl/intl.dart';

/// DateTime extension methods for formatting and manipulation.
extension DateTimeExtensions on DateTime {
  /// Returns the ISO 8601 string representation.
  String get toIso8601 => toIso8601String();

  /// Formats the date using the specified pattern.
  ///
  /// Default pattern: 'MMM dd, yyyy' (e.g., 'Jan 15, 2024')
  ///
  /// Common patterns:
  /// - 'yyyy-MM-dd' -> '2024-01-15'
  /// - 'dd/MM/yyyy' -> '15/01/2024'
  /// - 'EEEE, MMMM d, yyyy' -> 'Monday, January 15, 2024'
  /// - 'HH:mm:ss' -> '14:30:00'
  String format([String pattern = 'MMM dd, yyyy']) =>
      DateFormat(pattern).format(this);

  /// Returns a human-readable time ago string.
  ///
  /// Examples:
  /// - 'Just now' (< 1 minute)
  /// - '5 minutes ago'
  /// - '2 hours ago'
  /// - '3 days ago'
  /// - '2 months ago'
  /// - '1 years ago'
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} years ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }

  /// Returns true if this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Returns true if this date is tomorrow.
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Returns the start of the day (00:00:00).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns the end of the day (23:59:59.999).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Returns the start of the week (Monday).
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).startOfDay;
  }

  /// Returns the start of the month.
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Returns the end of the month.
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// Adds a specified number of days.
  DateTime addDays(int days) => add(Duration(days: days));

  /// Subtracts a specified number of days.
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// Returns true if this date is in the same day as [other].
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Returns true if this date is before today.
  bool get isPast => isBefore(DateTime.now().startOfDay);

  /// Returns true if this date is after today.
  bool get isFuture => isAfter(DateTime.now().endOfDay);
}
