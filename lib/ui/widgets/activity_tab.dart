import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/github_activity.dart';
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
                  final accent = _colorForActivity(activity.type);
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.22),
                      ),
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
                            _iconForActivity(activity.type),
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
                                _titleForActivity(l10n, activity.type),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _descriptionForActivity(l10n, activity),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
                              ),
                              if (activity.createdAt != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _formatRelativeTime(l10n, activity.createdAt!),
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

String _titleForActivity(AppLocalizations l10n, String type) {
  switch (type) {
    case 'commit':
      return l10n.activityTitleCommit;
    case 'pull_request':
      return l10n.activityTitlePullRequest;
    case 'issue':
      return l10n.activityTitleIssue;
    case 'code_review':
      return l10n.activityTitleCodeReview;
    case 'star':
      return l10n.activityTitleStar;
    case 'fork':
      return l10n.activityTitleFork;
    case 'release':
      return l10n.activityTitleRelease;
    default:
      return l10n.activityTitleDefault(type);
  }
}

String _descriptionForActivity(
  AppLocalizations l10n,
  GithubActivity activity,
) {
  final repo = activity.repoName.isEmpty
      ? l10n.homeUnknownRepo
      : activity.repoName;
  final payload = activity.payload;
  if (payload == null) {
    return repo;
  }

  switch (activity.type) {
    case 'commit':
      // webhook 적재 시 commits 배열을 그대로 보관한다고 가정. size 필드도 있을 수 있음.
      final commits = payload['commits'];
      final commitCount = payload['size'] is int
          ? payload['size'] as int
          : (commits is List ? commits.length : 0);
      if (commitCount > 0) {
        if (commits is List && commits.isNotEmpty) {
          final firstCommit = commits.first;
          if (firstCommit is Map<String, dynamic>) {
            final message = firstCommit['message']?.toString().trim();
            if (message != null && message.isNotEmpty) {
              return l10n.activityDescCommitWithMessage(repo, commitCount, message);
            }
          }
        }
        return l10n.activityDescCommitCount(repo, commitCount);
      }
      return l10n.activityDescCommitFallback(repo);
    case 'pull_request':
      final action = payload['action']?.toString() ?? 'updated';
      final pullRequest = payload['pull_request'];
      final title = pullRequest is Map<String, dynamic>
          ? pullRequest['title']?.toString()
          : null;
      return (title == null || title.isEmpty)
          ? l10n.activityDescPullRequestNoTitle(repo, action)
          : l10n.activityDescPullRequestWithTitle(repo, action, title);
    case 'issue':
      final action = payload['action']?.toString() ?? 'updated';
      final issue = payload['issue'];
      final title = issue is Map<String, dynamic>
          ? issue['title']?.toString()
          : null;
      return (title == null || title.isEmpty)
          ? l10n.activityDescIssueNoTitle(repo, action)
          : l10n.activityDescIssueWithTitle(repo, action, title);
    case 'code_review':
      final review = payload['review'];
      final state = review is Map<String, dynamic>
          ? review['state']?.toString()
          : null;
      return l10n.activityDescCodeReview(repo, state ?? 'submitted');
    case 'star':
      return l10n.activityDescStar(repo);
    case 'fork':
      return l10n.activityDescFork(repo);
    case 'release':
      final release = payload['release'];
      final tag = release is Map<String, dynamic>
          ? (release['tag_name'] ?? release['name'])?.toString()
          : null;
      return (tag == null || tag.isEmpty)
          ? l10n.activityDescReleaseNoTag(repo)
          : l10n.activityDescReleaseWithTag(repo, tag);
    default:
      return repo;
  }
}

IconData _iconForActivity(String type) {
  switch (type) {
    case 'commit':
      return Icons.upload_rounded;
    case 'pull_request':
      return Icons.merge_type_rounded;
    case 'issue':
      return Icons.error_outline_rounded;
    case 'code_review':
      return Icons.rate_review_outlined;
    case 'star':
      return Icons.star_border_rounded;
    case 'fork':
      return Icons.call_split_rounded;
    case 'release':
      return Icons.local_offer_outlined;
    default:
      return Icons.bolt_rounded;
  }
}

Color _colorForActivity(String type) {
  switch (type) {
    case 'commit':
      return const Color(0xFF4FC3F7);
    case 'pull_request':
      return const Color(0xFFB388FF);
    case 'issue':
      return const Color(0xFFFF8A65);
    case 'code_review':
      return const Color(0xFF81C784);
    case 'star':
      return const Color(0xFFFFD54F);
    case 'fork':
      return const Color(0xFFF06292);
    case 'release':
      return const Color(0xFF00897B);
    default:
      return const Color(0xFFB0BEC5);
  }
}

String _formatRelativeTime(AppLocalizations l10n, DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);
  if (difference.inMinutes < 1) {
    return l10n.relativeJustNow;
  }
  if (difference.inHours < 1) {
    return l10n.relativeMinutes(difference.inMinutes);
  }
  if (difference.inDays < 1) {
    return l10n.relativeHours(difference.inHours);
  }
  if (difference.inDays < 30) {
    return l10n.relativeDays(difference.inDays);
  }
  final month = (difference.inDays / 30).floor();
  if (month < 12) {
    return l10n.relativeMonths(month);
  }
  final year = (difference.inDays / 365).floor();
  return l10n.relativeYears(year);
}
