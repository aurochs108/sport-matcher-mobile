import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/data/core/mapper/api_error_to_user_message_mapper.dart';
import 'package:sport_matcher/data/profile/domain/profile_domain.dart';
import 'package:sport_matcher/data/profile/mapper/profile_mapper.dart';
import 'package:sport_matcher/data/profile/network/api/profile_api.dart';
import 'package:sport_matcher/data/profile/persistence/database/abstract_profile_database.dart';
import 'package:sport_matcher/data/profile/persistence/database/profile_database.dart';

class ProfilesRepository {
  final AbstractProfileDatabase _profileDatabase;
  final ProfileMapper _mapper;
  final ProfileApi _profileApi;
  final ApiErrorToUserMessageMapper _errorMapper;

  ProfilesRepository({
    AbstractProfileDatabase? profileDatabase,
    ProfileMapper? mapper,
    ProfileApi? profileApi,
    ApiErrorToUserMessageMapper? errorMapper,
  }) : _profileDatabase = profileDatabase ?? ProfileDatabase(),
       _mapper = mapper ?? ProfileMapper(),
       _profileApi = profileApi ?? ProfileApi(),
       _errorMapper = errorMapper ?? const ApiErrorToUserMessageMapper();

  Future<void> addProfile(ProfileDomain profile) {
    final profileEntity = _mapper.toEntity(profile);
    return _profileDatabase.insertProfile(profileEntity);
  }

  Future<ApiResult<void>> createProfile(ProfileDomain profile) async {
    try {
      final favoriteSports = profile.activities.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key.displayName)
          .toList();
      final result = await _profileApi.createProfile(
        name: profile.name,
        favoriteSports: favoriteSports,
        profileImageUrl: profile.profileImagePath,
      );

      switch (result) {
        case ApiSuccess():
          await addProfile(profile);
          return const ApiSuccess<void>(null);
        case ApiError(:final message, :final statusCode, :final code):
          return ApiError<void>(message, statusCode: statusCode, code: code);
      }
    } catch (error) {
      return ApiError<void>(_errorMapper.map(error));
    }
  }

  Future<ProfileDomain?> loadProfile() async {
    final profileEntity = await _profileDatabase.loadProfile();
    if (profileEntity == null) {
      return null;
    }

    return _mapper.toDomain(profileEntity);
  }
}
