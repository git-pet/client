import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/friend.dart';
import 'package:client/models/pet_state.dart';
import 'package:client/services/friends_service.dart';
import 'package:client/ui/widgets/friend_pet_card.dart';
import 'package:flutter/material.dart';

class FriendDetailPage extends StatefulWidget {
  const FriendDetailPage({
    super.key,
    required this.friendship,
    this.pet,
  });

  final Friendship friendship;
  // FriendsTab이 loadFriendsPets 배치 응답에서 뽑아 넘겨준다.
  // room_visibility='private' 인 친구는 서버가 응답에서 아예 제외하므로,
  // accepted 관계지만 null 로 들어올 수 있다.
  final FriendPetEntry? pet;

  @override
  State<FriendDetailPage> createState() => _FriendDetailPageState();
}

// - loading: pull-to-refresh 중.
// - ready: pet 있음.
// - private: friends-pets 응답에 없음 (= room_visibility private).
// - error: 재로드 실패.
enum _PetLoadStatus { loading, ready, private, error }

class _FriendDetailPageState extends State<FriendDetailPage> {
  final FriendsService _service = FriendsService();

  late _PetLoadStatus _status;
  PetState? _petState;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _petState = widget.pet?.pet;
    _status =
        _petState != null ? _PetLoadStatus.ready : _PetLoadStatus.private;
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() {
      _status = _PetLoadStatus.loading;
      _errorMessage = null;
    });
    try {
      final response = await _service.loadFriendsPets();
      if (!mounted) return;
      final friendId = widget.friendship.otherUser.id;
      FriendPetEntry? entry;
      for (final e in response.friends) {
        if (e.userId == friendId) {
          entry = e;
          break;
        }
      }
      setState(() {
        _petState = entry?.pet;
        _status =
            entry != null ? _PetLoadStatus.ready : _PetLoadStatus.private;
      });
    } on FriendsAuthRequiredException {
      if (!mounted) return;
      setState(() {
        _status = _PetLoadStatus.error;
        _errorMessage = AppLocalizations.of(context).homeSessionExpired;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = _PetLoadStatus.error;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final user = widget.friendship.otherUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.friendDetailTitle(user.username)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              _ProfileHeader(user: user),
              const SizedBox(height: 20),
              _buildPetSection(theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetSection(ThemeData theme, AppLocalizations l10n) {
    switch (_status) {
      case _PetLoadStatus.loading:
        return _PetSectionShell(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(
                l10n.friendDetailPetLoading,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        );
      case _PetLoadStatus.private:
        // TODO(profile): 이 분기는 서버 필터(room_visibility='private') 결과지만
        //   지금은 사용자가 자기 값을 바꿀 수단이 앱에 없다. 프로필 편집
        //   화면 붙는 시점에 friends_service.dart 의 TODO(profile) 와 함께
        //   실서비스 흐름으로 트리거 가능해진다.
        return _PetSectionShell(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: theme.colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.friendDetailPetPrivate,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      case _PetLoadStatus.error:
        return _PetSectionShell(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.friendDetailPetError,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _refresh,
                child: Text(l10n.friendDetailRetry),
              ),
            ],
          ),
        );
      case _PetLoadStatus.ready:
        final state = _petState;
        if (state == null) return const SizedBox.shrink();
        return FriendPetCard(state: state);
    }
  }
}

class _PetSectionShell extends StatelessWidget {
  const _PetSectionShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Center(child: child),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserSummary user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _Avatar(url: user.avatarUrl, fallback: user.username),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.bio!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white60,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              size: 16,
              color: Colors.white70,
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
        radius: 28,
        backgroundColor: colors.primary.withValues(alpha: 0.18),
        backgroundImage: NetworkImage(url!),
      );
    }
    final letter = fallback.isEmpty
        ? '?'
        : fallback.characters.first.toUpperCase();
    return CircleAvatar(
      radius: 28,
      backgroundColor: colors.primary.withValues(alpha: 0.18),
      child: Text(
        letter,
        style: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    );
  }
}
