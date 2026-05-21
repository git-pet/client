class GithubActivity {
  const GithubActivity({
    required this.type,
    required this.repoName,
    required this.createdAt,
    required this.payload,
  });

  final String type;
  final String repoName;
  final DateTime? createdAt;
  final Map<String, dynamic>? payload;

  factory GithubActivity.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] ?? 'Event').toString();
    final repo = json['repo'];
    final payload = json['payload'];
    final repoName = repo is Map<String, dynamic>
        ? (repo['name'] ?? '').toString()
        : '';
    final createdAtRaw = json['created_at']?.toString();
    final createdAt = createdAtRaw == null
        ? null
        : DateTime.tryParse(createdAtRaw)?.toLocal();

    return GithubActivity(
      type: type,
      repoName: repoName,
      createdAt: createdAt,
      payload: payload is Map<String, dynamic> ? payload : null,
    );
  }

  factory GithubActivity.fromSupabaseRow(Map<String, dynamic> row) {
    final type = (row['event_type'] ?? 'Event').toString();
    final rawMetadata = row['metadata'];
    final metadata = rawMetadata is Map<String, dynamic> ? rawMetadata : null;
    final repoName = _extractRepoName(metadata);
    final createdAtRaw = row['created_at']?.toString();
    final createdAt = createdAtRaw == null
        ? null
        : DateTime.tryParse(createdAtRaw)?.toLocal();

    return GithubActivity(
      type: type,
      repoName: repoName,
      createdAt: createdAt,
      payload: metadata,
    );
  }

  // metadata는 GitHub App webhook이 적재한 jsonb. payload 키 구조가 확정되기 전
  // 까지 흔히 보이는 형태들을 best-effort로 훑어본다.
  static String _extractRepoName(Map<String, dynamic>? metadata) {
    if (metadata == null) return '';
    final direct = metadata['repo_name'] ?? metadata['repo'];
    if (direct is String) return direct;
    final repo = metadata['repository'] ?? direct;
    if (repo is Map<String, dynamic>) {
      final fullName = repo['full_name'];
      if (fullName is String) return fullName;
      final name = repo['name'];
      if (name is String) return name;
    }
    return '';
  }
}
