import 'package:flutter/material.dart';
import 'package:sport_matcher/data/auth/manager/auth_manager.dart';
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
  final AuthManager _authManager;

  AuthGate({super.key, AuthManager? authManager})
      : _authManager = authManager ?? AuthManager();

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<AuthState> _authStateFuture;

  @override
  void initState() {
    super.initState();
    _authStateFuture = widget._authManager.resolveInitialAuthState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthState>(
      future: _authStateFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return switch (snapshot.requireData) {
          AuthState.authenticated => BottomNavigationBarScreen(),
          AuthState.unauthenticated => WelcomeScreen(),
        };
      },
    );
  }
}
