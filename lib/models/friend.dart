enum FriendshipStatus { pending, accepted, rejected, blocked, unknown }

FriendshipStatus _statusFromString(String? raw) {
  switch (raw) {
    case 'pending':
      return FriendshipStatus.pending;
    case 'accepted':
      return FriendshipStatus.accepted;
    case 'rejected':
      return FriendshipStatus.rejected;
    case 'blocked':
      return FriendshipStatus.blocked;
    default:
      return FriendshipStatus.unknown;
  }
}

class UserSummary {
  const UserSummary({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.bio,
  });

  final String id;
  final String username;
  final String? avatarUrl;
  final String? bio;

  factory UserSummary.fromRow(Map<String, dynamic> row) {
    return UserSummary(
      id: row['id'].toString(),
      username: (row['username'] ?? '').toString(),
      avatarUrl: row['avatar_url']?.toString(),
      bio: row['bio']?.toString(),
    );
  }
}

class Friendship {
  const Friendship({
    required this.id,
    required this.status,
    required this.isOutgoing,
    required this.otherUser,
    required this.createdAt,
  });

  final String id;
  final FriendshipStatus status;
  // 현재 로그인 사용자가 requester인지 여부. 들어온 요청은 false.
  final bool isOutgoing;
  final UserSummary otherUser;
  final DateTime? createdAt;

  factory Friendship.fromRow(Map<String, dynamic> row, String currentUserId) {
    final requesterId = row['requester_id'].toString();
    final isOutgoing = requesterId == currentUserId;
    final otherRow = isOutgoing ? row['receiver'] : row['requester'];

    final createdAtRaw = row['created_at']?.toString();
    final createdAt = createdAtRaw == null
        ? null
        : DateTime.tryParse(createdAtRaw)?.toLocal();

    return Friendship(
      id: row['id'].toString(),
      status: _statusFromString(row['status']?.toString()),
      isOutgoing: isOutgoing,
      otherUser: UserSummary.fromRow(
        otherRow is Map<String, dynamic> ? otherRow : const {},
      ),
      createdAt: createdAt,
    );
  }
}

class FriendsData {
  const FriendsData({
    required this.friends,
    required this.incoming,
    required this.outgoing,
  });

  final List<Friendship> friends;
  final List<Friendship> incoming;
  final List<Friendship> outgoing;
}
