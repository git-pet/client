import 'dart:async';

import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/friend.dart';
import 'package:client/models/pet_state.dart';
import 'package:client/services/friends_service.dart';
import 'package:client/ui/pages/friend_detail.dart';
import 'package:client/ui/theme/app_theme.dart';
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
  // friends-pets 응답을 user_id -> entry 로 인덱싱.
  // 서버는 room_visibility='private' 인 친구를 제외하므로,
  // accepted 인 관계이지만 여기 없는 케이스가 존재할 수 있다 (= 비공개).
  Map<String, FriendPetEntry> _petsByUserId = const {};

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
      // friendships 목록과 친구 펫 상태를 병렬 로드.
      // friends-pets 실패는 치명적이지 않다 — 목록은 살리고 뱃지만 비운다.
      final results = await Future.wait<Object>([
        _service.loadFriends(),
        _service.loadFriendsPets().catchError(
          (Object _) => const FriendsPetsResponse(friends: []),
        ),
      ]);
      if (!mounted) return;
      final data = results[0] as FriendsData;
      final pets = results[1] as FriendsPetsResponse;
      setState(() {
        _data = data;
        _petsByUserId = {for (final e in pets.friends) e.userId: e};
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

  // 받은 요청 거절 — soft reject(status='rejected'). 이력 보존.
  Future<void> _reject(Friendship f) async {
    try {
      await _service.rejectRequest(f.id);
      await _load();
    } catch (error) {
      if (!mounted) return;
      _toast(error.toString());
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
            content: Text(l10n.friendsRemoveConfirmBody(f.otherUser.username)),
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

  Future<void> _openFriendDetail(Friendship f) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            FriendDetailPage(friendship: f, pet: _petsByUserId[f.otherUser.id]),
      ),
    );
  }

  Future<void> _openAddFriend() async {
    final data = _data;
    if (data == null) return;
    await showModalBottomSheet<void>(
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
          child: _AddFriendSheet(service: _service, initialData: data),
        );
      },
    );
    // 시트 안에서 어떤 액션을 했든 닫히면 메인 목록을 새로고침.
    if (mounted) await _load();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                  color: colors.appOnSurfaceSubtle,
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
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.appOnSurfaceSubtle,
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
    final colors = theme.colorScheme;
    final data = _data;
    final isEmpty =
        data == null ||
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
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.friendsAddTitle,
              onPressed: _data == null ? null : _openAddFriend,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              color: colors.onSurface,
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
                  color: colors.appOnSurfaceSubtle,
                  height: 1.5,
                ),
              ),
            ),
          )
        else
          Expanded(child: _buildFriendsList(data)),
      ],
    );
  }

  Widget _buildFriendsList(FriendsData visibleData) {
    final l10n = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (visibleData.incoming.isNotEmpty) ...[
            _SectionHeader(label: l10n.friendsSectionIncoming),
            ...visibleData.incoming.map(
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
                    onTap: () => _reject(f),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (visibleData.friends.isNotEmpty) ...[
            _SectionHeader(label: l10n.friendsSectionFriends),
            ...visibleData.friends.map(
              (f) => _FriendRow(
                friendship: f,
                pet: _petsByUserId[f.otherUser.id],
                onTap: () => _openFriendDetail(f),
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
          if (visibleData.outgoing.isNotEmpty) ...[
            _SectionHeader(label: l10n.friendsSectionOutgoing),
            ...visibleData.outgoing.map(
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colors.appOnSurfaceMuted,
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
  const _FriendRow({
    required this.friendship,
    required this.actions,
    this.onTap,
    this.pet,
  });

  final Friendship friendship;
  final List<_RowAction> actions;
  final VoidCallback? onTap;
  final FriendPetEntry? pet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final user = friendship.otherUser;

    final content = Padding(
      padding: const EdgeInsets.all(12),
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
                    color: colors.onSurface,
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
                      color: colors.appOnSurfaceSubtle,
                    ),
                  ),
                if (pet != null) ...[
                  const SizedBox(height: 6),
                  _PetBadge(pet: pet!.pet),
                ],
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
                            : colors.appOnSurfaceMuted,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: colors.appSoftSurface,
        border: Border.all(color: colors.appPanelBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

class _PetBadge extends StatelessWidget {
  const _PetBadge({required this.pet});

  final PetState pet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_stageIcon(pet.stage), size: 14, color: colors.primary),
        const SizedBox(width: 4),
        Text(
          'Lv. ${pet.level}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // TODO(l10n): stage 라벨은 friend_pet_card와 함께 arb로 통합.
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
        style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _AddFriendSheet extends StatefulWidget {
  const _AddFriendSheet({required this.service, required this.initialData});

  final FriendsService service;
  final FriendsData initialData;

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
  late FriendsData _friendsData;

  @override
  void initState() {
    super.initState();
    _friendsData = widget.initialData;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // 검색 결과 유저와 현재 사용자 사이의 관계(있으면)를 찾는다.
  // pending/accepted만 _friendsData에 담겨 있으므로 rejected는 null로 취급된다.
  Friendship? _relationFor(String userId) {
    for (final f in _friendsData.incoming) {
      if (f.otherUser.id == userId) return f;
    }
    for (final f in _friendsData.outgoing) {
      if (f.otherUser.id == userId) return f;
    }
    for (final f in _friendsData.friends) {
      if (f.otherUser.id == userId) return f;
    }
    return null;
  }

  Future<void> _refreshRelations() async {
    try {
      final data = await widget.service.loadFriends();
      if (!mounted) return;
      setState(() => _friendsData = data);
    } catch (_) {
      // 관계 갱신 실패는 조용히 무시 — 시트가 닫힐 때 부모가 다시 로드한다.
    }
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

  // 액션 공통 래퍼: busy 표시 → 실행 → 관계 갱신 → 에러 토스트.
  Future<void> _runAction(
    String userId,
    Future<void> Function() action, {
    String? successMessage,
  }) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busyUserId = userId);
    try {
      await action();
      if (successMessage != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage)));
      }
      await _refreshRelations();
    } on FriendsAlreadyExistsException {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.friendsAlreadyExists)));
      }
    } on FriendsSelfRequestException {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.friendsSelfBlocked)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.friendsSendFailed(error.toString()))),
        );
      }
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
                  color: colors.appOnSurfaceDisabled,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.friendsAddTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onQueryChanged,
              style: TextStyle(color: colors.onSurface),
              decoration: InputDecoration(
                hintText: l10n.friendsSearchHint,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colors.appOnSurfaceSubtle,
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
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.appOnSurfaceSubtle,
          ),
        ),
      );
    }
    if (!_hasSearched) {
      return Center(
        child: Text(
          l10n.friendsSearchPrompt,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.appOnSurfaceSubtle,
          ),
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Text(
          l10n.friendsSearchEmpty,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.appOnSurfaceSubtle,
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final u = _results[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colors.appSoftSurface,
          ),
          child: Row(
            children: [
              _Avatar(url: u.avatarUrl, fallback: u.username),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  u.username,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildResultActions(u, colors, l10n),
            ],
          ),
        );
      },
    );
  }

  // 검색 결과의 관계 상태에 따라 버튼을 다르게 그린다.
  // 없음 → 추가 / 보낸요청 → 취소 / 받은요청 → 수락+거절 / 친구 → 삭제
  Widget _buildResultActions(
    UserSummary u,
    ColorScheme colors,
    AppLocalizations l10n,
  ) {
    if (_busyUserId == u.id) {
      return const SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final relation = _relationFor(u.id);

    if (relation == null) {
      // 관계 없음 → 친구 추가
      return FilledButton(
        onPressed: () => _runAction(
          u.id,
          () => widget.service.sendRequest(u.id),
          successMessage: l10n.friendsRequestSent,
        ),
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          minimumSize: const Size(0, 32),
        ),
        child: const Icon(Icons.person_add_alt_1_rounded, size: 18),
      );
    }

    if (relation.status == FriendshipStatus.accepted) {
      // 이미 친구 → 삭제
      return TextButton(
        onPressed: () => _runAction(
          u.id,
          () => widget.service.deleteFriendship(relation.id),
        ),
        style: TextButton.styleFrom(
          foregroundColor: colors.tertiary,
          minimumSize: const Size(0, 32),
        ),
        child: Text(l10n.friendsActionRemove),
      );
    }

    if (relation.isOutgoing) {
      // 내가 보낸 요청 → 취소
      return TextButton(
        onPressed: () => _runAction(
          u.id,
          () => widget.service.deleteFriendship(relation.id),
        ),
        style: TextButton.styleFrom(
          foregroundColor: colors.appOnSurfaceMuted,
          minimumSize: const Size(0, 32),
        ),
        child: Text(l10n.friendsActionCancel),
      );
    }

    // 상대가 보낸 요청 → 수락 + 거절
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton(
          onPressed: () =>
              _runAction(u.id, () => widget.service.acceptRequest(relation.id)),
          style: FilledButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(0, 32),
          ),
          child: Text(l10n.friendsActionAccept),
        ),
        TextButton(
          onPressed: () =>
              _runAction(u.id, () => widget.service.rejectRequest(relation.id)),
          style: TextButton.styleFrom(
            foregroundColor: colors.appOnSurfaceMuted,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 32),
          ),
          child: Text(l10n.friendsActionReject),
        ),
      ],
    );
  }
}
