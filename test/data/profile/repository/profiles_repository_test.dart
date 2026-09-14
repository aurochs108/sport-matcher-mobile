import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/data/profile/domain/profile_domain.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sport_matcher/data/profile/config/activities_config.dart';
import 'package:sport_matcher/data/profile/persistence/database/abstract_profile_database.dart';
import 'package:sport_matcher/data/profile/persistence/database/profile_database.dart';
import 'package:sport_matcher/data/profile/network/profile_api.dart';
import 'package:sport_matcher/data/profile/persistence/profile_id_store.dart';
import 'package:sport_matcher/data/profile/repository/profiles_repository.dart';

import '../../../random/profile_domain_random.dart';
import '../../../random/profile_entity_data_random.dart';
import 'profiles_repository_test.mocks.dart';

@GenerateMocks([AbstractProfileDatabase])
void main() {
  group('ProfilesRepository', () {
    late MockAbstractProfileDatabase profileDatabase;
    late ProfilesRepository sut;

    setUp(() {
      profileDatabase = MockAbstractProfileDatabase();
      sut = ProfilesRepository(
        profileDatabase: profileDatabase,
        profileApi: _ProfileApi(),
        profileIdStore: _ProfileIdStore(),
      );
    });

    // MARK: - addProfile

    test('addProfile inserts mapped companion', () async {
      // given
      when(profileDatabase.insertProfile(any)).thenAnswer((_) async => 1);
      final profile = ProfileDomainRandom.random();

      // when
      await sut.addProfile(profile);

      // then
      final captured =
          verify(profileDatabase.insertProfile(captureAny)).captured.single
              as ProfileEntityCompanion;

      final expectedProfile = ProfileEntityCompanion(
        name: Value(profile.name),
        profileImagePath: Value(profile.profileImagePath),
        bike: Value(profile.activities[ActivitiesConfig.bike] ?? false),
        climbing: Value(profile.activities[ActivitiesConfig.climbing] ?? false),
        football: Value(profile.activities[ActivitiesConfig.football] ?? false),
        hockey: Value(profile.activities[ActivitiesConfig.hockey] ?? false),
        pingPong: Value(profile.activities[ActivitiesConfig.pingPong] ?? false),
        running: Value(profile.activities[ActivitiesConfig.running] ?? false),
        tennis: Value(profile.activities[ActivitiesConfig.tennis] ?? false),
        voleyball: Value(
          profile.activities[ActivitiesConfig.voleyball] ?? false,
        ),
      );
      expect(expectedProfile, captured);
    });

    // MARK: - loadProfile

    test('loadProfile returns null when database returns null', () async {
      // given
      when(profileDatabase.loadProfile()).thenAnswer((_) async => null);

      // when
      final result = await sut.loadProfile();

      // then
      expect(result, isNull);
      verify(profileDatabase.loadProfile()).called(1);
    });

    test(
      'loadProfile maps entity to domain when database returns entity',
      () async {
        // given
        final entity = ProfileEntityDataRandom.random();
        when(profileDatabase.loadProfile()).thenAnswer((_) async => entity);

        // when
        final result = await sut.loadProfile();

        // then
        expect(result, isNotNull);
        expect(result!.name, entity.name);
        verify(profileDatabase.loadProfile()).called(1);
      },
    );
  });
}

class _ProfileApi extends ProfileApi {
  @override
  Future<ApiResult<String>> createProfile(ProfileDomain profile) async {
    return const ApiSuccess('profile-id');
  }
}

class _ProfileIdStore extends ProfileIdStore {
  @override
  Future<void> save(String profileId) async {}
}
