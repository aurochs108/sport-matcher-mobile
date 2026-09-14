import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/data/profile/domain/profile_domain.dart';
import 'package:sport_matcher/data/profile/mapper/profile_mapper.dart';
import 'package:sport_matcher/data/profile/network/profile_api.dart';
import 'package:sport_matcher/data/profile/persistence/database/abstract_profile_database.dart';
import 'package:sport_matcher/data/profile/persistence/database/profile_database.dart';
import 'package:sport_matcher/data/profile/persistence/profile_id_store.dart';

class ProfilesRepository {
  final AbstractProfileDatabase _profileDatabase;
  final ProfileMapper _mapper;
  final ProfileApi _profileApi;
  final ProfileIdStore _profileIdStore;

  ProfilesRepository({
    AbstractProfileDatabase? profileDatabase,
    ProfileMapper? mapper,
    ProfileApi? profileApi,
    ProfileIdStore? profileIdStore,
  }) : _profileDatabase = profileDatabase ?? ProfileDatabase(),
       _mapper = mapper ?? ProfileMapper(),
       _profileApi = profileApi ?? ProfileApi(),
       _profileIdStore = profileIdStore ?? ProfileIdStore();

  Future<void> addProfile(ProfileDomain profile) async {
    final result = await _profileApi.createProfile(profile);
    switch (result) {
      case ApiSuccess(:final data):
        await _profileIdStore.save(data);
        break;
      case ApiError():
        throw ProfileCreationException(result.message);
    }
    final profileEntity = _mapper.toEntity(profile);
    await _profileDatabase.insertProfile(profileEntity);
  }

  Future<ProfileDomain?> loadProfile() async {
    final profileEntity = await _profileDatabase.loadProfile();
    if (profileEntity == null) {
      return null;
    }

    return _mapper.toDomain(profileEntity);
  }

  Future<String?> loadProfileId() => _profileIdStore.load();
}

class ProfileCreationException implements Exception {
  final String message;
  const ProfileCreationException(this.message);
}
