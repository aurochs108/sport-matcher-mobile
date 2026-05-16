import 'package:flutter/material.dart';
import 'package:sport_matcher/ui/authentication/email_authentication/widgets/email_authentication_screen.dart';
import 'package:sport_matcher/ui/authentication/sign_in/widgets/sign_in_screen_model.dart';

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
    _viewModel = widget._viewModel ?? SignInScreenModel();
  }

  @override
  Widget build(BuildContext context) {
    return EmailAuthenticationScreen(
      title: "Sign in",
      onFinishProcessButtonAction: (email, password) async {
        final navigator = Navigator.of(context);
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        await _viewModel.login(email, password, navigator);
        _viewModel.showErrorMessage(scaffoldMessenger);
      },
    );
  }
}
