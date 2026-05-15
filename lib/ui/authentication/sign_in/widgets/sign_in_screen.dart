import 'package:flutter/material.dart';
import 'package:sport_matcher/ui/authentication/email_authentication/widgets/email_authentication_screen.dart';
import 'package:sport_matcher/ui/authentication/sign_in/widgets/sign_in_screen_model.dart';
import 'package:sport_matcher/ui/bottom_navigation_bar/widgets/bottom_navigation_bar_screen.dart';

class SignInScreen extends StatefulWidget {
  final SignInScreenModel? _viewModel;

  const SignInScreen({super.key, SignInScreenModel? viewModel})
    : _viewModel = viewModel;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final SignInScreenModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel =
        widget._viewModel ??
        SignInScreenModel(onLoginSuccess: _navigateToTabbar);
  }

  void _navigateToTabbar() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => BottomNavigationBarScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EmailAuthenticationScreen(
      title: "Sign in",
      onFinishProcessButtonAction: (email, password) async {
        await _viewModel.login(email, password);
        if (_viewModel.errorMessage != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_viewModel.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
}
