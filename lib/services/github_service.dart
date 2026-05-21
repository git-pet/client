import 'dart:convert';

import 'package:client/models/github_activity.dart';
import 'package:client/utils/secure_storage.dart';
import 'package:http/http.dart' as http;

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

class GithubService {
  static const _baseUrl = 'https://api.github.com';

  Future<GithubActivityFeed> fetchPublicActivities() async {
    final storage = SecureStorage();
    final login = await storage.read(SecureStorageKey.githubLogin);
    if (login == null || login.isEmpty) {
      throw const GithubUserNotConfiguredException();
    }

    final name = await storage.read(SecureStorageKey.githubName);
    final accessToken = await storage.read(SecureStorageKey.githubAccessToken);

    final uri = Uri.parse('$_baseUrl/users/$login/events/public?per_page=20');
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        if (accessToken != null && accessToken.isNotEmpty)
          'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 401) {
      throw const GithubAuthRequiredException();
    }
    if (response.statusCode != 200) {
      throw GithubApiException(response.statusCode);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const GithubInvalidResponseException();
    }

    final activities = decoded
        .whereType<Map<String, dynamic>>()
        .map(GithubActivity.fromJson)
        .toList();

    return GithubActivityFeed(
      login: login,
      name: (name != null && name.isNotEmpty) ? name : login,
      activities: activities,
    );
  }
}
