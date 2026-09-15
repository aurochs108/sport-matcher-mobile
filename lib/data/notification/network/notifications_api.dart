import 'package:sport_matcher/config/api_config.dart';
import 'package:sport_matcher/data/core/api_request/api_request.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/data/core/api_request/http_method.dart';
import 'package:sport_matcher/data/notification/domain/notification_domain.dart';

class NotificationsApi {
  Future<ApiResult<NotificationsPage>> getNotifications({
    required String profileId,
    String? cursor,
  }) {
    final query = <String, String>{'limit': '20'};
    if (cursor != null) query['cursor'] = cursor;
    return ApiRequest<NotificationsPage>(
      path:
          '/profiles/$profileId/notifications?${Uri(queryParameters: query).query}',
      baseUrl: ApiConfig.profilesBaseUrl,
      method: HttpMethod.get,
      responseParser: NotificationsPage.fromJson,
    ).execute();
  }

  Future<ApiResult<void>> deleteNotification({
    required String profileId,
    required String notificationId,
  }) {
    return ApiRequest<void>(
      path: '/profiles/$profileId/notifications/$notificationId',
      baseUrl: ApiConfig.profilesBaseUrl,
      method: HttpMethod.delete,
    ).execute();
  }
}
