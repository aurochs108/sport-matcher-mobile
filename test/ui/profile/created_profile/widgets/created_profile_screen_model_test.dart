import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sport_matcher/data/auth/repository/auth_repository.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/data/profile/repository/profiles_repository.dart';
import 'package:sport_matcher/ui/authentication/welcome/widgets/welcome_screen.dart';
import 'package:sport_matcher/ui/profile/created_profile/widgets/created_profile_screen_model.dart';
import 'package:sport_matcher/ui/profile/edit_profile/widgets/edit_profile_screen.dart';

import '../../../../mocks/mock_navigator_observer.dart';
import '../../../../random/profile_domain_random.dart';
import '../../../../utilities/build_context_provider.dart';
import 'created_profile_screen_model_test.mocks.dart';

@GenerateMocks([ProfilesRepository, AuthRepository])
void main() {
  provideDummy<ApiResult<void>>(const ApiSuccess<void>(null));

  group('CreatedProfileScreenModel', () {
    late MockProfilesRepository mockProfilesRepository;
    late MockAuthRepository mockAuthRepository;
    late CreatedProfileScreenModel sut;

    setUp(() {
      mockProfilesRepository = MockProfilesRepository();
      mockAuthRepository = MockAuthRepository();
      when(mockProfilesRepository.loadProfile()).thenAnswer((_) async => null);
      sut = CreatedProfileScreenModel(
        profilesRepository: mockProfilesRepository,
        authRepository: mockAuthRepository,
      );
    });

    // MARK: - profileFuture

    test('profileFuture loads profile on init', () async {
      // given
      clearInteractions(mockProfilesRepository);

      final expectedProfile = ProfileDomainRandom.random();
      when(
        mockProfilesRepository.loadProfile(),
      ).thenAnswer((_) async => expectedProfile);

      // when
      final sut = CreatedProfileScreenModel(
        profilesRepository: mockProfilesRepository,
      );
      final profile = await sut.profileFuture;

      // then
      expect(profile?.name, expectedProfile.name);
      expect(profile?.profileImagePath, expectedProfile.profileImagePath);
      expect(profile?.activities, expectedProfile.activities);
      verify(mockProfilesRepository.loadProfile()).called(1);
    });

    test('profileFuture returns null when repository has no profile', () async {
      // when
      final profile = await sut.profileFuture;

      // then
      expect(profile, isNull);
      verify(mockProfilesRepository.loadProfile()).called(1);
    });

    // MARK: - reloadProfile

    test('reloadProfile reloads and calls onStateChanged', () async {
      // given
      clearInteractions(mockProfilesRepository);
      var onStateChangedCallCount = 0;
      sut.onStateChanged = () => onStateChangedCallCount++;

      final expectedProfile = ProfileDomainRandom.random();
      when(
        mockProfilesRepository.loadProfile(),
      ).thenAnswer((_) async => expectedProfile);

      // when
      sut.reloadProfile();
      final profile = await sut.profileFuture;

      // then
      expect(profile?.name, expectedProfile.name);
      expect(profile?.profileImagePath, expectedProfile.profileImagePath);
      expect(profile?.activities, expectedProfile.activities);
      expect(onStateChangedCallCount, 1);
      verify(mockProfilesRepository.loadProfile()).called(1);
    });

    // MARK: - selectedActivities

    test('selectedActivities returns only selected activities', () {
      // given
      final profile = ProfileDomainRandom.random();
      final expectedEntries = profile.activities.entries
          .where((activity) => activity.value)
          .map((activity) => MapEntry(activity.key.displayName, true));

      // when
      final result = sut.selectedActivities(profile);

      // then
      expect(result, Map.fromEntries(expectedEntries));
    });

    test('selectedActivities returns empty map for null profile', () {
      // when
      final result = sut.selectedActivities(null);

      // then
      expect(result, isEmpty);
    });

    // MARK: - getEditButtonAction

    testWidgets('getEditButtonAction returns null when profile is null', (
      WidgetTester tester,
    ) async {
      // given
      final observer = TestNavigatorObserver();
      final buildContext = await BuildContextProvider.getWithObserver(
        tester,
        observer,
      );
      final navigator = Navigator.of(buildContext);

      // then
      expect(sut.getEditButtonAction(null, navigator), isNull);
    });

    testWidgets('getEditButtonAction pushes EditProfileScreen', (
      WidgetTester tester,
    ) async {
      // given
      final profile = ProfileDomainRandom.random();
      final observer = TestNavigatorObserver();
      final buildContext = await BuildContextProvider.getWithObserver(
        tester,
        observer,
      );
      final navigator = Navigator.of(buildContext);

      // when
      sut.getEditButtonAction(profile, navigator)?.call();
      await tester.pumpAndSettle();

      // then
      expect(observer.lastPushedRoute, isA<MaterialPageRoute>());
      expect(find.byType(EditProfileScreen), findsOneWidget);
    });

    // MARK: - logout

    testWidgets('logout calls repository and navigates to welcome on success', (
      WidgetTester tester,
    ) async {
      // given
      final observer = TestNavigatorObserver();
      final buildContext = await BuildContextProvider.getWithObserver(
        tester,
        observer,
      );
      final navigator = Navigator.of(buildContext);
      final scaffoldMessenger = ScaffoldMessenger.of(buildContext);
      when(
        mockAuthRepository.logout(),
      ).thenAnswer((_) async => const ApiSuccess<void>(null));

      // when
      await sut.logout(navigator, scaffoldMessenger);
      await tester.pumpAndSettle();

      // then
      verify(mockAuthRepository.logout()).called(1);
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(sut.errorMessage, isNull);
    });

    testWidgets('logout stores repository error and shows snackbar', (
      WidgetTester tester,
    ) async {
      // given
      const errorMessage = 'Logout failed';
      final observer = TestNavigatorObserver();
      final buildContext = await BuildContextProvider.getWithObserver(
        tester,
        observer,
      );
      final navigator = Navigator.of(buildContext);
      final scaffoldMessenger = ScaffoldMessenger.of(buildContext);
      when(
        mockAuthRepository.logout(),
      ).thenAnswer((_) async => const ApiError<void>(errorMessage));

      // when
      await sut.logout(navigator, scaffoldMessenger);
      await tester.pump();

      // then
      verify(mockAuthRepository.logout()).called(1);
      expect(sut.errorMessage, errorMessage);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsNothing);
    });
  });
}
