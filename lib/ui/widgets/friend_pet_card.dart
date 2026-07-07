import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/friend_pet_state.dart';
import 'package:client/models/pet.dart';
import 'package:client/ui/widgets/pet_level_bar.dart';
import 'package:client/ui/widgets/sprite_animator.dart';
import 'package:flutter/material.dart';

// PetRoomCard(홈 화면)와 동일한 그라디언트 배경/펫 스프라이트 재사용 흐름을
// 따르지만, 상세 화면에서는 상단에 프로필이 별도로 있으므로 타이틀은 생략하고
// 스프라이트 + 레벨/EXP 바 + 진화 단계 텍스트를 하나의 카드로 묶는다.
class FriendPetCard extends StatelessWidget {
  const FriendPetCard({super.key, required this.state});

  final FriendPetState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final sprite = petSprites[state.petType]?[PetMood.idle];

    return Container(
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
          Container(
            height: 200,
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
                  if (sprite != null)
                    Center(
                      child: SpriteAnimator(
                        assetPath: state.petType.spritePath(sprite.fileName),
                        frameCount: sprite.frameCount,
                        size: state.petType.frameSize <= 16 ? 64 : 96,
                        fps: 6,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.petType.displayName,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.friendDetailPetStage(state.stage),
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          PetLevelBar(
            level: state.level,
            exp: state.exp,
            nextLevelExp: state.nextLevelExp,
            progress: state.expProgress,
          ),
        ],
      ),
    );
  }
}
