import 'package:client/models/activity_stats.dart';
import 'package:client/models/friend_feed_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// backfill-user-activities Edge Function 계약
// (git-pet/server development 기준 README):
//   POST /functions/v1/backfill-user-activities
//   Body: { "days": 90, "limit": 300 }
//   호출자: 로그인/가입 성공 직후 Flutter 클라이언트.
//   멱등: users.backfilled_at + activities.github_event_id 로 서버가 보장하므로
//   재시도해도 안전하며 두 번째 호출부터는 no-op.
//
// 호출부는 fire-and-forget 으로 사용한다 — UI 흐름을 막지 않는다.

class ActivityAuthRequiredException implements Exception {
  const ActivityAuthRequiredException();
}

class ActivityServiceException implements Exception {
  const ActivityServiceException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ActivityService {
  // 지수 백오프 대기 시간. 초기 시도 뒤 이 지연들만큼씩 대기 후 재시도한다.
  //   1s → 3s → 10s. 총 최대 4회 시도(초회 + 3회 재시도).
  static const _retryDelays = <Duration>[
    Duration(seconds: 1),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];

  Future<void> backfillUserActivities({int days = 90, int limit = 300}) async {
    Object? lastError;
    for (var attempt = 0; attempt <= _retryDelays.length; attempt++) {
      try {
        await Supabase.instance.client.functions.invoke(
          'backfill-user-activities',
          body: {'days': days, 'limit': limit},
        );
        return;
      } on AuthException {
        // 401 계열은 재시도해도 무의미. 즉시 승격 후 종료.
        throw const ActivityAuthRequiredException();
      } on FunctionException catch (error) {
        if (error.status == 401) {
          throw const ActivityAuthRequiredException();
        }
        lastError = error;
      } catch (error) {
        lastError = error;
      }

      if (attempt < _retryDelays.length) {
        await Future.delayed(_retryDelays[attempt]);
      }
    }

    throw ActivityServiceException(
      lastError?.toString() ?? 'backfill-user-activities 재시도 후에도 실패',
    );
  }

  // friend-feed Edge Function 호출.
  //   응답: { items: [...], next_cursor: opaque-base64 | null }
  //   limit 은 서버가 [1, 100] 로 클램프한다. cursor 는 이전 호출의
  //   next_cursor 를 그대로 넘겨야 하며, null 이면 첫 페이지.
  Future<FriendFeedResponse> loadFriendFeed({
    int limit = 30,
    String? cursor,
  }) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'friend-feed',
        method: HttpMethod.get,
        queryParameters: {
          'limit': '$limit',
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return FriendFeedResponse.fromJson(data);
      }
      return const FriendFeedResponse(items: []);
    } on AuthException {
      throw const ActivityAuthRequiredException();
    } on FunctionException catch (error) {
      if (error.status == 401) {
        throw const ActivityAuthRequiredException();
      }
      throw ActivityServiceException(
        error.details?.toString() ?? 'friend-feed 호출 실패 (${error.status})',
      );
    }
  }

  Future<ActivityStats> loadActivityStats() async {
    try {
      final responses = await Future.wait([
        for (final path in const ['daily', 'weekly', 'breakdown'])
          Supabase.instance.client.functions.invoke(
            'activity-stats/$path',
            method: HttpMethod.get,
          ),
      ]);
      final merged = <String, dynamic>{};
      for (final response in responses) {
        final json = response.data;
        if (json is! Map<String, dynamic>) {
          throw const ActivityServiceException('activity-stats 응답 형식 오류');
        }
        final data = json['data'];
        merged.addAll(data is Map ? Map<String, dynamic>.from(data) : json);
      }
      return ActivityStats.fromJson(merged);
    } on AuthException {
      throw const ActivityAuthRequiredException();
    } on FunctionException catch (error) {
      if (error.status == 401) {
        throw const ActivityAuthRequiredException();
      }
      throw ActivityServiceException(
        error.details?.toString() ?? 'activity-stats 호출 실패 (${error.status})',
      );
    }
  }
}
