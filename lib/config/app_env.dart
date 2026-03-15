import 'package:flutter/services.dart';

class AppEnv {
  AppEnv._();

  static const _assetPath = 'assets/config/.env';
  static final Map<String, String> _values = <String, String>{};

  static Future<void> load() async {
    if (_values.isNotEmpty) {
      return;
    }

    final raw = await rootBundle.loadString(_assetPath);
    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }

      final separatorIndex = trimmed.indexOf('=');
      if (separatorIndex == -1) {
        continue;
      }

      final key = trimmed.substring(0, separatorIndex).trim();
      final value = trimmed.substring(separatorIndex + 1).trim();
      _values[key] = value;
    }
  }

  static String get supabaseUrl => _values['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => _values['SUPABASE_ANON_KEY'] ?? '';
  static String get supabaseRedirectUrl =>
      _values['SUPABASE_REDIRECT_URL'] ?? '';
}
