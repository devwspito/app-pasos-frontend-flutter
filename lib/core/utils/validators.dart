/// Utility class containing common validation functions for form fields.
///
/// All validators return `null` if validation passes, or an error message
/// string if validation fails. This pattern is compatible with Flutter's
/// `TextFormField.validator` parameter.
///
/// Usage:
/// ```dart
/// TextFormField(
///   validator: Validators.email,
///   decoration: InputDecoration(labelText: 'Email'),
/// )
/// ```
class Validators {
  Validators._();

  /// Email validation regex pattern.
  static final RegExp _emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  /// Phone number validation regex (international format).
  static final RegExp _phoneRegex = RegExp(
    r'^\+?[\d\s-]{10,}$',
  );

  /// Validates an email address.
  ///
  /// Returns `null` if valid, error message otherwise.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Invalid email format';
    }
    return null;
  }

  /// Validates a password.
  ///
  /// Requires at least 8 characters.
  /// Returns `null` if valid, error message otherwise.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Validates a strong password.
  ///
  /// Requires at least 8 characters, including uppercase, lowercase,
  /// number, and special character.
  /// Returns `null` if valid, error message otherwise.
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
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

  /// Validates that a field is not empty.
  ///
  /// [fieldName] is used in the error message for clarity.
  /// Returns `null` if valid, error message otherwise.
  static String? required(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates a phone number.
  ///
  /// Accepts international format with optional + prefix.
  /// Returns `null` if valid, error message otherwise.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'Invalid phone number format';
    }
    return null;
  }

  /// Validates that a value meets a minimum length requirement.
  ///
  /// Returns `null` if valid, error message otherwise.
  static String? minLength(String? value, int minLength,
      [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validates that a value does not exceed a maximum length.
  ///
  /// Returns `null` if valid, error message otherwise.
  static String? maxLength(String? value, int maxLength,
      [String fieldName = 'Field']) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }

  /// Validates that two values match (e.g., password confirmation).
  ///
  /// Returns `null` if valid, error message otherwise.
  static String? match(String? value, String? matchValue,
      [String fieldName = 'Fields']) {
    if (value != matchValue) {
      return '$fieldName do not match';
    }
    return null;
  }

  /// Validates a numeric value.
  ///
  /// Returns `null` if valid, error message otherwise.
  static String? numeric(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  /// Creates a validator that checks if the value is within a numeric range.
  ///
  /// Returns a validator function compatible with TextFormField.
  static String? Function(String?) range(
    double min,
    double max, [
    String fieldName = 'Value',
  ]) {
    return (String? value) {
      final numericError = numeric(value, fieldName);
      if (numericError != null) return numericError;

      final number = double.parse(value!);
      if (number < min || number > max) {
        return '$fieldName must be between $min and $max';
      }
      return null;
    };
  }
}
