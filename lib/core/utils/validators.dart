/// Validation utility class for form input validation.
///
/// Provides static validation methods that match the backend validation rules
/// defined in `auth.validator.ts`. All validators return an error message string
/// if validation fails, or `null` if validation passes.
///
/// Example:
/// ```dart
/// TextFormField(
///   validator: Validators.validateEmail,
///   decoration: InputDecoration(labelText: 'Email'),
/// )
/// ```
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  // ==========================================================================
  // Regular Expressions (matching backend)
  // ==========================================================================

  /// Email validation regex (matches backend: /^\S+@\S+\.\S+$/)
  static final RegExp _emailRegex = RegExp(r'^\S+@\S+\.\S+$');

  /// Username validation regex (matches backend: /^[a-zA-Z0-9_]+$/)
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  // ==========================================================================
  // Validation Constants (matching backend)
  // ==========================================================================

  /// Minimum password length (matches backend)
  static const int minPasswordLength = 6;

  /// Minimum username length (matches backend)
  static const int minUsernameLength = 3;

  /// Maximum username length (matches backend)
  static const int maxUsernameLength = 30;

  // ==========================================================================
  // Email Validation
  // ==========================================================================

  /// Validates an email address.
  ///
  /// Rules (matching backend auth.validator.ts):
  /// - Required field
  /// - Must be a valid email format (matches /^\S+@\S+\.\S+$/)
  ///
  /// [value] The email string to validate.
  ///
  /// Returns an error message if validation fails, or `null` if valid.
  static String? validateEmail(String? value) {
    // Check if empty
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmedValue = value.trim();

    // Check email format
    if (!_emailRegex.hasMatch(trimmedValue)) {
      return 'Please provide a valid email';
    }

    return null;
  }

  // ==========================================================================
  // Password Validation
  // ==========================================================================

  /// Validates a password.
  ///
  /// Rules (matching backend auth.validator.ts):
  /// - Required field
  /// - Minimum 6 characters
  ///
  /// [value] The password string to validate.
  ///
  /// Returns an error message if validation fails, or `null` if valid.
  static String? validatePassword(String? value) {
    // Check if empty
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    // Check minimum length
    if (value.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }

    return null;
  }

  // ==========================================================================
  // Username Validation
  // ==========================================================================

  /// Validates a username.
  ///
  /// Rules (matching backend auth.validator.ts):
  /// - Required field
  /// - Must be between 3 and 30 characters
  /// - Can only contain letters, numbers, and underscores
  ///
  /// [value] The username string to validate.
  ///
  /// Returns an error message if validation fails, or `null` if valid.
  static String? validateUsername(String? value) {
    // Check if empty
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }

    final trimmedValue = value.trim();

    // Check minimum length
    if (trimmedValue.length < minUsernameLength) {
      return 'Username must be at least $minUsernameLength characters';
    }

    // Check maximum length
    if (trimmedValue.length > maxUsernameLength) {
      return 'Username must be at most $maxUsernameLength characters';
    }

    // Check character format
    if (!_usernameRegex.hasMatch(trimmedValue)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  // ==========================================================================
  // Step Count Validation
  // ==========================================================================

  /// Validates a step count input.
  ///
  /// Rules:
  /// - Required field
  /// - Must be a valid positive integer
  ///
  /// [value] The step count string to validate.
  ///
  /// Returns an error message if validation fails, or `null` if valid.
  static String? validateStepCount(String? value) {
    // Check if empty
    if (value == null || value.trim().isEmpty) {
      return 'Step count is required';
    }

    final trimmedValue = value.trim();

    // Try to parse as integer
    final int? stepCount = int.tryParse(trimmedValue);

    if (stepCount == null) {
      return 'Please enter a valid number';
    }

    // Check if positive
    if (stepCount <= 0) {
      return 'Step count must be a positive number';
    }

    return null;
  }

  // ==========================================================================
  // Generic Validation
  // ==========================================================================

  /// Validates that a field is not empty.
  ///
  /// [value] The value to validate.
  /// [fieldName] The name of the field (used in error message).
  ///
  /// Returns an error message if validation fails, or `null` if valid.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates password confirmation matches the original password.
  ///
  /// [value] The confirmation password.
  /// [password] The original password to match against.
  ///
  /// Returns an error message if validation fails, or `null` if valid.
  static String? validatePasswordConfirmation(String? value, String? password) {
    // First check if empty
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    // Check if passwords match
    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates a minimum string length.
  ///
  /// [value] The value to validate.
  /// [minLength] The minimum required length.
  /// [fieldName] The name of the field (used in error message).
  ///
  /// Returns an error message if validation fails, or `null` if valid.
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

  /// Validates a maximum string length.
  ///
  /// [value] The value to validate.
  /// [maxLength] The maximum allowed length.
  /// [fieldName] The name of the field (used in error message).
  ///
  /// Returns an error message if validation fails, or `null` if valid.
  static String? validateMaxLength(
    String? value,
    int maxLength,
    String fieldName,
  ) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be at most $maxLength characters';
    }
    return null;
  }
}
