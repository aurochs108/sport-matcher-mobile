import 'package:flutter/material.dart';
import 'package:sport_matcher/ui/authentication/email_authentication/widgets/email_authentication_screen.dart';
import 'package:sport_matcher/ui/authentication/sign_in/widgets/sign_in_screen_model.dart';
import 'package:sport_matcher/ui/bottom_navigation_bar/widgets/bottom_navigation_bar_screen.dart';

class SignInScreen extends StatelessWidget {
  final SignInScreenModel _viewModel;

  SignInScreen({super.key, SignInScreenModel? viewModel})
      : _viewModel = viewModel ?? SignInScreenModel();

  void _navigateToTabbar(BuildContext buildContext) {
    Navigator.of(buildContext).push(MaterialPageRoute(
      builder: (buildContext) => BottomNavigationBarScreen(),
    ));
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
          return;
        }
        if (context.mounted) {
          _navigateToTabbar(context);
        }
      },
    );
  }
}
