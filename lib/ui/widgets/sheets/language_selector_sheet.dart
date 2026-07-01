import 'package:client/config/app_locale.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:client/ui/widgets/sheets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';

const _supportedLanguageChoices = <Locale?>[
  null,
  Locale('ko'),
  Locale('en'),
];

String localeLabel(AppLocalizations l10n, Locale? locale) {
  if (locale == null) return l10n.homeLanguageSystem;
  switch (locale.languageCode) {
    case 'ko':
      return '한국어';
    case 'en':
      return 'English';
    default:
      return locale.languageCode;
  }
}

Future<void> showLanguageSelectorSheet(BuildContext context) {
  return showAppBottomSheet<void>(
    context,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final colors = theme.colorScheme;
      final l10n = AppLocalizations.of(sheetContext);

      return SafeArea(
        child: ValueListenableBuilder<Locale?>(
          valueListenable: AppLocale.notifier,
          builder: (context, currentLocale, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SheetHandle(),
                  const SizedBox(height: 20),
                  Text(
                    l10n.homeLanguageSelectorTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._supportedLanguageChoices.map((locale) {
                    final selected =
                        currentLocale?.languageCode == locale?.languageCode;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: selected
                              ? colors.primary.withValues(alpha: 0.25)
                              : colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.language_rounded,
                          color: selected ? colors.primary : Colors.white54,
                        ),
                      ),
                      title: Text(
                        localeLabel(l10n, locale),
                        style: TextStyle(
                          color: selected ? colors.primary : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: selected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: colors.primary,
                            )
                          : null,
                      onTap: () async {
                        await AppLocale.setLocale(locale);
                        if (!sheetContext.mounted) return;
                        Navigator.of(sheetContext).pop();
                      },
                    );
                  }),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
