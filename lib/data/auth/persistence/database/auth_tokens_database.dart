import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sport_matcher/data/auth/persistence/database/abstract_auth_tokens_database.dart';
import 'package:sport_matcher/data/auth/persistence/entity/auth_tokens_entity.dart';

class AuthTokensDatabase implements AbstractAuthTokensDatabase {
  static const _tokenKey = 'auth_tokens';

  final FlutterSecureStorage _storage;

  AuthTokensDatabase({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<AuthTokensEntity?> loadTokens() async {
    final value = await _storage.read(key: _tokenKey);
    if (value == null) {
      return null;
    }

    return AuthTokensEntity.fromJson(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> saveTokens(AuthTokensEntity entity) async {
    await _storage.write(key: _tokenKey, value: jsonEncode(entity));
  }

  @override
  Future<void> deleteTokens() async {
    await _storage.delete(key: _tokenKey);
  }
}
