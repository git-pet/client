import 'package:client/models/pet.dart';
import 'package:flutter/material.dart';

class DebugMoodSelector extends StatelessWidget {
  const DebugMoodSelector({
    super.key,
    required this.current,
    required this.onChanged,
    required this.petType,
  });

  final PetMood current;
  final ValueChanged<PetMood> onChanged;
  final PetType petType;

  @override
  Widget build(BuildContext context) {
    final available =
        PetMood.values.where((m) => petSprites[petType]!.containsKey(m));

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: available.map((mood) {
        final selected = mood == current;
        return Material(
          color: selected
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onChanged(mood),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                mood.label,
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
