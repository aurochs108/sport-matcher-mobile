import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_matcher/data/profile/config/activities_config.dart';
import 'package:sport_matcher/data/profile/config/profile_config.dart';
import 'package:sport_matcher/data/profile/domain/profile_domain.dart';
import 'package:sport_matcher/data/profile/repository/profiles_repository.dart';
import 'package:sport_matcher/ui/core/utilities/validators/abstract_text_validator.dart';
import 'package:sport_matcher/ui/core/utilities/validators/text_length_validator.dart';

class ProfileFormFieldsViewModel {
  final String buttonTitle;
  final VoidCallback? _onSaved;
  final ImagePicker _picker;
  XFile? _pickedImage;
  final nameTextController = TextEditingController();
  final AbstractTextValidator nameValidator;
  final Map<ActivitiesConfig, bool> _activities = {
    for (final activity in ActivitiesConfig.values) activity: false,
  };
  final ProfilesRepository _profileRepository;
  Function()? onStateChanged;

  ProfileFormFieldsViewModel({
    required this.buttonTitle,
    VoidCallback? onSaved,
    AbstractTextValidator? nameValidator,
    ProfileDomain? initialProfile,
    ProfilesRepository? profileRepository,
    ImagePicker? imagePicker,
  }) : _onSaved = onSaved,
       nameValidator =
           nameValidator ??
           TextLengthValidator(
             minimumLength: ProfileConfig.nameMinLength,
             maximumLength: ProfileConfig.nameMaxLength,
           ),
       _profileRepository = profileRepository ?? ProfilesRepository(),
       _picker = imagePicker ?? ImagePicker() {
    nameTextController.addListener(_onStateChanged);
    if (initialProfile != null) {
      _loadFromProfile(initialProfile);
    }
  }

  void _onStateChanged() {
    onStateChanged?.call();
  }

  Future<void> pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (picked != null) {
        _pickedImage = picked;
        onStateChanged?.call();
      }
    } catch (e) {
      // TODO handle error
    }
  }

  String? get profileImagePath => _pickedImage?.path;

  void _loadFromProfile(ProfileDomain profile) {
    nameTextController.text = profile.name;
    _pickedImage = XFile(profile.profileImagePath);
    for (final entry in profile.activities.entries) {
      _activities[entry.key] = entry.value;
    }
    onStateChanged?.call();
  }

  Map<String, bool> get displayActivities {
    return {
      for (final entry in _activities.entries)
        entry.key.displayName: entry.value,
    };
  }

  void updateActivitiesByDisplayName(String displayName, bool isSelected) {
    final activity = _activities.keys.firstWhere(
      (activity) => activity.displayName == displayName,
    );
    _activities[activity] = isSelected;
    onStateChanged?.call();
  }

  VoidCallback? get buttonAction {
    final saved = _onSaved;
    if (saved == null) return null;
    return _getSaveButtonAction(saved);
  }

  VoidCallback? _getSaveButtonAction(VoidCallback onSaved) {
    final hasName = nameValidator.validate(nameTextController.text) == null;

    if (!_hasImage || !hasName || !_hasSelectedActivities) return null;

    return () {
      _saveProfile().then((_) {
        onSaved();
      });
    };
  }

  bool get _hasImage => _pickedImage != null;

  bool get _hasSelectedActivities =>
      _activities.values.any((isSelected) => isSelected);

  Future<void> _saveProfile() async {
    final imagePath = _pickedImage?.path;
    final profile = ProfileDomain(
      name: nameTextController.text,
      profileImagePath: imagePath!,
      activities: Map<ActivitiesConfig, bool>.from(_activities),
    );
    await _profileRepository.addProfile(profile);
  }

  void dispose() {
    nameTextController.removeListener(_onStateChanged);
    nameTextController.dispose();
  }
}
