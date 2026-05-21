import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sport_matcher/data/profile/config/activities_config.dart';
import 'package:sport_matcher/data/profile/domain/profile_domain.dart';
import 'package:sport_matcher/data/profile/repository/profiles_repository.dart';
import 'package:sport_matcher/ui/core/utilities/validators/abstract_text_validator.dart';
import 'package:sport_matcher/ui/profile/widgets/profile_form_fields_view_model.dart';
import 'package:uuid/uuid.dart';

import '../../../mocks/mock_image_picker.dart';
import 'profile_form_fields_view_model_test.mocks.dart';

@GenerateMocks([AbstractTextValidator, ProfilesRepository])
void main() {
  group('ProfileFormFieldsViewModel', () {
    late MockImagePicker imagePicker;
    late MockAbstractTextValidator nameValidator;
    late MockProfilesRepository profileRepository;
    late int onStateChangedCallCount;
    final buttonTitle = Uuid().v4();
    late ProfileFormFieldsViewModel sut;

    setUp(() {
      onStateChangedCallCount = 0;
      nameValidator = MockAbstractTextValidator();
      when(nameValidator.validate(any)).thenReturn(null);
      profileRepository = MockProfilesRepository();
      imagePicker = MockImagePicker();
      sut = ProfileFormFieldsViewModel(
        buttonTitle: buttonTitle,
        nameValidator: nameValidator,
        profileRepository: profileRepository,
        imagePicker: imagePicker,
      );
      sut.onStateChanged = () {
        onStateChangedCallCount++;
      };
    });

    // MARK: - initialProfile

    test('initialProfile populates fields from profile', () {
      // given
      final profile = ProfileDomain(
        name: Uuid().v4(),
        profileImagePath: 'path/to/image.jpg',
        activities: {
          for (final activity in ActivitiesConfig.values) activity: false,
          ActivitiesConfig.values.first: true,
        },
      );

      final expectedDisplayActivities = {
        for (final entry in profile.activities.entries)
          entry.key.displayName: entry.value,
      };

      // when
      final sut = ProfileFormFieldsViewModel(
        buttonTitle: buttonTitle,
        nameValidator: nameValidator,
        profileRepository: profileRepository,
        imagePicker: imagePicker,
        initialProfile: profile,
      );

      // then
      expect(sut.nameTextController.text, profile.name);
      expect(sut.profileImagePath, profile.profileImagePath);
      expect(sut.displayActivities, expectedDisplayActivities);
    });

    // MARK: - buttonTitle

    test('buttonTitle returns provided value', () {
      // then
      expect(sut.buttonTitle, buttonTitle);
    });

    // MARK: - buttonAction

    test('buttonAction returns null when onSaved not provided', () {
      // then
      expect(sut.buttonAction, isNull);
    });

    // MARK: - dispose

    test('dispose disposes nameTextController', () {
      // when
      sut.dispose();

      // then
      expect(
        () => sut.nameTextController.text = Uuid().v4(),
        throwsFlutterError,
      );
    });

    // MARK: - pickImage

    test('should update picked image path on successful image pick', () async {
      // given
      final expectedImagePath = 'path/to/image.jpg';
      imagePicker.pickedImageReturnValue = XFile(expectedImagePath);

      final actualOnStateChangedCallCount = onStateChangedCallCount;

      // when
      await sut.pickImage();

      // then
      expect(sut.profileImagePath, expectedImagePath);
      expect(actualOnStateChangedCallCount + 1, onStateChangedCallCount);
    });

    test(
      'should not update picked image path when image is not picked',
      () async {
        // given
        imagePicker.pickedImageReturnValue = null;

        final actualOnStateChangedCallCount = onStateChangedCallCount;

        // when
        await sut.pickImage();

        // then
        expect(sut.profileImagePath, isNull);
        expect(actualOnStateChangedCallCount, onStateChangedCallCount);
      },
    );

    // MARK: - profileImagePath

    test('profileImagePath returns null initially', () {
      // then
      expect(sut.profileImagePath, isNull);
    });

    // MARK: - onStateChanged

    test('onStateChanged is called when name text changes', () {
      // given
      final actualOnStateChangedCallCount = onStateChangedCallCount;

      // when
      sut.nameTextController.text = Uuid().v4();

      // then
      expect(actualOnStateChangedCallCount + 1, onStateChangedCallCount);
    });

    // MARK: - displayActivities

    test('should map activities to display names', () {
      // given
      final expectedDisplayActivities = {
        for (final activity in ActivitiesConfig.values)
          activity.displayName: false,
      };

      // when
      final displayActivities = sut.displayActivities;

      // then
      expect(displayActivities, expectedDisplayActivities);
    });

    // MARK: - updateActivitiesByDisplayName

    test('should update activities by display name', () {
      // given
      final activitiesKeys = sut.displayActivities.keys.toList();
      activitiesKeys.shuffle();
      final activity = activitiesKeys.first;
      final expectedIsSelected = !sut.displayActivities[activity]!;
      var activitiesCopy = Map<String, bool>.from(sut.displayActivities);

      final actualOnStateChangedCallCount = onStateChangedCallCount;

      // when
      sut.updateActivitiesByDisplayName(activity, expectedIsSelected);

      // then
      activitiesCopy[activity] = expectedIsSelected;
      expect(sut.displayActivities, activitiesCopy);
      expect(actualOnStateChangedCallCount + 1, onStateChangedCallCount);
    });

    // MARK: - buttonAction

    test('buttonAction returns null when no image', () {
      // given
      final sut = ProfileFormFieldsViewModel(
        buttonTitle: buttonTitle,
        onSaved: () {},
        nameValidator: nameValidator,
        profileRepository: profileRepository,
        imagePicker: imagePicker,
      );
      sut.nameTextController.text = Uuid().v4();
      sut.updateActivitiesByDisplayName(sut.displayActivities.keys.first, true);

      // then
      expect(sut.buttonAction, isNull);
    });

    test('buttonAction returns null when name is invalid', () async {
      // given
      final sut = ProfileFormFieldsViewModel(
        buttonTitle: buttonTitle,
        onSaved: () {},
        nameValidator: nameValidator,
        profileRepository: profileRepository,
        imagePicker: imagePicker,
      );
      imagePicker.pickedImageReturnValue = XFile('path/to/image.jpg');
      await sut.pickImage();

      final invalidName = Uuid().v4();
      when(nameValidator.validate(invalidName)).thenReturn('Name too short');
      sut.nameTextController.text = invalidName;
      sut.updateActivitiesByDisplayName(sut.displayActivities.keys.first, true);

      // then
      expect(sut.buttonAction, isNull);
    });

    test('buttonAction returns null when no activities selected', () async {
      // given
      final sut = ProfileFormFieldsViewModel(
        buttonTitle: buttonTitle,
        onSaved: () {},
        nameValidator: nameValidator,
        profileRepository: profileRepository,
        imagePicker: imagePicker,
      );
      imagePicker.pickedImageReturnValue = XFile('path/to/image.jpg');
      await sut.pickImage();

      sut.nameTextController.text = Uuid().v4();

      // then
      expect(sut.buttonAction, isNull);
    });

    test('buttonAction saves profile and calls onSaved', () async {
      // given
      var onSavedCalled = false;
      final sut = ProfileFormFieldsViewModel(
        buttonTitle: buttonTitle,
        onSaved: () => onSavedCalled = true,
        nameValidator: nameValidator,
        profileRepository: profileRepository,
        imagePicker: imagePicker,
      );

      final profileImagePath = 'path/to/image.jpg';
      imagePicker.pickedImageReturnValue = XFile(profileImagePath);
      await sut.pickImage();

      sut.nameTextController.text = Uuid().v4();

      final activityToSelect = ActivitiesConfig.values.first;
      final expectedActivities = {
        for (final activity in ActivitiesConfig.values) activity: false,
      };
      expectedActivities[activityToSelect] = true;
      sut.updateActivitiesByDisplayName(sut.displayActivities.keys.first, true);

      when(profileRepository.addProfile(any)).thenAnswer((_) async {});

      // when
      sut.buttonAction?.call();
      await Future.delayed(Duration.zero);

      // then
      expect(onSavedCalled, true);

      verify(
        profileRepository.addProfile(
          argThat(
            predicate<ProfileDomain?>((profile) {
              return profile != null &&
                  profile.name == sut.nameTextController.text &&
                  profile.profileImagePath == profileImagePath &&
                  mapEquals(profile.activities, expectedActivities);
            }),
          ),
        ),
      ).called(1);
    });
  });
}
