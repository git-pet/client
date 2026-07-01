import 'package:client/models/friend.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendsAuthRequiredException implements Exception {
  const FriendsAuthRequiredException();
}

class FriendsAlreadyExistsException implements Exception {
  const FriendsAlreadyExistsException();
}

class FriendsSelfRequestException implements Exception {
  const FriendsSelfRequestException();
}

class FriendsServiceException implements Exception {
  const FriendsServiceException(this.message);
  final String message;
  @override
  String toString() => message;
}

// TODO(realtime): 친구 요청/수락은 알림성이 강한 영역.
//   Supabase Realtime 구독(channel().onPostgresChanges)으로 전환 검토 필요.
//   지금은 진입/액션 후 단발 SELECT로 갱신.
class FriendsService {
  static const _friendshipsTable = 'friendships';
  static const _usersTable = 'users';

  // PostgREST 임베디드 셀렉트. FK가 friendships.requester_id → users.id,
  // friendships.receiver_id → users.id 로 정의돼 있어야 동작.
  static const _friendshipSelect =
      'id, status, requester_id, receiver_id, created_at, '
      'requester:requester_id(id, username, avatar_url, bio), '
      'receiver:receiver_id(id, username, avatar_url, bio)';

  Future<FriendsData> loadFriends() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw const FriendsAuthRequiredException();
    }

    try {
      final rows = await supabase
          .from(_friendshipsTable)
          .select(_friendshipSelect)
          .or('requester_id.eq.${user.id},receiver_id.eq.${user.id}')
          .order('created_at', ascending: false);

      final friendships = rows
          .whereType<Map<String, dynamic>>()
          .map((row) => Friendship.fromRow(row, user.id))
          .toList();

      return FriendsData(
        friends: friendships
            .where((f) => f.status == FriendshipStatus.accepted)
            .toList(),
        incoming: friendships
            .where((f) =>
                f.status == FriendshipStatus.pending && !f.isOutgoing)
            .toList(),
        outgoing: friendships
            .where((f) =>
                f.status == FriendshipStatus.pending && f.isOutgoing)
            .toList(),
      );
    } on AuthException {
      throw const FriendsAuthRequiredException();
    } on PostgrestException catch (error) {
      throw FriendsServiceException(error.message);
    }
  }

  Future<List<UserSummary>> searchUsers(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw const FriendsAuthRequiredException();
    }

    try {
      final rows = await supabase
          .from(_usersTable)
          .select('id, username, avatar_url, bio')
          .ilike('username', '%$trimmed%')
          .neq('id', user.id)
          .limit(20);

      return rows
          .whereType<Map<String, dynamic>>()
          .map(UserSummary.fromRow)
          .toList();
    } on PostgrestException catch (error) {
      throw FriendsServiceException(error.message);
    }
  }

  Future<void> sendRequest(String targetUserId) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw const FriendsAuthRequiredException();
    }
    if (targetUserId == user.id) {
      throw const FriendsSelfRequestException();
    }

    try {
      await supabase.from(_friendshipsTable).insert({
        'requester_id': user.id,
        'receiver_id': targetUserId,
        'status': 'pending',
      });
    } on PostgrestException catch (error) {
      // 23505: unique_violation — 이미 존재하는 친구/요청.
      if (error.code == '23505') {
        throw const FriendsAlreadyExistsException();
      }
      throw FriendsServiceException(error.message);
    }
  }

  Future<void> acceptRequest(String friendshipId) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw const FriendsAuthRequiredException();
    }

    try {
      await supabase
          .from(_friendshipsTable)
          .update({
            'status': 'accepted',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', friendshipId)
          .eq('receiver_id', user.id);
    } on PostgrestException catch (error) {
      throw FriendsServiceException(error.message);
    }
  }

  // 들어온 요청 거절 — row를 지우지 않고 status='rejected'로 보존.
  // 이력이 남아 있어야 추후 친구 추천 제외 / 재요청 차단 등으로 확장 가능.
  Future<void> rejectRequest(String friendshipId) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw const FriendsAuthRequiredException();
    }

    try {
      await supabase
          .from(_friendshipsTable)
          .update({
            'status': 'rejected',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', friendshipId)
          .eq('receiver_id', user.id);
    } on PostgrestException catch (error) {
      throw FriendsServiceException(error.message);
    }
  }

  // 보낸 요청 취소 / 친구 삭제 — row 자체를 삭제.
  Future<void> deleteFriendship(String friendshipId) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw const FriendsAuthRequiredException();
    }

    try {
      await supabase
          .from(_friendshipsTable)
          .delete()
          .eq('id', friendshipId)
          .or('requester_id.eq.${user.id},receiver_id.eq.${user.id}');
    } on PostgrestException catch (error) {
      throw FriendsServiceException(error.message);
    }
  }
}
