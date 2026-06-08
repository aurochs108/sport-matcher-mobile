import 'package:flutter/material.dart';
import 'package:sport_matcher/data/auth/manager/auth_token_manager.dart';
import 'package:sport_matcher/ui/authentication/auth_gate/widgets/auth_gate_view_model.dart';
import 'package:sport_matcher/ui/authentication/welcome/widgets/welcome_screen.dart';
import 'package:sport_matcher/ui/bottom_navigation_bar/widgets/bottom_navigation_bar_screen.dart';
import 'package:sport_matcher/ui/core/ui/loaders/full_screen_loader.dart';

class AuthGateScreen extends StatefulWidget {
  final AuthGateViewModel _viewModel;

  AuthGateScreen({
    super.key,
    AuthGateViewModel? viewModel,
    AuthTokenManager? authTokenManager,
  }) : _viewModel =
           viewModel ?? AuthGateViewModel(authTokenManager: authTokenManager);

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
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
          null => const FullScreenLoader(),
          AuthState.authenticated => BottomNavigationBarScreen(),
          AuthState.unauthenticated => WelcomeScreen(),
        };
      },
    );
  }
}
