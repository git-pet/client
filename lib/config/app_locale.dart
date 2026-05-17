import 'package:client/utils/secure_storage.dart';
import 'package:flutter/widgets.dart';

class AppLocale {
  AppLocale._();

  static final ValueNotifier<Locale?> notifier = ValueNotifier<Locale?>(null);

  static Future<void> load() async {
    final code = await SecureStorage().read(SecureStorageKey.localeCode);
    if (code != null && code.isNotEmpty) {
      notifier.value = Locale(code);
    }
  }

  static Future<void> setLocale(Locale? locale) async {
    final storage = SecureStorage();
    if (locale == null) {
      await storage.delete(SecureStorageKey.localeCode);
    } else {
      await storage.write(SecureStorageKey.localeCode, locale.languageCode);
    }
    notifier.value = locale;
  }
}
