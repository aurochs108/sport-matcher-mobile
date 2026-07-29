import 'package:flutter/material.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/data/profile/domain/profile_domain.dart';
import 'package:sport_matcher/data/profile/repository/profiles_repository.dart';
import 'package:sport_matcher/ui/bottom_navigation_bar/widgets/bottom_navigation_bar_screen.dart';

class CreateProfileScreenModel {
  final ProfilesRepository _profilesRepository;

  CreateProfileScreenModel({ProfilesRepository? profilesRepository})
    : _profilesRepository = profilesRepository ?? ProfilesRepository();

  Future<ApiResult<void>> createProfile(ProfileDomain profile) {
    return _profilesRepository.createProfile(profile);
  }

  void navigateToHomeAction(NavigatorState navigator) {
    navigator.push(
      MaterialPageRoute(builder: (_) => BottomNavigationBarScreen()),
    );
  }
}
