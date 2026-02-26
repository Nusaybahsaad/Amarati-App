import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationService = NotificationService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final notifs = await _notificationService.getMyNotifications();
      if (mounted) setState(() => _notifications = notifs);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('خطأ في جلب الإشعارات')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markRead(String id) async {
    try {
      final success = await _notificationService.markAsRead(id);
      if (success && mounted) {
        setState(() {
          final idx = _notifications.indexWhere(
            (n) => n['notification_id'] == id,
          );
          if (idx != -1) {
            _notifications[idx] = Map<String, dynamic>.from(_notifications[idx])
              ..['is_read'] = true;
          }
        });
      }
    } catch (_) {}
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              child: _notifications.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_off,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'لا توجد إشعارات',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notif = _notifications[index];
                        final isRead = notif['is_read'] ?? false;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: isRead ? 1 : 3,
                          color: isRead
                              ? Colors.white
                              : AppColors.primary.withOpacity(0.05),
                          child: ListTile(
                            onTap: () {
                              if (!isRead) {
                                _markRead(notif['notification_id']);
                              }
                              // Optionally, route to related_entity_id depending on related_entity_type
                            },
                            leading: CircleAvatar(
                              backgroundColor: isRead
                                  ? Colors.grey.withOpacity(0.2)
                                  : AppColors.primary,
                              child: Icon(
                                Icons.notifications,
                                color: isRead ? Colors.grey : Colors.white,
                              ),
                            ),
                            title: Text(
                              notif['title'] ?? 'إشعار جديد',
                              style: TextStyle(
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(notif['message'] ?? ''),
                                const SizedBox(height: 8),
                                Text(
                                  _formatDate(notif['date']),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
