/// Centralized validation utilities for form fields and user input.
///
/// All validators return null if valid, or an error message if invalid.
/// This follows the pattern expected by Flutter's TextFormField validator.
abstract final class Validators {
  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final _phoneRegex = RegExp(r'^\+?[0-9]{10,14}$');

  /// Validates an email address.
  ///
  /// Returns null if valid, error message if invalid.
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(value)) return 'Invalid email format';
    return null;
  }

  /// Validates a password with configurable minimum length.
  ///
  /// Requirements:
  /// - Not empty
  /// - Minimum length (default: 8 characters)
  /// - At least one uppercase letter
  /// - At least one number
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }
    return null;
  }

  /// Validates that a field is not empty.
  ///
  /// [fieldName] is used to customize the error message.
  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  /// Validates a phone number.
  ///
  /// Accepts international format with optional + prefix.
  /// Strips spaces, dashes, and parentheses before validation.
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!_phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-()]'), ''))) {
      return 'Invalid phone number';
    }
    return null;
  }

  /// Validates that a value has a minimum length.
  static String? minLength(String? value, int length, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    if (value.length < length) {
      return '$fieldName must be at least $length characters';
    }
    return null;
  }

  /// Validates that a value has a maximum length.
  static String? maxLength(String? value, int length, {String fieldName = 'Field'}) {
    if (value == null) return null;
    if (value.length > length) {
      return '$fieldName must be at most $length characters';
    }
    return null;
  }

  /// Validates that two values match (e.g., password confirmation).
  static String? match(String? value, String? matchValue, {String message = 'Values do not match'}) {
    if (value != matchValue) return message;
    return null;
  }
}
