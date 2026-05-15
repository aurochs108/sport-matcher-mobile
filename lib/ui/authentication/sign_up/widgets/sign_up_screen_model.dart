import 'package:sport_matcher/data/auth/repository/auth_repository.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';

class SignUpScreenModel {
  final AuthRepository _authRepository;

  String? errorMessage;

  SignUpScreenModel({
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ?? AuthRepository();

  Future<void> register(String email, String password) async {
    errorMessage = null;
    final result = await _authRepository.registerWithEmail(
      email: email,
      password: password,
    );

    switch (result) {
      case ApiSuccess():
        return;
      case ApiError(:final message, :final code):
        errorMessage = code == 'EMAIL_ALREADY_REGISTERED'
            ? 'This email is already in use. Please use a different email.'
            : message;
    }
  }
}
