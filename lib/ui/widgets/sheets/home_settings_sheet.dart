import 'package:client/config/app_locale.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/pet.dart';
import 'package:client/ui/widgets/sheets/app_bottom_sheet.dart';
import 'package:client/ui/widgets/sheets/language_selector_sheet.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

enum HomeSettingsAction { changePet, changeLanguage, logout }

Future<HomeSettingsAction?> showHomeSettingsSheet(
  BuildContext context, {
  required PetType currentPet,
}) {
  return showAppBottomSheet<HomeSettingsAction>(
    context,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final l10n = AppLocalizations.of(sheetContext);

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SheetHandle(),
              const SizedBox(height: 20),
              Text(
                l10n.homeSettingsTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.homeSettingsDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 20),
              if (kDebugMode) ...[
                _SettingsTile(
                  icon: Icons.pets_rounded,
                  title: l10n.homeSettingsPetChange,
                  subtitle: currentPet.displayName,
                  onTap: () => Navigator.of(sheetContext).pop(
                    HomeSettingsAction.changePet,
                  ),
                ),
                const Divider(color: Colors.white12),
              ],
              _SettingsTile(
                icon: Icons.language_rounded,
                title: l10n.homeSettingsLanguage,
                subtitle: localeLabel(l10n, AppLocale.notifier.value),
                onTap: () => Navigator.of(sheetContext).pop(
                  HomeSettingsAction.changeLanguage,
                ),
              ),
              const Divider(color: Colors.white12),
              _SettingsTile(
                icon: Icons.logout_rounded,
                title: l10n.homeSettingsLogout,
                subtitle: l10n.homeSettingsLogoutDescription,
                onTap: () => Navigator.of(sheetContext).pop(
                  HomeSettingsAction.logout,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: colors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.white38,
      ),
      onTap: onTap,
    );
  }
}
