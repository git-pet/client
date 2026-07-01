import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/pet.dart';
import 'package:client/ui/widgets/sheets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';

Future<PetType?> showPetSelectorSheet(
  BuildContext context, {
  required PetType currentPet,
}) {
  return showAppBottomSheet<PetType>(
    context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final colors = theme.colorScheme;
      final l10n = AppLocalizations.of(sheetContext);

      return SafeArea(
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SheetHandle(),
                  const SizedBox(height: 20),
                  Text(
                    l10n.homePetSelectorTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: PetType.values.length,
                      itemBuilder: (context, index) {
                        final pet = PetType.values[index];
                        final selected = pet == currentPet;
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
                              Icons.pets_rounded,
                              color: selected
                                  ? colors.primary
                                  : Colors.white54,
                            ),
                          ),
                          title: Text(
                            pet.displayName,
                            style: TextStyle(
                              color: selected ? colors.primary : Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            '${pet.frameSize}px',
                            style: const TextStyle(color: Colors.white38),
                          ),
                          trailing: selected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: colors.primary,
                                )
                              : null,
                          onTap: () => Navigator.of(sheetContext).pop(pet),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
