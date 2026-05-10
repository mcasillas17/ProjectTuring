import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  const AuthStorage([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;
  static const _backendUrlKey = 'turing_backend_url';
  static const _apiKeyKey = 'turing_api_key';

  Future<void> save({
    required String backendUrl,
    required String apiKey,
  }) async {
    await _storage.write(key: _backendUrlKey, value: backendUrl.trim());
    await _storage.write(key: _apiKeyKey, value: apiKey.trim());
  }

  Future<String?> readBackendUrl() => _storage.read(key: _backendUrlKey);

  Future<String?> readApiKey() => _storage.read(key: _apiKeyKey);
}
