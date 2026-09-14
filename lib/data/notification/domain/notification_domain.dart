class NotificationDomain {
  final String id;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;

  const NotificationDomain({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  factory NotificationDomain.fromJson(Map<String, dynamic> json) {
    return NotificationDomain(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      read: json['read'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }
}

class NotificationsPage {
  final List<NotificationDomain> notifications;
  final String? nextCursor;

  const NotificationsPage({required this.notifications, required this.nextCursor});

  factory NotificationsPage.fromJson(Map<String, dynamic> json) {
    return NotificationsPage(
      notifications: (json['notifications'] as List<dynamic>)
          .map((item) => NotificationDomain.fromJson(item as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );
  }
}
