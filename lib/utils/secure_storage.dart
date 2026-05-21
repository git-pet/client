import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum SecureStorageKey {
  introSeen,
  githubAccessToken,
  githubRefreshToken,
  githubLogin,
  githubName,
  localeCode,
}

class SecureStorage {
  factory SecureStorage() => _instance;
  SecureStorage._internal() : _storage = const FlutterSecureStorage();

  static final SecureStorage _instance = SecureStorage._internal();
  static const _githubCredentialKeys = <SecureStorageKey>[
    SecureStorageKey.githubAccessToken,
    SecureStorageKey.githubRefreshToken,
    SecureStorageKey.githubLogin,
    SecureStorageKey.githubName,
  ];

  final FlutterSecureStorage _storage;

  Future<String?> read(SecureStorageKey key) => _storage.read(key: key.name);

  Future<void> write(SecureStorageKey key, String value) =>
      _storage.write(key: key.name, value: value);

  Future<void> delete(SecureStorageKey key) => _storage.delete(key: key.name);

  Future<void> deleteAll(Iterable<SecureStorageKey> keys) async {
    for (final key in keys) {
      await delete(key);
    }
  }

  Future<void> clearGithubCredentials() => deleteAll(_githubCredentialKeys);
}
