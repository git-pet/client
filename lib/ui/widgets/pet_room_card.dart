import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/pet.dart';
import 'package:client/models/pet_state.dart';
import 'package:client/ui/theme/app_theme.dart';
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
    this.progress,
    this.isLoadingProgress = false,
    this.progressError,
    this.onRetryProgress,
  });

  final double height;
  final PetType petType;
  final SpriteInfo sprite;
  final PetMood mood;
  final bool showCollapseHint;
  final ValueChanged<PetMood> onMoodChanged;
  final VoidCallback onTap;
  // 서버 pet-progress 응답. null 이면 로드 전/실패 — 뱃지·진행바를 숨긴다.
  final PetState? progress;
  final bool isLoadingProgress;
  final String? progressError;
  final Future<void> Function()? onRetryProgress;

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
          colors: [colors.secondaryContainer, colors.surface, colors.surface],
        ),
        border: Border.all(color: colors.appPanelBorder),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  l10n.homePetRoomTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (progress != null) _ProgressChip(state: progress!),
            ],
          ),
          const SizedBox(height: 10),
          if (progress != null)
            _ExpBar(state: progress!)
          else
            _ProgressStatus(
              isLoading: isLoadingProgress,
              error: progressError,
              onRetry: onRetryProgress,
            ),
          const SizedBox(height: 20),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: colors.appSofterSurface,
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
                          size: _spriteSize(petType, progress),
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

double _spriteSize(PetType petType, PetState? state) {
  final base = petType.frameSize <= 16 ? 64.0 : 96.0;
  if (state == null) return base;
  return base * (0.84 + state.stage.index * 0.08);
}

// stage 아이콘 + Lv.N 을 하나의 알약 형태로 표시한다.
// friend_pet_card / friends_tab 의 stage 아이콘 매핑과 동일하다.
// TODO(l10n): stage 라벨/아이콘 매핑은 여러 위젯에서 중복 중이라 통합 필요.
class _ProgressChip extends StatelessWidget {
  const _ProgressChip({required this.state});

  final PetState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_stageIcon(state.stage), size: 14, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            'Lv. ${state.level}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  static IconData _stageIcon(PetStage stage) {
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

// 얇은 EXP 진행 바. 현재 레벨 내 진행률 + "{expInLevel}/{nextLevelExp}" 라벨.
class _ExpBar extends StatelessWidget {
  const _ExpBar({required this.state});

  final PetState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: state.progress,
            minHeight: 6,
            backgroundColor: colors.onSurface.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation(colors.primary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${state.expInLevel} / ${state.nextLevelExp} XP',
          textAlign: TextAlign.right,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.appOnSurfaceSubtle,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _ProgressStatus extends StatelessWidget {
  const _ProgressStatus({
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final bool isLoading;
  final String? error;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final hasError = error != null;
    final iconColor = hasError ? colors.error : colors.primary;
    final message = isLoading
        ? l10n.homePetProgressLoading
        : hasError
        ? l10n.homePetProgressLoadError
        : l10n.homePetProgressEmpty;

    return Row(
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            ),
          )
        else
          Tooltip(
            message: error ?? message,
            child: Icon(
              hasError ? Icons.error_outline_rounded : Icons.info_rounded,
              size: 16,
              color: iconColor,
            ),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.appOnSurfaceSubtle,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (hasError && onRetry != null)
          IconButton(
            tooltip: l10n.homePetProgressRetry,
            onPressed: () => onRetry!(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            style: IconButton.styleFrom(
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: colors.error,
            ),
          ),
      ],
    );
  }
}
