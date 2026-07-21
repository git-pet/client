// friend-feed Edge Function 응답 요소.
//   서버 계약 (git-pet/server development 기준):
//     items: [{
//       activity_id, user_id, nickname, avatar,
//       event_type, repo_name, occurred_at, xp_awarded
//     }],
//     next_cursor: string | null (opaque base64 — 클라는 그대로 다음 요청에 전달)

class FriendFeedItem {
  const FriendFeedItem({
    required this.activityId,
    required this.userId,
    required this.nickname,
    required this.eventType,
    required this.xpAwarded,
    this.avatarUrl,
    this.repoName,
    this.occurredAt,
  });

  final String activityId;
  final String userId;
  final String nickname;
  final String? avatarUrl;
  // 서버 CHECK 제약:
  //   'commit' | 'pull_request' | 'code_review' | 'issue' | 'star' | 'fork' | 'release'
  final String eventType;
  // metadata->>'repo' 에서 뽑히므로 null 가능.
  final String? repoName;
  final DateTime? occurredAt;
  final int xpAwarded;

  factory FriendFeedItem.fromJson(Map<String, dynamic> json) {
    final occurredRaw = json['occurred_at']?.toString();
    return FriendFeedItem(
      activityId: json['activity_id'].toString(),
      userId: json['user_id'].toString(),
      nickname: (json['nickname'] ?? '').toString(),
      avatarUrl: json['avatar']?.toString(),
      eventType: (json['event_type'] ?? '').toString(),
      repoName: json['repo_name']?.toString(),
      occurredAt: occurredRaw == null
          ? null
          : DateTime.tryParse(occurredRaw)?.toLocal(),
      xpAwarded: (json['xp_awarded'] as num?)?.toInt() ?? 0,
    );
  }
}

class FriendFeedResponse {
  const FriendFeedResponse({required this.items, this.nextCursor});

  final List<FriendFeedItem> items;
  // null 이면 다음 페이지 없음(끝).
  final String? nextCursor;

  factory FriendFeedResponse.fromJson(Map<String, dynamic> json) {
    final list = json['items'];
    return FriendFeedResponse(
      items: list is List
          ? list
                .whereType<Map<String, dynamic>>()
                .map(FriendFeedItem.fromJson)
                .toList()
          : const [],
      nextCursor: json['next_cursor']?.toString(),
    );
  }
}
