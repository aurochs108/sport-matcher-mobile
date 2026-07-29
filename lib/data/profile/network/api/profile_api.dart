import 'package:sport_matcher/config/api_config.dart';
import 'package:sport_matcher/data/core/api_request/api_request.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/data/core/api_request/http_method.dart';
import 'package:sport_matcher/data/profile/network/request/create_profile_request.dart';

class ProfileApi {
  Future<ApiResult<void>> createProfile({
    required String name,
    required List<String> favoriteSports,
    required String profileImageUrl,
  }) {
    final request = CreateProfileRequest(
      name: name,
      favoriteSports: favoriteSports,
      profileImageUrl: profileImageUrl,
    );

    return ApiRequest<void>(
      baseUrl: ApiConfig.profilesBaseUrl,
      path: '/profiles',
      method: HttpMethod.post,
      body: request.toJson(),
    ).execute();
  }
}
