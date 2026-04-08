class Validators {
  Validators._();

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!re.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Must contain an uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(v)) return 'Must contain a lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Must contain a digit';
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) {
      return 'Must contain a special character';
    }
    return null;
  }

  static String? required(String? v, {String label = 'This field'}) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? positiveNumber(String? v, {String label = 'Value'}) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    final n = num.tryParse(v.trim());
    if (n == null) return '$label must be a number';
    if (n < 0) return '$label must be positive';
    return null;
  }
}
