import '../constants/app_constants.dart';

/// Input validation utilities.
///
/// Provides validation methods for common input types used in forms.
/// Returns null for valid input, or an error message string for invalid input.
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  /// Regular expression for validating email format
  static final RegExp _emailRegex = RegExp(r'^\S+@\S+\.\S+$');

  /// Regular expression for validating date format (YYYY-MM-DD)
  static final RegExp _dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// Regular expression for validating username format (alphanumeric and underscores)
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  /// Validate an email address.
  ///
  /// Returns null if valid, or an error message if invalid.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final trimmed = value.trim();
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate a password.
  ///
  /// Returns null if valid, or an error message if invalid.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  /// Validate a password confirmation.
  ///
  /// Returns null if valid, or an error message if invalid.
  static String? validateConfirmPassword(String? value, String password) {
    final passwordError = validatePassword(value);
    if (passwordError != null) {
      return passwordError;
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate a username.
  ///
  /// Returns null if valid, or an error message if invalid.
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < AppConstants.minUsernameLength) {
      return 'Username must be at least ${AppConstants.minUsernameLength} characters';
    }
    if (trimmed.length > AppConstants.maxUsernameLength) {
      return 'Username cannot exceed ${AppConstants.maxUsernameLength} characters';
    }
    if (!_usernameRegex.hasMatch(trimmed)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  /// Validate a step count value.
  ///
  /// Returns null if valid, or an error message if invalid.
  static String? validateStepCount(int? value) {
    if (value == null) {
      return 'Step count is required';
    }
    if (value < 0) {
      return 'Step count cannot be negative';
    }
    if (value > AppConstants.maxStepsPerDay) {
      return 'Step count exceeds maximum allowed';
    }
    return null;
  }

  /// Validate a required field.
  ///
  /// Returns null if valid, or an error message if invalid.
  static String? validateRequired(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Check if a date string is in valid format (YYYY-MM-DD).
  static bool isValidDateFormat(String date) {
    if (!_dateRegex.hasMatch(date)) {
      return false;
    }
    // Additional validation for actual date validity
    try {
      final parts = date.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final parsedDate = DateTime(year, month, day);
      // Check if the parsed date matches the input
      return parsedDate.year == year &&
          parsedDate.month == month &&
          parsedDate.day == day;
    } catch (_) {
      return false;
    }
  }

  /// Validate a date string.
  ///
  /// Returns null if valid, or an error message if invalid.
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    if (!isValidDateFormat(value)) {
      return 'Please enter a valid date (YYYY-MM-DD)';
    }
    return null;
  }

  /// Check if a string is a valid positive integer.
  static bool isPositiveInteger(String value) {
    final number = int.tryParse(value);
    return number != null && number > 0;
  }

  /// Check if an email format is valid.
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  /// Check if a username format is valid.
  static bool isValidUsername(String username) {
    final trimmed = username.trim();
    return trimmed.length >= AppConstants.minUsernameLength &&
        trimmed.length <= AppConstants.maxUsernameLength &&
        _usernameRegex.hasMatch(trimmed);
  }
}
