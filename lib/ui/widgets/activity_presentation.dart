import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/github_activity.dart';
import 'package:flutter/material.dart';

String activityTitleFor(AppLocalizations l10n, String type) {
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

String activityDescriptionFor(AppLocalizations l10n, GithubActivity activity) {
  final repo = activity.repoName.isEmpty
      ? l10n.homeUnknownRepo
      : activity.repoName;
  final payload = activity.payload;
  if (payload == null) {
    return repo;
  }

  switch (activity.type) {
    case 'commit':
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
              return l10n.activityDescCommitWithMessage(
                repo,
                commitCount,
                message,
              );
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

IconData activityIconFor(String type) {
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

Color activityColorFor(String type) {
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

String formatRelativeActivityTime(AppLocalizations l10n, DateTime dateTime) {
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
