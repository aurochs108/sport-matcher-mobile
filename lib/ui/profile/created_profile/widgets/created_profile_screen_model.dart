import 'package:flutter/material.dart';
import 'package:sport_matcher/data/auth/repository/auth_repository.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/data/profile/domain/profile_domain.dart';
import 'package:sport_matcher/data/profile/repository/profiles_repository.dart';
import 'package:sport_matcher/ui/authentication/welcome/widgets/welcome_screen.dart';
import 'package:sport_matcher/ui/profile/edit_profile/widgets/edit_profile_screen.dart';

class CreatedProfileScreenModel extends ChangeNotifier {
  final ProfilesRepository _profilesRepository;
  final AuthRepository _authRepository;
  late Future<ProfileDomain?> profileFuture;
  Function()? onStateChanged;
  String? errorMessage;

  CreatedProfileScreenModel({
    ProfilesRepository? profilesRepository,
    AuthRepository? authRepository,
  }) : _profilesRepository = profilesRepository ?? ProfilesRepository(),
       _authRepository = authRepository ?? AuthRepository() {
    profileFuture = _loadProfile();
  }

  Future<ProfileDomain?> _loadProfile() async {
    return await _profilesRepository.loadProfile();
  }

  void reloadProfile() {
    profileFuture = _loadProfile();
    onStateChanged?.call();
  }

  Map<String, bool> selectedActivities(ProfileDomain? profile) {
    return Map.fromEntries(
      profile?.activities.entries
              .where((activity) => activity.value)
              .map((activity) => MapEntry(activity.key.displayName, true)) ??
          [],
    );
  }

  VoidCallback? getEditButtonAction(
    ProfileDomain? profile,
    NavigatorState navigator,
  ) {
    if (profile == null) return null;

    return () async {
      await navigator.push(
        MaterialPageRoute(builder: (_) => EditProfileScreen(profile: profile)),
      );
      reloadProfile();
    };
  }

  Future<void> logout(
    NavigatorState navigator,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    errorMessage = null;
    final result = await _authRepository.logout();

    switch (result) {
      case ApiSuccess():
        _navigateToWelcome(navigator);
      case ApiError(:final message):
        errorMessage = message;
        _showErrorMessage(scaffoldMessenger);
    }
  }

  void _navigateToWelcome(NavigatorState navigator) {
    if (!navigator.mounted) {
      return;
    }

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => WelcomeScreen()),
      (route) => false,
    );
  }

  void _showErrorMessage(ScaffoldMessengerState scaffoldMessenger) {
    final message = errorMessage;
    if (message == null || !scaffoldMessenger.mounted) {
      return;
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
