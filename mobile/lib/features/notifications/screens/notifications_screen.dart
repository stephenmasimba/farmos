import 'package:flutter/material.dart';
import '../../../core/widgets/common.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: EmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'No notifications yet',
      ),
    );
  }
}
