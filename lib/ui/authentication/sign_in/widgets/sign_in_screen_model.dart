import 'package:sport_matcher/data/auth/repository/auth_repository.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';

class SignInScreenModel {
  final AuthRepository _authRepository;

  String? errorMessage;

  SignInScreenModel({
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ?? AuthRepository();

  Future<void> login(String email, String password) async {
    errorMessage = null;
    final result = await _authRepository.loginWithEmail(
      email: email,
      password: password,
    );

    switch (result) {
      case ApiSuccess():
        return;
      case ApiError(:final message):
        errorMessage = message;
    }
  }
}
