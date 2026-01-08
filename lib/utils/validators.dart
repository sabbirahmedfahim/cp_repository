class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!value.contains('@') || !value.contains('.')) return 'Enter a valid email address';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) return 'URL is required';
    try {
      final uri = Uri.parse(value);
      if (!uri.isAbsolute) return 'Enter a valid URL (include http:// or https://)';
      return null;
    } catch (_) {
      return 'Enter a valid URL';
    }
  }
}