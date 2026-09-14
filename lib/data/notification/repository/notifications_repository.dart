import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/data/notification/domain/notification_domain.dart';
import 'package:sport_matcher/data/notification/network/notifications_api.dart';
import 'package:sport_matcher/data/profile/repository/profiles_repository.dart';

class NotificationsRepository {
  final NotificationsApi _notificationsApi;
  final ProfilesRepository _profilesRepository;

  NotificationsRepository({
    NotificationsApi? notificationsApi,
    ProfilesRepository? profilesRepository,
  }) : _notificationsApi = notificationsApi ?? NotificationsApi(),
       _profilesRepository = profilesRepository ?? ProfilesRepository();

  Future<ApiResult<NotificationsPage>> load({String? cursor}) async {
    final profileId = await _profilesRepository.loadProfileId();
    if (profileId == null) {
      return const ApiError('Profile ID is unavailable. Please create your profile again.');
    }
    return _notificationsApi.getNotifications(profileId: profileId, cursor: cursor);
  }
}
