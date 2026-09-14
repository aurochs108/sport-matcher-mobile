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
      path: '/profiles/$profileId/notifications?${Uri(queryParameters: query).query}',
      method: HttpMethod.get,
      responseParser: NotificationsPage.fromJson,
    ).execute();
  }
}
