import 'dart:async';

import 'package:sport_matcher/data/auth/manager/auth_token_manager.dart';

class AuthGateScreenModel {
  final AuthTokenManager _authTokenManager;

  AuthGateScreenModel({AuthTokenManager? authTokenManager})
      : _authTokenManager = authTokenManager ?? AuthTokenManager.instance;

  AuthState? get authState => _authTokenManager.authState;

  Stream<AuthState?> get authStateStream => _authTokenManager.authStateStream;

  void checkSession() {
    unawaited(_authTokenManager.isSessionAuthenticated());
  }
}
