import 'package:flutter/material.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/data/notification/domain/notification_domain.dart';
import 'package:sport_matcher/data/notification/repository/notifications_repository.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final _repository = NotificationsRepository();
  final _notifications = <NotificationDomain>[];
  String? _nextCursor;
  String? _error;
  bool _loading = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool nextPage = false}) async {
    setState(() {
      if (nextPage) {
        _loadingMore = true;
      } else {
        _loading = true;
        _error = null;
      }
    });
    final result = await _repository.load(cursor: nextPage ? _nextCursor : null);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _loadingMore = false;
      switch (result) {
        case ApiSuccess(:final data):
          if (!nextPage) _notifications.clear();
          _notifications.addAll(data.notifications);
          _nextCursor = data.nextCursor;
          break;
        case ApiError(:final message):
          _error = message;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(_error!),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _load, child: const Text('Retry')),
              ]),
            )
          : _notifications.isEmpty
          ? const Center(child: Text('No notifications yet.'))
          : ListView(
              children: [
                for (final notification in _notifications)
                  ListTile(
                    leading: Icon(notification.read ? Icons.notifications_none : Icons.notifications),
                    title: Text(notification.title),
                    subtitle: Text(notification.message),
                    trailing: Text(MaterialLocalizations.of(context).formatShortDate(notification.createdAt)),
                  ),
                if (_nextCursor != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _loadingMore ? null : () => _load(nextPage: true),
                      child: _loadingMore
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                          : const Text('Load more'),
                    ),
                  ),
              ],
            ),
    );
  }
}
