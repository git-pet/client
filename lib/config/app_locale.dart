import 'package:client/utils/secure_storage.dart';
import 'package:flutter/widgets.dart';

class AppLocale {
  AppLocale._();

  static final ValueNotifier<Locale?> notifier = ValueNotifier<Locale?>(null);

  static Future<void> load() async {
    final code = await SecureStorage().storage.read(
      key: SecureStorageKey.localeCode.name,
    );
    if (code != null && code.isNotEmpty) {
      notifier.value = Locale(code);
    }
  }

  static Future<void> setLocale(Locale? locale) async {
    final storage = SecureStorage().storage;
    if (locale == null) {
      await storage.delete(key: SecureStorageKey.localeCode.name);
    } else {
      await storage.write(
        key: SecureStorageKey.localeCode.name,
        value: locale.languageCode,
      );
    }
    notifier.value = locale;
  }
}
