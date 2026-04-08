import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
              title: Text(auth?.name ?? auth?.email ?? 'User'),
              subtitle: Text('Role: ${auth?.role ?? 'unknown'}'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.language_rounded),
                  title: Text('Language'),
                  subtitle: Text('English'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.notifications_active_rounded),
                  title: Text('Notifications'),
                  subtitle: Text('Enabled'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.storage_rounded),
                  title: Text('Offline Cache'),
                  subtitle: Text('Manage local data'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            label: const Text('Logout', style: TextStyle(color: AppColors.error)),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
