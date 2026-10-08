/// Form and Input Validators for AttendEase
class Validators {
  /// Validates that a string is not null or empty
  static String? requiredField(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates student full name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Student name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }
    final nameRegex = RegExp(r"^[a-zA-Z\s\.\'-]+$");
    if (!nameRegex.hasMatch(trimmed)) {
      return 'Enter a valid name (letters, spaces, dots, hyphens only)';
    }
    return null;
  }

  /// Validates roll number format
  static String? validateRollNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Roll number is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Roll number must be at least 2 characters';
    }
    final rollRegex = RegExp(r'^[a-zA-Z0-9_\-\/]+$');
    if (!rollRegex.hasMatch(trimmed)) {
      return 'Roll number must be alphanumeric (hyphens and slashes allowed)';
    }
    return null;
  }

  /// Validates password
  static String? validatePassword(String? value, {int minLength = 4}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validates class or department selection
  static String? validateClass(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Class / Section is required';
    }
    return null;
  }

  /// Validates leave reason
  static String? validateReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Reason is required';
    }
    if (value.trim().length < 5) {
      return 'Please provide a detailed reason (at least 5 characters)';
    }
    return null;
  }
}
