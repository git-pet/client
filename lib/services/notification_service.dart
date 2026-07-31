import 'package:supabase_flutter/supabase_flutter.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.payload,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final bool isRead;
  final DateTime createdAt;

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    type: type,
    payload: payload,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      payload: rawPayload is Map<String, dynamic> ? rawPayload : const {},
      isRead: json['is_read'] == true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class NotificationAuthRequiredException implements Exception {
  const NotificationAuthRequiredException();
}

class NotificationServiceException implements Exception {
  const NotificationServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NotificationService {
  const NotificationService();

  Future<List<AppNotification>> loadNotifications({
    bool unreadOnly = false,
    int? limit,
  }) async {
    final data = await _invoke(
      'notifications',
      method: HttpMethod.get,
      queryParameters: {
        if (unreadOnly) 'unread_only': 'true',
        if (limit != null) 'limit': '$limit',
      },
    );
    return parseNotifications(data);
  }

  Future<int> loadUnreadCount() async {
    final data = _unwrap(
      await _invoke('notifications/unread-count', method: HttpMethod.get),
    );
    final count = data?['unread_count'];
    return count is num ? count.toInt() : 0;
  }

  Future<void> markRead(String id) async {
    await _invoke('notifications/$id/read', method: HttpMethod.post);
  }

  Future<Object?> _invoke(
    String path, {
    required HttpMethod method,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        path,
        method: method,
        queryParameters: queryParameters,
      );
      return response.data;
    } on AuthException {
      throw const NotificationAuthRequiredException();
    } on FunctionException catch (error) {
      if (error.status == 401) {
        throw const NotificationAuthRequiredException();
      }
      throw NotificationServiceException(
        error.details?.toString() ?? '$path 호출 실패 (${error.status})',
      );
    }
  }

  static List<AppNotification> parseNotifications(Object? raw) {
    final data = _unwrap(raw);
    if (data == null) return const [];
    final rows = data['notifications'];
    if (rows is! List) return const [];

    final notifications =
        rows
            .whereType<Map<String, dynamic>>()
            .map(AppNotification.fromJson)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  static Map<String, dynamic>? _unwrap(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final wrapped = raw['data'];
    return wrapped is Map<String, dynamic> ? wrapped : raw;
  }
}
