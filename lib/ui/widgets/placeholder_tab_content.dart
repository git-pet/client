import 'package:client/l10n/app_localizations.dart';
import 'package:client/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PlaceholderTabContent extends StatelessWidget {
  const PlaceholderTabContent({
    super.key,
    required this.label,
    required this.isExpanded,
    required this.contentConstraints,
  });

  final String label;
  final bool isExpanded;
  final BoxConstraints contentConstraints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: contentConstraints.maxHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              Text(
                l10n.homeTabPlaceholder(label),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.appOnSurfaceSubtle,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
