// 서버 소스: git-pet/server development 브랜치
//   - GET /functions/v1/pet-progress → { level, exp, stage, mood }
//   - GET /functions/v1/friends-pets → { friends: [{ user_id, nickname, avatar,
//         level, exp, leveled_up, evolved, new_stage }] }
//
// 두 응답을 공용 PetState로 흡수한다. friends-pets는 스냅샷이라
// leveled_up/evolved 는 항상 false, new_stage 는 현재 stage와 같다.
// pet-progress 응답에는 leveled_up/evolved/new_stage 가 아예 없으므로
// PetState의 해당 필드는 기본값 false 로 채운다.
//
// XP 모델: 100 XP 당 1 레벨 (server 01_users_pets.sql 트리거 참조).
// progress/nextLevelExp 는 파생값이므로 서버가 별도 필드로 주지 않는다.

enum PetStage {
  egg,
  baby,
  adult,
  expert,
  legend;

  static PetStage fromApi(String? raw) {
    if (raw == null) return PetStage.egg;
    for (final stage in PetStage.values) {
      if (stage.name == raw) return stage;
    }
    return PetStage.egg;
  }
}

class PetState {
  const PetState({
    required this.level,
    required this.exp,
    required this.stage,
    this.mood,
    this.leveledUp = false,
    this.evolved = false,
  });

  final int level;
  // 누적 XP. 서버 pets.xp 값 그대로.
  final int exp;
  final PetStage stage;
  // pet-progress 응답에만 있고 friends-pets 응답에는 없다.
  final String? mood;
  final bool leveledUp;
  final bool evolved;

  static const int expPerLevel = 100;

  // 현재 레벨 안에서의 진행 XP (0 ~ expPerLevel - 1).
  int get expInLevel => exp % expPerLevel;

  // 이번 레벨을 채우는 데 필요한 총 XP.
  int get nextLevelExp => expPerLevel;

  // 0.0 ~ 1.0 진행률.
  double get progress => (expInLevel / expPerLevel).clamp(0.0, 1.0);

  factory PetState.fromPetProgressJson(Map<String, dynamic> json) {
    return PetState(
      level: (json['level'] as num?)?.toInt() ?? 1,
      exp: (json['exp'] as num?)?.toInt() ?? 0,
      stage: PetStage.fromApi(json['stage']?.toString()),
      mood: json['mood']?.toString(),
    );
  }

  factory PetState.fromFriendsPetsEntry(Map<String, dynamic> json) {
    return PetState(
      level: (json['level'] as num?)?.toInt() ?? 1,
      exp: (json['exp'] as num?)?.toInt() ?? 0,
      stage: PetStage.fromApi(json['new_stage']?.toString()),
      leveledUp: json['leveled_up'] == true,
      evolved: json['evolved'] == true,
    );
  }
}

// friends-pets 응답 배열의 각 요소. 유저 식별/표시 필드 + 펫 상태.
class FriendPetEntry {
  const FriendPetEntry({
    required this.userId,
    required this.nickname,
    required this.pet,
    this.avatarUrl,
  });

  final String userId;
  final String nickname;
  final String? avatarUrl;
  final PetState pet;

  factory FriendPetEntry.fromJson(Map<String, dynamic> json) {
    return FriendPetEntry(
      userId: json['user_id'].toString(),
      nickname: (json['nickname'] ?? '').toString(),
      avatarUrl: json['avatar']?.toString(),
      pet: PetState.fromFriendsPetsEntry(json),
    );
  }
}

class FriendsPetsResponse {
  const FriendsPetsResponse({required this.friends});

  final List<FriendPetEntry> friends;

  factory FriendsPetsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['friends'];
    if (list is! List) return const FriendsPetsResponse(friends: []);
    return FriendsPetsResponse(
      friends: list
          .whereType<Map<String, dynamic>>()
          .map(FriendPetEntry.fromJson)
          .toList(),
    );
  }
}
