class FriendActivity {
  const FriendActivity({
    required this.id,
    required this.userId,
    required this.nickname,
    this.avatarUrl,
    required this.eventType,
    required this.repoName,
    required this.occurredAt,
    required this.xpAwarded,
  });

  final String id;
  final String userId;
  final String nickname;
  final String? avatarUrl;
  final String eventType;
  final String repoName;
  final DateTime? occurredAt;
  final int xpAwarded;

  factory FriendActivity.fromJson(Map<String, dynamic> json) {
    final occurredAtRaw = json['occurred_at']?.toString();
    final occurredAt = occurredAtRaw == null
        ? null
        : DateTime.tryParse(occurredAtRaw)?.toLocal();

    return FriendActivity(
      id: json['activity_id'].toString(),
      userId: json['user_id'].toString(),
      nickname: (json['nickname'] ?? '').toString(),
      avatarUrl: json['avatar']?.toString(),
      eventType: (json['event_type'] ?? 'Event').toString(),
      repoName: (json['repo_name'] ?? '').toString(),
      occurredAt: occurredAt,
      xpAwarded: _intFromJson(json['xp_awarded']),
    );
  }
}

class FriendActivityPage {
  const FriendActivityPage({required this.items, required this.nextCursor});

  final List<FriendActivity> items;
  final String? nextCursor;
}

int _intFromJson(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
