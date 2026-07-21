import 'package:client/models/activity_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses activity stats response variants', () {
    final stats = ActivityStats.fromJson({
      'daily': [
        {'date': '2026-06-10', 'xp': 12},
      ],
      'weekly': [
        {'week_start': '2026-06-10', 'total_xp': '40'},
      ],
      'events': [
        {'event_type': 'commit', 'count': 2},
        {'type': 'pull_request', 'value': 1},
      ],
    });

    expect(stats.daily.single.xp, 12);
    expect(stats.weekly.single.xp, 40);
    expect(stats.events.map((event) => event.type), ['push', 'pull_request']);
  });
}
