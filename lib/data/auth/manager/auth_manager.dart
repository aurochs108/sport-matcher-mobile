import 'package:sport_matcher/data/auth/persistence/database/auth_tokens_database.dart';
import 'package:sport_matcher/data/auth/persistence/entity/auth_tokens_entity.dart';
import 'package:sport_matcher/data/auth/repository/auth_repository.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';

enum AuthState {
  authenticated,
  unauthenticated,
}

class AuthManager {
  final AuthRepository _authRepository;
  final AuthTokensDatabase _tokenDatabase;
  final DateTime Function() _now;

  factory AuthManager({
    AuthRepository? authRepository,
    AuthTokensDatabase? tokenDatabase,
    DateTime Function()? now,
  }) {
    final resolvedTokenDatabase = tokenDatabase ?? AuthTokensDatabase();
    return AuthManager._(
      authRepository ??
          AuthRepository(tokenDatabase: resolvedTokenDatabase),
      resolvedTokenDatabase,
      now ?? DateTime.now,
    );
  }

  AuthManager._(
    this._authRepository,
    this._tokenDatabase,
    this._now,
  );

  Future<AuthState> resolveInitialAuthState() async {
    try {
      final tokens = await _tokenDatabase.loadTokens();
      if (tokens == null) {
        return AuthState.unauthenticated;
      }

      if (_isAccessTokenValid(tokens)) {
        return AuthState.authenticated;
      }

      return await _refreshExpiredTokens();
    } catch (_) {
      return AuthState.unauthenticated;
    }
  }

  bool _isAccessTokenValid(AuthTokensEntity tokens) {
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      tokens.accessTokenExpiresAtMillisecondsSinceEpoch,
    );
    return expiresAt.isAfter(_now());
  }

  Future<AuthState> _refreshExpiredTokens() async {
    final result = await _authRepository.refreshTokens();
    switch (result) {
      case ApiSuccess():
        return AuthState.authenticated;
      case ApiError():
        await _authRepository.clearStoredTokens();
        return AuthState.unauthenticated;
    }
  }
}
