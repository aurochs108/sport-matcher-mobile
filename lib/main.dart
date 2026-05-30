import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sport_matcher/data/auth/manager/auth_token_manager.dart';
import 'package:sport_matcher/ui/authentication/welcome/widgets/welcome_screen.dart';
import 'package:sport_matcher/ui/bottom_navigation_bar/widgets/bottom_navigation_bar_screen.dart';

void main() {
  runApp(const SportMatcherApp());
}

class SportMatcherApp extends StatelessWidget {
  const SportMatcherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AuthGate());
  }
}

class AuthGate extends StatefulWidget {
  final AuthTokenManager _authManager;

  AuthGate({super.key, AuthTokenManager? authManager})
      : _authManager = authManager ?? AuthTokenManager.instance;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    unawaited(widget._authManager.isSessionAuthenticated());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState?>(
      stream: widget._authManager.authStateStream,
      initialData: widget._authManager.authState,
      builder: (context, snapshot) {
        final authState = snapshot.data;
        if (authState == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return switch (authState) {
          AuthState.authenticated => BottomNavigationBarScreen(),
          AuthState.unauthenticated => WelcomeScreen(),
        };
      },
    );
  }
}
