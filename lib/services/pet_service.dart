import 'package:client/models/pet_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// pet-progress Edge Function 계약 (git-pet/server development 기준):
//   GET /functions/v1/pet-progress
//   응답: { level, exp, stage, mood }
//   XP 지급/증가는 서버 webhook 경로로만 이루어지며, 클라이언트는 조회 전용.

class PetAuthRequiredException implements Exception {
  const PetAuthRequiredException();
}

class PetServiceException implements Exception {
  const PetServiceException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PetService {
  Future<PetState> loadPetProgress() async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'pet-progress',
        method: HttpMethod.get,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PetState.fromPetProgressJson(data);
      }
      throw const PetServiceException('pet-progress 응답 형식 오류');
    } on AuthException {
      throw const PetAuthRequiredException();
    } on FunctionException catch (error) {
      if (error.status == 401) {
        throw const PetAuthRequiredException();
      }
      throw PetServiceException(
        error.details?.toString() ?? 'pet-progress 호출 실패 (${error.status})',
      );
    }
  }
}
