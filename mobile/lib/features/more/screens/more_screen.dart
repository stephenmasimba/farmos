import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_Item>[
      _Item('Inventory', Icons.inventory_2_rounded, '/inventory'),
      _Item('Weather', Icons.cloud_rounded, '/weather'),
      _Item('IoT', Icons.sensors_rounded, '/iot'),
      _Item('Fields', Icons.grass_rounded, '/fields'),
      _Item('Reports', Icons.summarize_rounded, '/reports'),
      _Item('Analytics', Icons.analytics_rounded, '/analytics'),
      _Item('Users', Icons.group_rounded, '/users'),
      _Item('Settings', Icons.settings_rounded, '/settings'),
      _Item('Notifications', Icons.notifications_rounded, '/notifications'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('More Modules')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemBuilder: (_, i) {
          final item = items[i];
          return Card(
            child: InkWell(
              onTap: () => context.push(item.path),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 30),
                  const SizedBox(height: 10),
                  Text(item.label,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Item {
  const _Item(this.label, this.icon, this.path);

  final String label;
  final IconData icon;
  final String path;
}
