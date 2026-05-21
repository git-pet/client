import 'package:client/models/github_activity.dart';
import 'package:client/utils/secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GithubAuthRequiredException implements Exception {
  const GithubAuthRequiredException();
}

class GithubUserNotConfiguredException implements Exception {
  const GithubUserNotConfiguredException();
}

class GithubApiException implements Exception {
  const GithubApiException(this.statusCode);
  final int statusCode;
}

class GithubInvalidResponseException implements Exception {
  const GithubInvalidResponseException();
}

class GithubActivityFeed {
  const GithubActivityFeed({
    required this.login,
    required this.name,
    required this.activities,
  });

  final String login;
  final String name;
  final List<GithubActivity> activities;
}
// TODO(realtime): 활동 피드는 실시간 반영이 자연스러운 영역.
//   Supabase Realtime 구독(channel().onPostgresChanges)으로
//   전환할지 검토 필요. 지금은 webhook 인입 빈도가 낮을 거라 보고 단발 조회로 유지.
//
// 스키마: public.activities (event_type text, metadata jsonb, user_id uuid → users.id).
// 레포 이름 등 추가 정보는 metadata jsonb에서 꺼낸다 (GithubActivity._extractRepoName 참고).
class GithubService {
  static const _activitiesTable = 'activities';
  static const _columnEventType = 'event_type';
  static const _columnMetadata = 'metadata';
  static const _columnCreatedAt = 'created_at';
  static const _columnUserId = 'user_id';
  static const _activityFetchLimit = 20;

  Future<GithubActivityFeed> fetchPublicActivities() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw const GithubAuthRequiredException();
    }

    final storage = SecureStorage();
    final login = await storage.read(SecureStorageKey.githubLogin);
    if (login == null || login.isEmpty) {
      throw const GithubUserNotConfiguredException();
    }
    final name = await storage.read(SecureStorageKey.githubName);

    try {
      final rows = await supabase
          .from(_activitiesTable)
          .select(
            '$_columnEventType, $_columnMetadata, $_columnCreatedAt',
          )
          .eq(_columnUserId, user.id)
          .order(_columnCreatedAt, ascending: false)
          .limit(_activityFetchLimit);

      final activities = rows
          .whereType<Map<String, dynamic>>()
          .map(GithubActivity.fromSupabaseRow)
          .toList();

      return GithubActivityFeed(
        login: login,
        name: (name != null && name.isNotEmpty) ? name : login,
        activities: activities,
      );
    } on AuthException {
      throw const GithubAuthRequiredException();
    } on PostgrestException catch (error) {
      // RLS 위반 / JWT 만료 → 재로그인 유도.
      if (error.code == '42501' || error.code == 'PGRST301') {
        throw const GithubAuthRequiredException();
      }
      throw GithubApiException(int.tryParse(error.code ?? '') ?? 0);
    }
  }
}
