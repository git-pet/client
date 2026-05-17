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
}
