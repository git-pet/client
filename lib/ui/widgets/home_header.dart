import 'package:client/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.isLoggingOut,
    required this.onOpenSettings,
  });

  final bool isLoggingOut;
  final Future<void> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withValues(alpha: 0.14),
            ),
            child: Icon(Icons.pets_rounded, color: colors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.homeAppTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: isLoggingOut ? null : onOpenSettings,
            style: IconButton.styleFrom(
              minimumSize: const Size(38, 38),
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white.withValues(alpha: 0.04),
              foregroundColor: Colors.white70,
            ),
            icon: isLoggingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.menu_rounded),
          ),
        ],
      ),
    );
  }
}
