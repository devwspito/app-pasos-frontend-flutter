/// Input validation utilities for App Pasos.
///
/// Provides static validation methods for common input types such as
/// email addresses, passwords, phone numbers, and generic text fields.
library;

/// Abstract final class containing static validation methods.
///
/// All validators return `null` for valid input and an error message string
/// for invalid input. This makes them directly compatible with Flutter's
/// [TextFormField.validator] callback.
///
/// Example usage:
/// ```dart
/// TextFormField(
///   validator: Validators.email,
///   decoration: InputDecoration(labelText: 'Email'),
/// )
///
/// TextFormField(
///   validator: (value) => Validators.minLength(value, 3, 'Username'),
///   decoration: InputDecoration(labelText: 'Username'),
/// )
/// ```
abstract final class Validators {
  /// Regular expression for validating email addresses.
  ///
  /// Matches most common email formats as per RFC 5322 (simplified).
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Regular expression for validating phone numbers.
  ///
  /// Accepts formats like: +1234567890, (123) 456-7890, 123-456-7890, etc.
  static final _phoneRegex = RegExp(
    r'^[\+]?[(]?[0-9]{1,3}[)]?[-\s\.]?[(]?[0-9]{1,4}[)]?[-\s\.]?[0-9]{1,4}[-\s\.]?[0-9]{1,9}$',
  );

  /// Regular expression for checking uppercase letters.
  static final _uppercaseRegex = RegExp(r'[A-Z]');

  /// Regular expression for checking lowercase letters.
  static final _lowercaseRegex = RegExp(r'[a-z]');

  /// Regular expression for checking digits.
  static final _digitRegex = RegExp(r'[0-9]');

  /// Validates an email address.
  ///
  /// Returns `null` if the email is valid, or an error message if invalid.
  ///
  /// Validation rules:
  /// - Must not be empty
  /// - Must match email format (name@domain.tld)
  ///
  /// [value] - The email address to validate.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmedValue = value.trim();
    if (!_emailRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates a password.
  ///
  /// Returns `null` if the password is valid, or an error message if invalid.
  ///
  /// Validation rules:
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one digit
  ///
  /// [value] - The password to validate.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!_uppercaseRegex.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!_lowercaseRegex.hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!_digitRegex.hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validates that a field is not empty.
  ///
  /// Returns `null` if the field has a value, or an error message if empty.
  ///
  /// [value] - The value to validate.
  /// [fieldName] - The name of the field for the error message.
  static String? required(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates minimum length of a string.
  ///
  /// Returns `null` if the string meets the minimum length, or an error
  /// message if too short.
  ///
  /// [value] - The value to validate.
  /// [min] - The minimum required length.
  /// [fieldName] - The name of the field for the error message.
  static String? minLength(String? value, int min, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }

    return null;
  }

  /// Validates a phone number.
  ///
  /// Returns `null` if the phone number is valid, or an error message if invalid.
  ///
  /// Accepts various formats including:
  /// - +1234567890
  /// - (123) 456-7890
  /// - 123-456-7890
  /// - 123.456.7890
  ///
  /// [value] - The phone number to validate.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final cleanedValue = value.replaceAll(RegExp(r'\s'), '');
    if (!_phoneRegex.hasMatch(cleanedValue)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates maximum length of a string.
  ///
  /// Returns `null` if the string meets the maximum length constraint,
  /// or an error message if too long.
  ///
  /// [value] - The value to validate.
  /// [max] - The maximum allowed length.
  /// [fieldName] - The name of the field for the error message.
  static String? maxLength(String? value, int max, [String fieldName = 'Field']) {
    if (value == null) {
      return null;
    }

    if (value.length > max) {
      return '$fieldName must be at most $max characters';
    }

    return null;
  }

  /// Validates that a value matches a confirmation value.
  ///
  /// Useful for password confirmation fields.
  ///
  /// [value] - The value to validate.
  /// [confirmValue] - The value to match against.
  /// [fieldName] - The name of the field for the error message.
  static String? match(
    String? value,
    String? confirmValue, [
    String fieldName = 'Fields',
  ]) {
    if (value != confirmValue) {
      return '$fieldName do not match';
    }
    return null;
  }

  /// Validates a numeric string.
  ///
  /// Returns `null` if the value is a valid number, or an error message
  /// if invalid.
  ///
  /// [value] - The value to validate.
  /// [fieldName] - The name of the field for the error message.
  static String? numeric(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (double.tryParse(value.trim()) == null) {
      return '$fieldName must be a valid number';
    }

    return null;
  }

  /// Combines multiple validators into one.
  ///
  /// Returns the first error message from any failing validator,
  /// or `null` if all validators pass.
  ///
  /// Example usage:
  /// ```dart
  /// TextFormField(
  ///   validator: Validators.compose([
  ///     (v) => Validators.required(v, 'Username'),
  ///     (v) => Validators.minLength(v, 3, 'Username'),
  ///     (v) => Validators.maxLength(v, 20, 'Username'),
  ///   ]),
  /// )
  /// ```
  ///
  /// [validators] - List of validator functions to combine.
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }
}
