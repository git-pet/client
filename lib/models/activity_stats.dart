class ActivityStats {
  const ActivityStats({
    required this.daily,
    required this.weekly,
    required this.events,
  });

  final List<ActivityStatPoint> daily;
  final List<ActivityStatPoint> weekly;
  final List<ActivityEventStat> events;

  bool get isEmpty => daily.isEmpty && weekly.isEmpty && events.isEmpty;

  factory ActivityStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final source = data is Map ? Map<String, dynamic>.from(data) : json;

    return ActivityStats(
      daily: _points(
        source['daily'] ?? source['days'] ?? source['daily_stats'],
        const ['date', 'day', 'period'],
      ),
      weekly: _points(
        source['weekly'] ?? source['weeks'] ?? source['weekly_stats'],
        const ['week_start', 'week', 'date', 'period'],
      ),
      events: _events(
        source['breakdown'] ??
            source['events'] ??
            source['event_types'] ??
            source['by_event'],
      ),
    );
  }

  static List<ActivityStatPoint> _points(Object? raw, List<String> dateKeys) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) {
          final json = Map<String, dynamic>.from(item);
          final date = _dateFrom(json, dateKeys);
          if (date == null) return null;
          return ActivityStatPoint(
            date: date,
            xp: _intFrom(json, const ['xp', 'total_xp', 'value', 'xp_awarded']),
          );
        })
        .nonNulls
        .toList();
  }

  static List<ActivityEventStat> _events(Object? raw) {
    final totals = <String, int>{};

    if (raw is Map) {
      for (final entry in raw.entries) {
        final type = _normalizeEventType(entry.key.toString());
        final value = _toInt(entry.value) ?? 0;
        if (value > 0) totals[type] = (totals[type] ?? 0) + value;
      }
    } else if (raw is List) {
      for (final item in raw.whereType<Map>()) {
        final json = Map<String, dynamic>.from(item);
        final rawType =
            json['event_type'] ?? json['type'] ?? json['event'] ?? json['name'];
        if (rawType == null) continue;
        final type = _normalizeEventType(rawType.toString());
        final value = _intFrom(json, const [
          'count',
          'total_count',
          'value',
          'xp',
          'total_xp',
        ]);
        if (value > 0) totals[type] = (totals[type] ?? 0) + value;
      }
    }

    final preferredOrder = {
      'push': 0,
      'pull_request': 1,
      'issue': 2,
      'star': 3,
    };
    final stats = totals.entries
        .map((entry) => ActivityEventStat(type: entry.key, value: entry.value))
        .toList();
    stats.sort((a, b) {
      final left = preferredOrder[a.type] ?? 99;
      final right = preferredOrder[b.type] ?? 99;
      if (left != right) return left.compareTo(right);
      return a.type.compareTo(b.type);
    });
    return stats;
  }

  static DateTime? _dateFrom(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final raw = json[key];
      if (raw == null) continue;
      final date = DateTime.tryParse(raw.toString());
      if (date != null) return date;
    }
    return null;
  }

  static int _intFrom(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = _toInt(json[key]);
      if (value != null) return value;
    }
    return 0;
  }

  static int? _toInt(Object? raw) {
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static String _normalizeEventType(String raw) {
    final value = raw.trim().toLowerCase();
    switch (value) {
      case 'push':
      case 'pushevent':
      case 'commit':
        return 'push';
      case 'pr':
      case 'pullrequestevent':
      case 'pull_request':
        return 'pull_request';
      case 'issues':
      case 'issuesevent':
      case 'issue':
        return 'issue';
      case 'watch':
      case 'watchevent':
      case 'star':
        return 'star';
      default:
        return value;
    }
  }
}

class ActivityStatPoint {
  const ActivityStatPoint({required this.date, required this.xp});

  final DateTime date;
  final int xp;
}

class ActivityEventStat {
  const ActivityEventStat({required this.type, required this.value});

  final String type;
  final int value;
}
