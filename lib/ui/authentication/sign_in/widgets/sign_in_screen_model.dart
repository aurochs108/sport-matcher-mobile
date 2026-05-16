import 'package:flutter/material.dart';
import 'package:sport_matcher/data/auth/repository/auth_repository.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/ui/bottom_navigation_bar/widgets/bottom_navigation_bar_screen.dart';

class SignInScreenModel {
  final AuthRepository _authRepository;

  String? errorMessage;

  SignInScreenModel({
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ?? AuthRepository();

  Future<void> login(
    String email,
    String password,
    NavigatorState navigator,
  ) async {
    errorMessage = null;
    final result = await _authRepository.loginWithEmail(
      email: email,
      password: password,
    );

    switch (result) {
      case ApiSuccess():
        _navigateToTabbar(navigator);
        return;
      case ApiError(:final message):
        errorMessage = message;
    }
  }

  void _navigateToTabbar(NavigatorState navigator) {
    if (!navigator.mounted) {
      return;
    }

    navigator.pushReplacement(
      MaterialPageRoute(builder: (context) => BottomNavigationBarScreen()),
    );
  }

  void showErrorMessage(ScaffoldMessengerState scaffoldMessenger) {
    final message = errorMessage;
    if (message == null || !scaffoldMessenger.mounted) {
      return;
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
