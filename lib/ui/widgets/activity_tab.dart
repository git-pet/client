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
    case 'PushEvent':
      return l10n.activityTitlePush;
    case 'PullRequestEvent':
      return l10n.activityTitlePr;
    case 'IssuesEvent':
      return l10n.activityTitleIssue;
    case 'IssueCommentEvent':
      return l10n.activityTitleIssueComment;
    case 'PullRequestReviewEvent':
      return l10n.activityTitlePrReview;
    case 'WatchEvent':
      return l10n.activityTitleWatch;
    case 'CreateEvent':
      return l10n.activityTitleCreate;
    case 'ForkEvent':
      return l10n.activityTitleFork;
    default:
      return l10n.activityTitleDefault(type.replaceAll('Event', ''));
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
    case 'PushEvent':
      final commitCount = payload['size'];
      final commits = payload['commits'];
      if (commitCount is int && commitCount > 0) {
        if (commits is List && commits.isNotEmpty) {
          final firstCommit = commits.first;
          if (firstCommit is Map<String, dynamic>) {
            final message = firstCommit['message']?.toString().trim();
            if (message != null && message.isNotEmpty) {
              return l10n.activityDescPushWithMessage(repo, commitCount, message);
            }
          }
        }
        return l10n.activityDescPushCount(repo, commitCount);
      }
      return l10n.activityDescPushFallback(repo);
    case 'PullRequestEvent':
      final action = payload['action']?.toString() ?? 'updated';
      final pullRequest = payload['pull_request'];
      final title = pullRequest is Map<String, dynamic>
          ? pullRequest['title']?.toString()
          : null;
      return (title == null || title.isEmpty)
          ? l10n.activityDescPrNoTitle(repo, action)
          : l10n.activityDescPrWithTitle(repo, action, title);
    case 'IssuesEvent':
      final action = payload['action']?.toString() ?? 'updated';
      final issue = payload['issue'];
      final title = issue is Map<String, dynamic>
          ? issue['title']?.toString()
          : null;
      return (title == null || title.isEmpty)
          ? l10n.activityDescIssueNoTitle(repo, action)
          : l10n.activityDescIssueWithTitle(repo, action, title);
    case 'IssueCommentEvent':
      final issue = payload['issue'];
      final title = issue is Map<String, dynamic>
          ? issue['title']?.toString()
          : null;
      return (title == null || title.isEmpty)
          ? l10n.activityDescIssueCommentNoTitle(repo)
          : l10n.activityDescIssueCommentWithTitle(repo, title);
    case 'PullRequestReviewEvent':
      final review = payload['review'];
      final state = review is Map<String, dynamic>
          ? review['state']?.toString()
          : null;
      return l10n.activityDescPrReview(repo, state ?? 'submitted');
    case 'WatchEvent':
      return l10n.activityDescWatch(repo);
    case 'CreateEvent':
      final refType = payload['ref_type']?.toString() ?? 'resource';
      final ref = payload['ref']?.toString();
      return (ref == null || ref.isEmpty)
          ? l10n.activityDescCreateNoRef(repo, refType)
          : l10n.activityDescCreateWithRef(repo, refType, ref);
    case 'ForkEvent':
      return l10n.activityDescFork(repo);
    default:
      return repo;
  }
}

IconData _iconForActivity(String type) {
  switch (type) {
    case 'PushEvent':
      return Icons.upload_rounded;
    case 'PullRequestEvent':
      return Icons.merge_type_rounded;
    case 'IssuesEvent':
      return Icons.error_outline_rounded;
    case 'IssueCommentEvent':
      return Icons.chat_bubble_outline_rounded;
    case 'PullRequestReviewEvent':
      return Icons.rate_review_outlined;
    case 'WatchEvent':
      return Icons.star_border_rounded;
    case 'ForkEvent':
      return Icons.call_split_rounded;
    default:
      return Icons.bolt_rounded;
  }
}

Color _colorForActivity(String type) {
  switch (type) {
    case 'PushEvent':
      return const Color(0xFF4FC3F7);
    case 'PullRequestEvent':
      return const Color(0xFFB388FF);
    case 'IssuesEvent':
      return const Color(0xFFFF8A65);
    case 'IssueCommentEvent':
      return const Color(0xFF4DD0E1);
    case 'PullRequestReviewEvent':
      return const Color(0xFF81C784);
    case 'WatchEvent':
      return const Color(0xFFFFD54F);
    case 'CreateEvent':
      return const Color(0xFF00897B);
    case 'ForkEvent':
      return const Color(0xFFF06292);
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
