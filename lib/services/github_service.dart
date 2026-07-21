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

class GithubTokenRefreshException implements Exception {
  const GithubTokenRefreshException(this.reason);
  final String reason;
  @override
  String toString() => 'GithubTokenRefreshException: $reason';
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

  // Supabase Edge Function `refresh-github-token` 을 호출해 GitHub OAuth
  // access token 을 갱신한다. 함수는 client_secret 을 보관하고 있고,
  // 클라이언트는 저장해둔 refresh token 만 넘긴다.
  //
  // 성공 시 새 access token (+ 있으면 refresh token) 을 SecureStorage 에 덮어쓴다.
  // 실패 원인은 [GithubTokenRefreshException]으로 감싸서 던진다.
  Future<void> refreshAccessToken() async {
    final storage = SecureStorage();
    final refreshToken = await storage.read(
      SecureStorageKey.githubRefreshToken,
    );
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const GithubTokenRefreshException('missing_refresh_token');
    }

    final supabase = Supabase.instance.client;
    final FunctionResponse response;
    try {
      response = await supabase.functions.invoke(
        'refresh-github-token',
        body: {'refresh_token': refreshToken},
      );
    } on FunctionException catch (error) {
      throw GithubTokenRefreshException(
        error.reasonPhrase ?? 'function_error_${error.status}',
      );
    }

    if (response.status != 200) {
      throw GithubTokenRefreshException('bad_status_${response.status}');
    }
    final data = response.data;
    if (data is! Map) {
      throw const GithubTokenRefreshException('invalid_response_shape');
    }
    final newAccess = data['access_token']?.toString();
    if (newAccess == null || newAccess.isEmpty) {
      throw const GithubTokenRefreshException('access_token_missing');
    }
    final newRefresh = data['refresh_token']?.toString();

    await storage.write(SecureStorageKey.githubAccessToken, newAccess);
    if (newRefresh != null && newRefresh.isNotEmpty) {
      await storage.write(SecureStorageKey.githubRefreshToken, newRefresh);
    }
  }
}
