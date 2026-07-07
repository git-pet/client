import 'package:client/models/pet.dart';

// TODO(social): code kim의 친구 펫 상태 조회 Edge Function 응답 스키마 확정 후
//  fromJson 본체를 채우고 필요한 필드를 추가한다. 현재는 UI/라우팅/에러 경로
//  검증용 스텁이며, 실제 데이터 표시 경로는 열려 있지 않다(FriendsService
//  쪽에서 FriendPetStateUnavailableException을 항상 던진다).
class FriendPetState {
  const FriendPetState({
    required this.petType,
    required this.level,
    required this.exp,
    required this.nextLevelExp,
    required this.stage,
  });

  final PetType petType;
  final int level;
  final int exp;
  final int nextLevelExp;
  final int stage;

  double get expProgress {
    if (nextLevelExp <= 0) return 0;
    return (exp / nextLevelExp).clamp(0.0, 1.0);
  }

  factory FriendPetState.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError(
      'FriendPetState.fromJson: 백엔드 응답 스키마 확정 대기',
    );
  }
}
