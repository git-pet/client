import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/pet.dart';
import 'package:client/ui/widgets/debug_mood_selector.dart';
import 'package:client/ui/widgets/sprite_animator.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

class PetRoomCard extends StatelessWidget {
  const PetRoomCard({
    super.key,
    required this.height,
    required this.petType,
    required this.sprite,
    required this.mood,
    required this.showCollapseHint,
    required this.onMoodChanged,
    required this.onTap,
  });

  final double height;
  final PetType petType;
  final SpriteInfo sprite;
  final PetMood mood;
  final bool showCollapseHint;
  final ValueChanged<PetMood> onMoodChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.secondaryContainer,
            colors.surface,
            colors.surface,
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homePetRoomTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withValues(alpha: 0.04),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/backgrounds/Classic/1.png',
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.none,
                        ),
                      ),
                      Center(
                        child: SpriteAnimator(
                          assetPath: petType.spritePath(sprite.fileName),
                          frameCount: sprite.frameCount,
                          size: petType.frameSize <= 16 ? 64 : 96,
                          fps: 6,
                        ),
                      ),
                      if (kDebugMode)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: DebugMoodSelector(
                            current: mood,
                            petType: petType,
                            onChanged: onMoodChanged,
                          ),
                        ),
                      if (showCollapseHint)
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Text(
                            l10n.homeTabCollapseHint,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white60,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
