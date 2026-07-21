import 'package:client/models/pet_state.dart';
import 'package:client/ui/widgets/pet_level_bar.dart';
import 'package:flutter/material.dart';

// 홈의 PetRoomCard와 동일한 그라디언트 배경/카드 구조를 재사용하지만,
// friends-pets 응답에는 pet-type이 포함되지 않아 SpriteAnimator를 그릴 수
// 없다. 그래서 스프라이트 자리는 진화 단계(PetStage) 기반 아이콘으로 대체한다.
// TODO(social): pet-type이 응답 스키마에 추가되면 SpriteAnimator로 되돌린다.
class FriendPetCard extends StatelessWidget {
  const FriendPetCard({super.key, required this.state});

  final PetState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
            child: Center(
              child: Icon(
                _stageIcon(state.stage),
                size: 96,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _stageLabel(state.stage),
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          PetLevelBar(
            level: state.level,
            exp: state.expInLevel,
            nextLevelExp: state.nextLevelExp,
            progress: state.progress,
          ),
        ],
      ),
    );
  }

  // TODO(l10n): stage 라벨을 arb로 옮긴다. 지금은 서버 enum 값을 그대로 노출.
  String _stageLabel(PetStage stage) {
    switch (stage) {
      case PetStage.egg:
        return 'Egg';
      case PetStage.baby:
        return 'Baby';
      case PetStage.adult:
        return 'Adult';
      case PetStage.expert:
        return 'Expert';
      case PetStage.legend:
        return 'Legend';
    }
  }

  IconData _stageIcon(PetStage stage) {
    switch (stage) {
      case PetStage.egg:
        return Icons.egg_alt_rounded;
      case PetStage.baby:
        return Icons.child_care_rounded;
      case PetStage.adult:
        return Icons.pets_rounded;
      case PetStage.expert:
        return Icons.star_rounded;
      case PetStage.legend:
        return Icons.workspace_premium_rounded;
    }
  }
}
