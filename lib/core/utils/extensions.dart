import 'package:flutter/material.dart';

/// Extension methods on [String] for common string operations.
extension StringExtension on String {
  /// Capitalizes the first letter of the string.
  ///
  /// Example: 'hello' -> 'Hello'
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of each word in the string.
  ///
  /// Example: 'hello world' -> 'Hello World'
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Removes all whitespace from the string.
  ///
  /// Example: 'hello world' -> 'helloworld'
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Truncates the string to the specified [maxLength] with optional [suffix].
  ///
  /// Example: 'Hello World'.truncate(5) -> 'Hello...'
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }

  /// Checks if the string is a valid email format.
  bool get isValidEmail {
    if (isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Checks if the string contains only numeric characters.
  bool get isNumeric {
    if (isEmpty) return false;
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  /// Checks if the string contains only alphabetic characters.
  bool get isAlpha {
    if (isEmpty) return false;
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  /// Checks if the string contains only alphanumeric characters.
  bool get isAlphanumeric {
    if (isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  /// Converts the string to a nullable int.
  int? toIntOrNull() => int.tryParse(this);

  /// Converts the string to a nullable double.
  double? toDoubleOrNull() => double.tryParse(this);

  /// Masks the string, showing only the first and last [visibleChars] characters.
  ///
  /// Example: 'password'.mask() -> 'pa****rd'
  String mask({int visibleChars = 2, String maskChar = '*'}) {
    if (length <= visibleChars * 2) return maskChar * length;
    final start = substring(0, visibleChars);
    final end = substring(length - visibleChars);
    final masked = maskChar * (length - visibleChars * 2);
    return '$start$masked$end';
  }

  /// Extracts initials from the string (first letter of each word).
  ///
  /// Example: 'John Doe' -> 'JD'
  String get initials {
    if (isEmpty) return '';
    return split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase())
        .join();
  }
}

/// Extension methods on nullable [String] for safe operations.
extension NullableStringExtension on String? {
  /// Returns true if the string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns true if the string is not null and not empty.
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Returns the string or a default value if null/empty.
  String orDefault(String defaultValue) =>
      isNullOrEmpty ? defaultValue : this!;
}

/// Extension methods on [DateTime] for common date operations.
extension DateTimeExtension on DateTime {
  /// Formats the date as 'yyyy-MM-dd'.
  ///
  /// Example: DateTime(2024, 1, 15) -> '2024-01-15'
  String get toDateString {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Formats the time as 'HH:mm'.
  ///
  /// Example: DateTime(2024, 1, 15, 14, 30) -> '14:30'
  String get toTimeString {
    final h = hour.toString().padLeft(2, '0');
    final min = minute.toString().padLeft(2, '0');
    return '$h:$min';
  }

  /// Formats the date and time as 'yyyy-MM-dd HH:mm'.
  String get toDateTimeString => '$toDateString $toTimeString';

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

  /// Returns true if this date is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Returns true if this date is in the future.
  bool get isFuture => isAfter(DateTime.now());

  /// Returns the start of the day (00:00:00).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns the end of the day (23:59:59.999).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Returns a human-readable relative time string.
  ///
  /// Example: '2 hours ago', 'in 3 days', 'just now'
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.isNegative) {
      return _formatFutureTime(difference.abs());
    }

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  String _formatFutureTime(Duration difference) {
    if (difference.inSeconds < 60) {
      return 'in a moment';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'in $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'in $hours ${hours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'in $days ${days == 1 ? 'day' : 'days'}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'in $weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'in $months ${months == 1 ? 'month' : 'months'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'in $years ${years == 1 ? 'year' : 'years'}';
    }
  }

  /// Adds a specified number of business days to the date.
  DateTime addBusinessDays(int days) {
    var result = this;
    var remaining = days;

    while (remaining > 0) {
      result = result.add(const Duration(days: 1));
      if (result.weekday != DateTime.saturday &&
          result.weekday != DateTime.sunday) {
        remaining--;
      }
    }

    return result;
  }
}

/// Extension methods on [BuildContext] for easy access to common properties.
extension BuildContextExtension on BuildContext {
  /// Returns the current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Returns the current [TextTheme].
  TextTheme get textTheme => theme.textTheme;

  /// Returns the current [ColorScheme].
  ColorScheme get colorScheme => theme.colorScheme;

  /// Returns the current [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Returns the screen width.
  double get screenWidth => mediaQuery.size.width;

  /// Returns the screen height.
  double get screenHeight => mediaQuery.size.height;

  /// Returns the screen size.
  Size get screenSize => mediaQuery.size;

  /// Returns the view padding (safe areas).
  EdgeInsets get viewPadding => mediaQuery.viewPadding;

  /// Returns the bottom padding (keyboard height when visible).
  double get bottomInset => mediaQuery.viewInsets.bottom;

  /// Returns true if the keyboard is visible.
  bool get isKeyboardVisible => mediaQuery.viewInsets.bottom > 0;

  /// Returns true if the device is in dark mode.
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Returns true if the device is in portrait orientation.
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// Returns true if the device is in landscape orientation.
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// Returns true if the device is a tablet (screen width >= 600).
  bool get isTablet => screenWidth >= 600;

  /// Returns true if the device is a phone (screen width < 600).
  bool get isPhone => screenWidth < 600;

  /// Shows a [SnackBar] with the given [message].
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
      ),
    );
  }

  /// Shows an error [SnackBar] with the given [message].
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Shows a success [SnackBar] with the given [message].
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Hides the current [SnackBar].
  void hideSnackBar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }

  /// Unfocuses any focused widget (closes keyboard).
  void unfocus() {
    FocusScope.of(this).unfocus();
  }
}

/// Extension methods on [num] for common numeric operations.
extension NumExtension on num {
  /// Converts the number to a duration in milliseconds.
  Duration get milliseconds => Duration(milliseconds: toInt());

  /// Converts the number to a duration in seconds.
  Duration get seconds => Duration(seconds: toInt());

  /// Converts the number to a duration in minutes.
  Duration get minutes => Duration(minutes: toInt());

  /// Converts the number to a duration in hours.
  Duration get hours => Duration(hours: toInt());

  /// Converts the number to a duration in days.
  Duration get days => Duration(days: toInt());

  /// Returns true if the number is between [min] and [max] (inclusive).
  bool isBetween(num min, num max) => this >= min && this <= max;

  /// Formats the number as currency with optional [symbol] and [decimals].
  String toCurrency({String symbol = '\$', int decimals = 2}) {
    return '$symbol${toStringAsFixed(decimals)}';
  }

  /// Formats the number as a percentage with optional [decimals].
  String toPercentage({int decimals = 1}) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }
}

/// Extension methods on [Iterable] for common collection operations.
extension IterableExtension<T> on Iterable<T> {
  /// Returns the first element matching the predicate, or null if none found.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Returns the last element matching the predicate, or null if none found.
  T? lastWhereOrNull(bool Function(T element) test) {
    T? result;
    for (final element in this) {
      if (test(element)) result = element;
    }
    return result;
  }

  /// Returns a list with distinct elements based on the key selector.
  List<T> distinctBy<K>(K Function(T element) keySelector) {
    final seen = <K>{};
    return where((element) => seen.add(keySelector(element))).toList();
  }
}

/// Extension methods on [List] for common list operations.
extension ListExtension<T> on List<T> {
  /// Safely returns the element at [index], or null if out of bounds.
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Adds an element only if it doesn't already exist in the list.
  void addIfNotExists(T element) {
    if (!contains(element)) add(element);
  }

  /// Replaces the first occurrence of [oldElement] with [newElement].
  bool replaceFirst(T oldElement, T newElement) {
    final index = indexOf(oldElement);
    if (index == -1) return false;
    this[index] = newElement;
    return true;
  }
}
