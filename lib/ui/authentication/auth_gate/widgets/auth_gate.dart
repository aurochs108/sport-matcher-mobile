import 'package:flutter/material.dart';
import 'package:sport_matcher/data/auth/manager/auth_token_manager.dart';
import 'package:sport_matcher/ui/authentication/auth_gate/widgets/auth_gate_view_model.dart';
import 'package:sport_matcher/ui/authentication/welcome/widgets/welcome_screen.dart';
import 'package:sport_matcher/ui/bottom_navigation_bar/widgets/bottom_navigation_bar_screen.dart';

class AuthGate extends StatefulWidget {
  final AuthGateViewModel _viewModel;

  AuthGate({
    super.key,
    AuthGateViewModel? viewModel,
    AuthTokenManager? authManager,
  })
      : _viewModel = viewModel ?? AuthGateViewModel(authManager: authManager);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    widget._viewModel.checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState?>(
      stream: widget._viewModel.authStateStream,
      initialData: widget._viewModel.authState,
      builder: (_, snapshot) {
        final authState = snapshot.data;
        return switch (authState) {
          null => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          AuthState.authenticated => BottomNavigationBarScreen(),
          AuthState.unauthenticated => WelcomeScreen(),
        };
      },
    );
  }
}
