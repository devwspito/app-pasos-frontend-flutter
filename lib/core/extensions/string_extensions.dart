/// String extension methods for common operations.
extension StringExtensions on String {
  /// Capitalizes the first letter of the string.
  ///
  /// Example: 'hello' -> 'Hello'
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Capitalizes the first letter of each word.
  ///
  /// Example: 'hello world' -> 'Hello World'
  String get capitalizeWords =>
      split(' ').map((w) => w.capitalize).join(' ');

  /// Returns true if the string is a valid email format.
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  /// Truncates the string to [maxLength] and adds a suffix.
  ///
  /// Example: 'Hello World'.truncate(8) -> 'Hello...'
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Returns null if the string is empty, otherwise returns the string.
  String? get nullIfEmpty => isEmpty ? null : this;

  /// Returns true if the string contains only numeric characters.
  bool get isNumeric => RegExp(r'^[0-9]+$').hasMatch(this);

  /// Returns true if the string contains only alphabetic characters.
  bool get isAlphabetic => RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  /// Returns true if the string contains only alphanumeric characters.
  bool get isAlphanumeric => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);

  /// Removes all whitespace from the string.
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Converts the string to snake_case.
  String get toSnakeCase => replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => '_${match.group(0)!.toLowerCase()}',
      ).replaceFirst(RegExp(r'^_'), '');

  /// Converts the string to camelCase.
  String get toCamelCase {
    final words = split(RegExp(r'[_\s-]+'));
    if (words.isEmpty) return this;
    return words.first.toLowerCase() +
        words.skip(1).map((w) => w.capitalize).join();
  }
}

/// Extension methods for nullable strings.
extension NullableStringExtensions on String? {
  /// Returns true if the string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns the string if not null, otherwise returns an empty string.
  String orEmpty() => this ?? '';

  /// Returns the string if not null or empty, otherwise returns the default value.
  String orDefault(String defaultValue) =>
      isNullOrEmpty ? defaultValue : this!;
}
