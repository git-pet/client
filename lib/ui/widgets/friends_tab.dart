import 'dart:async';

import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/friend.dart';
import 'package:client/services/friends_service.dart';
import 'package:flutter/material.dart';

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key, required this.isExpanded});

  final bool isExpanded;

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  final FriendsService _service = FriendsService();

  bool _isLoading = true;
  String? _error;
  FriendsData? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.loadFriends();
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } on FriendsAuthRequiredException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = AppLocalizations.of(context).homeSessionExpired;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _accept(Friendship f) async {
    try {
      await _service.acceptRequest(f.id);
      await _load();
    } catch (_) {
      if (!mounted) return;
      _toast(AppLocalizations.of(context).friendsAcceptFailed);
    }
  }

  Future<void> _delete(Friendship f, {bool confirm = false}) async {
    if (confirm) {
      final l10n = AppLocalizations.of(context);
      final ok = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(l10n.friendsRemoveConfirmTitle),
            content: Text(
              l10n.friendsRemoveConfirmBody(f.otherUser.username),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.friendsRemoveConfirmCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.friendsRemoveConfirmAccept),
              ),
            ],
          );
        },
      );
      if (ok != true) return;
    }

    try {
      await _service.deleteFriendship(f.id);
      await _load();
    } catch (error) {
      if (!mounted) return;
      _toast(error.toString());
    }
  }

  Future<void> _openAddFriend() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: _AddFriendSheet(service: _service),
        );
      },
    );
    if (added == true) {
      await _load();
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
            Icon(Icons.group_rounded, color: colors.primary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.friendsCollapsedHint,
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
              l10n.friendsLoadError,
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
            FilledButton(onPressed: _load, child: Text(l10n.friendsRetry)),
          ],
        ),
      );
    }

    // 동일하게 좁은 프레임 보호. ActivityTab과 같은 패턴.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight < 80) {
          return const SizedBox.shrink();
        }
        return _buildBody(theme, l10n);
      },
    );
  }

  Widget _buildBody(ThemeData theme, AppLocalizations l10n) {
    final data = _data;
    final isEmpty = data == null ||
        (data.friends.isEmpty &&
            data.incoming.isEmpty &&
            data.outgoing.isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.homeTabFriends,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.friendsAddTitle,
              onPressed: _openAddFriend,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isEmpty)
          Expanded(
            child: Center(
              child: Text(
                l10n.friendsEmpty,
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
              onRefresh: _load,
              child: ListView(
                children: [
                  if (data.incoming.isNotEmpty) ...[
                    _SectionHeader(label: l10n.friendsSectionIncoming),
                    ...data.incoming.map(
                      (f) => _FriendRow(
                        friendship: f,
                        actions: [
                          _RowAction(
                            label: l10n.friendsActionAccept,
                            primary: true,
                            onTap: () => _accept(f),
                          ),
                          _RowAction(
                            label: l10n.friendsActionReject,
                            onTap: () => _delete(f),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (data.friends.isNotEmpty) ...[
                    _SectionHeader(label: l10n.friendsSectionFriends),
                    ...data.friends.map(
                      (f) => _FriendRow(
                        friendship: f,
                        actions: [
                          _RowAction(
                            label: l10n.friendsActionRemove,
                            destructive: true,
                            onTap: () => _delete(f, confirm: true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (data.outgoing.isNotEmpty) ...[
                    _SectionHeader(label: l10n.friendsSectionOutgoing),
                    ...data.outgoing.map(
                      (f) => _FriendRow(
                        friendship: f,
                        actions: [
                          _RowAction(
                            label: l10n.friendsActionCancel,
                            onTap: () => _delete(f),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _RowAction {
  const _RowAction({
    required this.label,
    required this.onTap,
    this.primary = false,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool destructive;
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({required this.friendship, required this.actions});

  final Friendship friendship;
  final List<_RowAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final user = friendship.otherUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          _Avatar(url: user.avatarUrl, fallback: user.username),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.bio != null && user.bio!.isNotEmpty)
                  Text(
                    user.bio!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ...actions.map(
            (a) => Padding(
              padding: const EdgeInsets.only(left: 6),
              child: a.primary
                  ? FilledButton(
                      onPressed: a.onTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Text(a.label),
                    )
                  : TextButton(
                      onPressed: a.onTap,
                      style: TextButton.styleFrom(
                        foregroundColor: a.destructive
                            ? colors.tertiary
                            : Colors.white70,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Text(a.label),
                    ),
            ),
          ),
        ],
      ),
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
        radius: 22,
        backgroundColor: colors.primary.withValues(alpha: 0.18),
        backgroundImage: NetworkImage(url!),
      );
    }
    final letter = fallback.isEmpty
        ? '?'
        : fallback.characters.first.toUpperCase();
    return CircleAvatar(
      radius: 22,
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

class _AddFriendSheet extends StatefulWidget {
  const _AddFriendSheet({required this.service});

  final FriendsService service;

  @override
  State<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<_AddFriendSheet> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;
  List<UserSummary> _results = const [];
  String? _error;
  bool _hasSearched = false;
  String? _busyUserId;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _search(value);
    });
  }

  Future<void> _search(String query) async {
    if (!mounted) return;
    setState(() {
      _isSearching = true;
      _error = null;
      _hasSearched = query.trim().isNotEmpty;
    });
    try {
      final results = await widget.service.searchUsers(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _sendRequest(UserSummary target) async {
    final l10n = AppLocalizations.of(context);
    if (!mounted) return;
    setState(() => _busyUserId = target.id);
    try {
      await widget.service.sendRequest(target.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.friendsRequestSent)),
      );
      Navigator.of(context).pop(true);
    } on FriendsAlreadyExistsException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.friendsAlreadyExists)),
      );
    } on FriendsSelfRequestException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.friendsSelfBlocked)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.friendsSendFailed(error.toString())),
        ),
      );
    } finally {
      if (mounted) setState(() => _busyUserId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.friendsAddTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onQueryChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l10n.friendsSearchHint,
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320, minHeight: 80),
              child: _buildResults(theme, colors, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(
    ThemeData theme,
    ColorScheme colors,
    AppLocalizations l10n,
  ) {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60),
        ),
      );
    }
    if (!_hasSearched) {
      return Center(
        child: Text(
          l10n.friendsSearchPrompt,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Text(
          l10n.friendsSearchEmpty,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final u = _results[index];
        final isBusy = _busyUserId == u.id;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: Row(
            children: [
              _Avatar(url: u.avatarUrl, fallback: u.username),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  u.username,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              FilledButton(
                onPressed: isBusy ? null : () => _sendRequest(u),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 32),
                ),
                child: isBusy
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_alt_1_rounded, size: 18),
              ),
            ],
          ),
        );
      },
    );
  }
}
