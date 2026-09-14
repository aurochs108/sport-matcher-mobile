import 'package:sport_matcher/config/api_config.dart';
import 'package:sport_matcher/data/core/api_request/api_request.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/data/core/api_request/http_method.dart';
import 'package:sport_matcher/data/profile/domain/profile_domain.dart';

class ProfileApi {
  Future<ApiResult<String>> createProfile(ProfileDomain profile) {
    return ApiRequest<String>(
      path: '/profiles',
      baseUrl: ApiConfig.profilesBaseUrl,
      method: HttpMethod.post,
      body: {
        'name': profile.name,
        'favoriteSports': profile.activities.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key.displayName)
            .toList(),
        'profileImageUrl': profile.profileImagePath,
      },
      responseParser: (json) => json['id'] as String,
    ).execute();
  }
}
