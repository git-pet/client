import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/friend_activity.dart';
import 'package:client/models/github_activity.dart';
import 'package:client/services/friends_service.dart';
import 'package:client/ui/widgets/activity_presentation.dart';
import 'package:flutter/material.dart';

class FriendActivityFeed extends StatefulWidget {
  const FriendActivityFeed({super.key, required this.service});

  final FriendsService service;

  @override
  State<FriendActivityFeed> createState() => _FriendActivityFeedState();
}

class _FriendActivityFeedState extends State<FriendActivityFeed> {
  static const _pageSize = 30;
  static const _loadMoreThreshold = 280.0;

  final ScrollController _scrollController = ScrollController();

  List<FriendActivity> _items = const [];
  String? _nextCursor;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String? _loadMoreError;

  bool get _hasMore => _nextCursor != null;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        !_hasMore ||
        _isInitialLoading ||
        _isLoadingMore) {
      return;
    }

    final position = _scrollController.position;
    if (position.extentAfter < _loadMoreThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadFirstPage({bool showSpinner = true}) async {
    if (!mounted) return;
    setState(() {
      _error = null;
      _loadMoreError = null;
      if (showSpinner) {
        _isInitialLoading = true;
      }
    });

    try {
      final page = await widget.service.fetchFriendFeed(limit: _pageSize);
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _nextCursor = page.nextCursor;
        _isInitialLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _messageForError(error);
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _refresh() {
    return _loadFirstPage(showSpinner: _items.isEmpty);
  }

  Future<void> _loadMore() async {
    final cursor = _nextCursor;
    if (cursor == null || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _loadMoreError = null;
    });

    try {
      final page = await widget.service.fetchFriendFeed(
        limit: _pageSize,
        cursor: cursor,
      );
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...page.items];
        _nextCursor = page.nextCursor;
        _isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadMoreError = _messageForError(error);
        _isLoadingMore = false;
      });
    }
  }

  String _messageForError(Object error) {
    final l10n = AppLocalizations.of(context);
    if (error is FriendsAuthRequiredException) {
      return l10n.homeSessionExpired;
    }
    if (error is FriendFeedInvalidResponseException) {
      return l10n.friendFeedInvalidResponse;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isInitialLoading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (_error != null && _items.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: constraints.maxHeight,
                  child: _FriendFeedError(
                    message: _error!,
                    onRetry: () => _loadFirstPage(),
                  ),
                ),
              ],
            ),
          );
        }

        if (_items.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: constraints.maxHeight,
                  child: _FriendFeedEmpty(message: l10n.friendFeedEmpty),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _items.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == _items.length) {
                return _FriendFeedFooter(
                  isLoading: _isLoadingMore,
                  hasMore: _hasMore,
                  error: _loadMoreError,
                  onRetry: _loadMore,
                );
              }
              return _FriendActivityRow(activity: _items[index]);
            },
          ),
        );
      },
    );
  }
}

class _FriendActivityRow extends StatelessWidget {
  const _FriendActivityRow({required this.activity});

  final FriendActivity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final accent = activityColorFor(activity.eventType);
    final githubActivity = GithubActivity(
      type: activity.eventType,
      repoName: activity.repoName,
      createdAt: activity.occurredAt,
      payload: null,
    );

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
          _FriendAvatar(url: activity.avatarUrl, fallback: activity.nickname),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        activity.nickname.isEmpty
                            ? l10n.friendFeedUnknownFriend
                            : activity.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (activity.xpAwarded > 0) ...[
                      const SizedBox(width: 8),
                      _XpBadge(xp: activity.xpAwarded),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  activityTitleFor(l10n, activity.eventType),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  activityDescriptionFor(l10n, githubActivity),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    height: 1.35,
                  ),
                ),
                if (activity.occurredAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    formatRelativeActivityTime(l10n, activity.occurredAt!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white38,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: accent.withValues(alpha: 0.18),
            ),
            child: Icon(
              activityIconFor(activity.eventType),
              color: accent,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendFeedFooter extends StatelessWidget {
  const _FriendFeedFooter({
    required this.isLoading,
    required this.hasMore,
    required this.error,
    required this.onRetry,
  });

  final bool isLoading;
  final bool hasMore;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.friendFeedLoadMoreError),
          ),
        ),
      );
    }

    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            l10n.friendFeedEnd,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
          ),
        ),
      );
    }

    return const SizedBox(height: 4);
  }
}

class _FriendFeedError extends StatelessWidget {
  const _FriendFeedError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.friendFeedLoadError,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white60,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: Text(l10n.friendFeedRetry)),
        ],
      ),
    );
  }
}

class _FriendFeedEmpty extends StatelessWidget {
  const _FriendFeedEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white60,
          height: 1.5,
        ),
      ),
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({this.url, required this.fallback});

  final String? url;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final backgroundColor = colors.primary.withValues(alpha: 0.18);
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: 21,
        backgroundColor: backgroundColor,
        backgroundImage: NetworkImage(url!),
      );
    }

    final letter = fallback.isEmpty
        ? '?'
        : fallback.characters.first.toUpperCase();
    return CircleAvatar(
      radius: 21,
      backgroundColor: backgroundColor,
      child: Text(
        letter,
        style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _XpBadge extends StatelessWidget {
  const _XpBadge({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.primary.withValues(alpha: 0.14),
      ),
      child: Text(
        l10n.friendFeedXp(xp),
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
