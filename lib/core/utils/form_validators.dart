/// Form Validators - Centralized validation logic for all forms
/// Matches your web validation rules exactly
class FormValidators {
  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }

    // Email regex pattern (matches your web validation)
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(
      String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate Philippine phone number (matches your web validation)
  static String? validatePhilippinePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    // Philippine phone number format: +63XXXXXXXXXX or 09XXXXXXXXXX
    // Matches your web regex: /^(\+63|0)9\d{9}$/
    final philippinePhoneRegex = RegExp(r'^(\+63|0)9\d{9}$');

    if (!philippinePhoneRegex.hasMatch(value)) {
      return 'Please enter a valid Philippine phone number (e.g., 09171234567)';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? 'Please enter your $fieldName'
          : 'This field is required';
    }

    return null;
  }

  /// Validate name fields (first name, last name)
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }

    // Check for minimum length
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\s\-\']+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Validate PWD ID number
  static String? validatePwdId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your PWD ID number';
    }

    // Basic validation - you can make this more specific based on PWD ID format
    if (value.trim().length < 5) {
      return 'PWD ID number must be at least 5 characters';
    }

    return null;
  }

  /// Validate date field
  static String? validateDate(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? 'Please select the $fieldName'
          : 'Please select a date';
    }

    // Try to parse the date
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  /// Validate dropdown selection
  static String? validateDropdown(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please select your $fieldName';
    }

    return null;
  }
}
