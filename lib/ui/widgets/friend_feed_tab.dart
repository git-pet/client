import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/friend_feed_item.dart';
import 'package:client/services/activity_service.dart';
import 'package:flutter/material.dart';

// 친구들의 최근 활동 스트림 (friend-feed Edge Function).
// keyset 커서 기반 무한 스크롤 + Pull-to-refresh.
class FriendFeedTab extends StatefulWidget {
  const FriendFeedTab({super.key, required this.isExpanded});

  final bool isExpanded;

  @override
  State<FriendFeedTab> createState() => _FriendFeedTabState();
}

class _FriendFeedTabState extends State<FriendFeedTab> {
  final ActivityService _service = ActivityService();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String? _nextCursor;
  List<FriendFeedItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  // 리스트 하단에 근접하면 다음 페이지 로드.
  void _onScroll() {
    if (_isLoadingMore || _nextCursor == null) return;
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (!mounted) return;
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final response = await _service.loadFriendFeed();
      if (!mounted) return;
      setState(() {
        _items = response.items;
        _nextCursor = response.nextCursor;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _nextCursor == null || !mounted) return;
    setState(() => _isLoadingMore = true);
    try {
      final response = await _service.loadFriendFeed(cursor: _nextCursor);
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...response.items];
        _nextCursor = response.nextCursor;
        _isLoadingMore = false;
      });
    } catch (_) {
      // 페이지 확장 실패는 조용히 무시 — 다음 스크롤에서 재시도.
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    if (!widget.isExpanded) {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dynamic_feed_rounded, color: colors.primary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.friendFeedCollapsedHint,
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

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
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
              _error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _load(reset: true),
              child: Text(l10n.friendFeedRetry),
            ),
          ],
        ),
      );
    }

    // 좁은 프레임 보호 (ActivityTab / FriendsTab 과 같은 패턴).
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight < 80) {
          return const SizedBox.shrink();
        }
        return _buildFeed(theme, l10n);
      },
    );
  }

  Widget _buildFeed(ThemeData theme, AppLocalizations l10n) {
    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _load(reset: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 60),
            Center(
              child: Text(
                l10n.friendFeedEmpty,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _items.length + (_nextCursor != null ? 1 : 0),
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return _FeedRow(item: _items[index]);
        },
      ),
    );
  }
}

class _FeedRow extends StatelessWidget {
  const _FeedRow({required this.item});

  final FriendFeedItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(url: item.avatarUrl, fallback: item.nickname),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: item.nickname,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const TextSpan(text: '  '),
                      TextSpan(
                        text: _titleForEvent(l10n, item.eventType),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (item.repoName != null && item.repoName!.isNotEmpty) ...[
                      Flexible(
                        child: Text(
                          item.repoName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      _Dot(),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '+${item.xpAwarded} XP',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (item.occurredAt != null) ...[
                      _Dot(),
                      Text(
                        _formatRelativeTime(l10n, item.occurredAt!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text('·', style: TextStyle(color: Colors.white38)),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url, required this.fallback});

  final String? url;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: colors.primary.withValues(alpha: 0.18),
        backgroundImage: NetworkImage(url!),
      );
    }
    final letter = fallback.isEmpty
        ? '?'
        : fallback.characters.first.toUpperCase();
    return CircleAvatar(
      radius: 20,
      backgroundColor: colors.primary.withValues(alpha: 0.18),
      child: Text(
        letter,
        style: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// TODO(l10n): activity_tab.dart 의 동일 매핑과 중복. 다음 리팩터에서 통합.
String _titleForEvent(AppLocalizations l10n, String type) {
  switch (type) {
    case 'commit':
      return l10n.activityTitleCommit;
    case 'pull_request':
      return l10n.activityTitlePullRequest;
    case 'code_review':
      return l10n.activityTitleCodeReview;
    case 'issue':
      return l10n.activityTitleIssue;
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

// TODO(l10n): activity_tab.dart 의 _formatRelativeTime 과 동일. 유틸로 이동.
String _formatRelativeTime(AppLocalizations l10n, DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);
  if (difference.inMinutes < 1) return l10n.relativeJustNow;
  if (difference.inHours < 1) return l10n.relativeMinutes(difference.inMinutes);
  if (difference.inDays < 1) return l10n.relativeHours(difference.inHours);
  if (difference.inDays < 30) return l10n.relativeDays(difference.inDays);
  final month = (difference.inDays / 30).floor();
  if (month < 12) return l10n.relativeMonths(month);
  final year = (difference.inDays / 365).floor();
  return l10n.relativeYears(year);
}
