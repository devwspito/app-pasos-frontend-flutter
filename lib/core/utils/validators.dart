/// Utility class for form field validation.
///
/// Provides common validation methods for email, password, phone, etc.
/// All methods return null if valid, or an error message string if invalid.
///
/// Example:
/// ```dart
/// TextFormField(
///   validator: Validators.validateEmail,
///   decoration: InputDecoration(labelText: 'Email'),
/// )
/// ```
class Validators {
  /// Regular expression for validating email addresses.
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Regular expression for validating international phone numbers.
  static final RegExp _phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');

  /// Validates an email address.
  ///
  /// Returns null if valid, error message if invalid.
  /// Checks for:
  /// - Non-empty value
  /// - Valid email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates a password.
  ///
  /// Returns null if valid, error message if invalid.
  /// Checks for:
  /// - Non-empty value
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one number
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validates a phone number.
  ///
  /// Returns null if valid, error message if invalid.
  /// Accepts international format with optional + prefix.
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!_phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-()]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates that a field is not empty.
  ///
  /// [fieldName] is used in the error message.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates minimum length of a field.
  ///
  /// [minLength] is the minimum required length.
  /// [fieldName] is used in the error message.
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Prevent instantiation - this is a utility class
  Validators._();
}
