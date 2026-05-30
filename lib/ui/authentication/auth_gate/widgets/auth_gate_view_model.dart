import 'dart:async';

import 'package:sport_matcher/data/auth/manager/auth_token_manager.dart';

class AuthGateViewModel {
  final AuthTokenManager _authManager;

  AuthGateViewModel({AuthTokenManager? authManager})
      : _authManager = authManager ?? AuthTokenManager.instance;

  AuthState? get authState => _authManager.authState;

  Stream<AuthState?> get authStateStream => _authManager.authStateStream;

  void checkSession() {
    unawaited(_authManager.isSessionAuthenticated());
  }
}
