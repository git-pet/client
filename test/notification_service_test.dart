import 'package:client/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses wrapped notifications newest first', () {
    final notifications = NotificationService.parseNotifications({
      'success': true,
      'data': {
        'notifications': [
          {
            'id': 'old',
            'type': 'level_up',
            'payload': {'level': 2},
            'is_read': true,
            'created_at': '2026-06-17T00:00:00Z',
          },
          {
            'id': 'new',
            'type': 'friend_request',
            'payload': {'requester_name': 'Kim'},
            'is_read': false,
            'created_at': '2026-06-24T00:00:00Z',
          },
        ],
      },
    });

    expect(notifications.map((item) => item.id), ['new', 'old']);
    expect(notifications.first.payload['requester_name'], 'Kim');
    expect(notifications.first.isRead, isFalse);
  });
}
