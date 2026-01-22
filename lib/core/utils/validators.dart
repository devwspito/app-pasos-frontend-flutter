import '../constants/app_constants.dart';

/// A collection of input validation functions.
///
/// Uses Dart 3 `abstract final class` pattern to prevent instantiation.
/// All validators return a nullable String:
/// - Returns null if valid
/// - Returns an error message if invalid
abstract final class Validators {
  // ============================================
  // Email Validation
  // ============================================

  /// Validates an email address.
  ///
  /// Returns null if valid, or an error message if invalid.
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final trimmed = value.trim();

    if (trimmed.length > 254) {
      return 'Email is too long';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // ============================================
  // Password Validation
  // ============================================

  /// Validates a password.
  ///
  /// Requirements:
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one digit
  /// - At least one special character
  ///
  /// Returns null if valid, or an error message if invalid.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password must be less than ${AppConstants.maxPasswordLength} characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validates password confirmation.
  ///
  /// Returns null if valid, or an error message if invalid.
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates a simple password (less strict, no special char requirement).
  ///
  /// Requirements:
  /// - Minimum 8 characters
  /// - At least one letter
  /// - At least one digit
  static String? simplePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  // ============================================
  // Phone Validation
  // ============================================

  /// Validates a phone number.
  ///
  /// Accepts formats:
  /// - +1234567890
  /// - 1234567890
  /// - 123-456-7890
  /// - (123) 456-7890
  ///
  /// Returns null if valid, or an error message if invalid.
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters except +
    final digits = value.replaceAll(RegExp(r'[^\d+]'), '');

    // Check for valid format
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

    if (!phoneRegex.hasMatch(digits)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates an optional phone number (empty is allowed).
  static String? phoneOptional(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return phone(value);
  }

  // ============================================
  // Username Validation
  // ============================================

  /// Validates a username.
  ///
  /// Requirements:
  /// - 3-50 characters
  /// - Only alphanumeric characters, underscores, and hyphens
  /// - Must start with a letter
  ///
  /// Returns null if valid, or an error message if invalid.
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < AppConstants.minUsernameLength) {
      return 'Username must be at least ${AppConstants.minUsernameLength} characters';
    }

    if (trimmed.length > AppConstants.maxUsernameLength) {
      return 'Username must be less than ${AppConstants.maxUsernameLength} characters';
    }

    if (!RegExp(r'^[a-zA-Z]').hasMatch(trimmed)) {
      return 'Username must start with a letter';
    }

    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_-]*$').hasMatch(trimmed)) {
      return 'Username can only contain letters, numbers, underscores, and hyphens';
    }

    return null;
  }

  // ============================================
  // Name Validation
  // ============================================

  /// Validates a name (first name, last name, etc.).
  ///
  /// Requirements:
  /// - 1-100 characters
  /// - Only letters, spaces, hyphens, and apostrophes
  ///
  /// Returns null if valid, or an error message if invalid.
  static String? name(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return '$fieldName is required';
    }

    if (trimmed.length > 100) {
      return '$fieldName must be less than 100 characters';
    }

    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(trimmed)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // ============================================
  // Generic Validations
  // ============================================

  /// Validates that a field is not empty.
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates minimum length.
  static String? minLength(
    String? value, {
    required int min,
    String fieldName = 'This field',
  }) {
    if (value == null || value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Validates maximum length.
  static String? maxLength(
    String? value, {
    required int max,
    String fieldName = 'This field',
  }) {
    if (value != null && value.length > max) {
      return '$fieldName must be less than $max characters';
    }
    return null;
  }

  /// Validates a numeric value.
  static String? numeric(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }

    return null;
  }

  /// Validates a positive number.
  static String? positiveNumber(
    String? value, {
    String fieldName = 'This field',
  }) {
    final numericError = numeric(value, fieldName: fieldName);
    if (numericError != null) return numericError;

    final number = double.parse(value!);
    if (number <= 0) {
      return '$fieldName must be greater than zero';
    }

    return null;
  }

  /// Validates a number is within a range.
  static String? numberInRange(
    String? value, {
    required num min,
    required num max,
    String fieldName = 'This field',
  }) {
    final numericError = numeric(value, fieldName: fieldName);
    if (numericError != null) return numericError;

    final number = double.parse(value!);
    if (number < min || number > max) {
      return '$fieldName must be between $min and $max';
    }

    return null;
  }

  // ============================================
  // URL Validation
  // ============================================

  /// Validates a URL.
  ///
  /// Returns null if valid, or an error message if invalid.
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Please enter a valid URL';
    }

    if (!['http', 'https'].contains(uri.scheme.toLowerCase())) {
      return 'URL must start with http:// or https://';
    }

    return null;
  }

  /// Validates an optional URL (empty is allowed).
  static String? urlOptional(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return url(value);
  }

  // ============================================
  // Date Validation
  // ============================================

  /// Validates that a date is not in the past.
  static String? notInPast(
    DateTime? value, {
    String fieldName = 'Date',
  }) {
    if (value == null) {
      return '$fieldName is required';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(value.year, value.month, value.day);

    if (date.isBefore(today)) {
      return '$fieldName cannot be in the past';
    }

    return null;
  }

  /// Validates that a date is not in the future.
  static String? notInFuture(
    DateTime? value, {
    String fieldName = 'Date',
  }) {
    if (value == null) {
      return '$fieldName is required';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(value.year, value.month, value.day);

    if (date.isAfter(today)) {
      return '$fieldName cannot be in the future';
    }

    return null;
  }

  /// Validates an age requirement.
  static String? minimumAge(
    DateTime? birthDate, {
    required int minimumAge,
    String fieldName = 'Birth date',
  }) {
    if (birthDate == null) {
      return '$fieldName is required';
    }

    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    if (age < minimumAge) {
      return 'You must be at least $minimumAge years old';
    }

    return null;
  }

  // ============================================
  // Compose Multiple Validators
  // ============================================

  /// Combines multiple validators. Returns the first error found, or null if all pass.
  static String? compose(
    List<String? Function()> validators,
  ) {
    for (final validator in validators) {
      final error = validator();
      if (error != null) return error;
    }
    return null;
  }
}
