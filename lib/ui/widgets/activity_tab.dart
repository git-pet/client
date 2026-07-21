import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/github_activity.dart';
import 'package:client/ui/widgets/activity_presentation.dart';
import 'package:flutter/material.dart';

class ActivityTab extends StatelessWidget {
  const ActivityTab({
    super.key,
    required this.isExpanded,
    required this.isLoading,
    required this.githubName,
    required this.githubLogin,
    required this.error,
    required this.activities,
    required this.onRetry,
  });

  final bool isExpanded;
  final bool isLoading;
  final String? githubName;
  final String? githubLogin;
  final String? error;
  final List<GithubActivity> activities;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    if (!isExpanded) {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insights_rounded, color: colors.primary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.homeActivityCollapsedHint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.homeActivityLoadError,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(l10n.homeActivityRetry),
            ),
          ],
        ),
      );
    }

    // 패널이 펼쳐지는 260ms 동안엔 가용 높이가 헤더(~68px)보다 작은 프레임이
    // 생긴다. 그 짧은 구간에선 헤더 렌더링을 건너뛰어 오버플로를 피한다.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight < 80) {
          return const SizedBox.shrink();
        }
        return _buildExpandedContent(context, theme, l10n);
      },
    );
  }

  Widget _buildExpandedContent(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          githubName ?? l10n.homeActivityDefaultName,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (githubLogin != null) ...[
          const SizedBox(height: 4),
          Text(
            l10n.homeActivityRecentSubtitle(githubLogin!),
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60),
          ),
        ],
        const SizedBox(height: 16),
        if (activities.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                l10n.homeActivityEmpty,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRetry,
              child: ListView.separated(
                itemCount: activities.length,
                separatorBuilder: (_, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  final accent = activityColorFor(activity.type);
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(color: accent.withValues(alpha: 0.22)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: accent.withValues(alpha: 0.18),
                          ),
                          child: Icon(
                            activityIconFor(activity.type),
                            color: accent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activityTitleFor(l10n, activity.type),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activityDescriptionFor(l10n, activity),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
                              ),
                              if (activity.createdAt != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  formatRelativeActivityTime(
                                    l10n,
                                    activity.createdAt!,
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
