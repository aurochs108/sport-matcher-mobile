import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sport_matcher/data/auth/persistence/database/auth_tokens_database.dart';
import 'package:sport_matcher/data/auth/persistence/entity/auth_tokens_entity.dart';
import 'package:sport_matcher/data/auth/repository/auth_repository.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';

enum AuthState { authenticated, unauthenticated }

class AuthTokenManager {
  static final AuthTokenManager instance = AuthTokenManager._();

  late final AuthRepository _authRepository;
  late final AuthTokensDatabase _tokenDatabase;
  late final DateTime Function() _now;
  final _authStateController = StreamController<AuthState?>.broadcast();
  AuthState? _authState;

  @visibleForTesting
  AuthTokenManager.forTesting({
    AuthRepository? authRepository,
    AuthTokensDatabase? tokenDatabase,
    DateTime Function()? now,
  }) : this._(
         authRepository: authRepository,
         tokenDatabase: tokenDatabase,
         now: now,
       );

  AuthTokenManager._({
    AuthRepository? authRepository,
    AuthTokensDatabase? tokenDatabase,
    DateTime Function()? now,
  }) {
    final resolvedTokenDatabase = tokenDatabase ?? AuthTokensDatabase();
    _authRepository =
        authRepository ?? AuthRepository(tokenDatabase: resolvedTokenDatabase);
    _tokenDatabase = resolvedTokenDatabase;
    _now = now ?? DateTime.now;
  }

  AuthState? get authState => _authState;

  Stream<AuthState?> get authStateStream async* {
    yield _authState;
    yield* _authStateController.stream;
  }

  Future<AuthState> isSessionAuthenticated() async {
    final authState = await _resolveSessionAuthState();
    _setAuthState(authState);
    return authState;
  }

  Future<AuthState> _resolveSessionAuthState() async {
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

  void _setAuthState(AuthState authState) {
    _authState = authState;
    _authStateController.add(authState);
  }
}
