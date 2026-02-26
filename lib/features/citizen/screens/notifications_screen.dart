// lib/features/citizen/screens/notifications_screen.dart
import 'package:flutter/material.dart';

class _MockNotification {
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final IconData icon;
  final Color color;

  const _MockNotification({
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.icon,
    required this.color,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notifications = [
    _MockNotification(title: 'Issue In Progress', body: 'Your pothole report on Koramangala has been assigned to our team.', time: '2h ago', isRead: false, icon: Icons.engineering_rounded, color: Color(0xFFF57C00)),
    _MockNotification(title: 'Issue Resolved ✅', body: 'The streetlight repair on Indiranagar has been completed. Thank you!', time: '1d ago', isRead: false, icon: Icons.check_circle_rounded, color: Color(0xFF2E7D32)),
    _MockNotification(title: 'New Comment', body: 'An admin added a note to your drainage issue in HSR Layout.', time: '2d ago', isRead: true, icon: Icons.comment_rounded, color: Color(0xFF1565C0)),
    _MockNotification(title: 'Issue Open', body: 'Your garbage complaint has been received. Issue #issue_018.', time: '3d ago', isRead: true, icon: Icons.flag_rounded, color: Color(0xFFE53935)),
    _MockNotification(title: 'Reminder', body: 'Don\'t forget to upvote issues in your area to prioritize them.', time: '5d ago', isRead: true, icon: Icons.campaign_rounded, color: Color(0xFF7B1FA2)),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unread = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications${unread > 0 ? ' ($unread)' : ''}'),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              // mark all read
            }),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications yet'),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final n = _notifications[index];
                return Container(
                  decoration: BoxDecoration(
                    color: n.isRead ? scheme.surfaceContainerHighest : scheme.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: n.isRead ? scheme.outlineVariant.withOpacity(0.2) : scheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: n.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      child: Icon(n.icon, color: n.color, size: 20),
                    ),
                    title: Text(
                      n.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(n.body, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text(n.time, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant.withOpacity(0.7))),
                      ],
                    ),
                    trailing: !n.isRead
                        ? Container(width: 8, height: 8, decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle))
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
