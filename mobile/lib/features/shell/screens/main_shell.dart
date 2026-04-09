import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../farm/screens/farm_switcher.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _Tab(label: 'Dashboard', icon: Icons.dashboard_rounded, path: '/dashboard'),
    _Tab(label: 'Livestock', icon: Icons.pets_rounded, path: '/livestock'),
    _Tab(label: 'Tasks', icon: Icons.task_alt_rounded, path: '/tasks'),
    _Tab(label: 'Financial', icon: Icons.account_balance_wallet_rounded, path: '/financial'),
    _Tab(label: 'More', icon: Icons.grid_view_rounded, path: '/more'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return Scaffold(
      body: child,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Consumer(
                builder: (_, ref, __) {
                  final user = ref.watch(authProvider).user;
                  return AppBar(
                    title: const Text('FarmOS Mobile'),
                    actions: [
                      if (user != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Center(child: FarmSwitcher()),
                        ),
                    ],
                    elevation: 0,
                  );
                },
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs
            .map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }
}

class _Tab {
  const _Tab({required this.label, required this.icon, required this.path});

  final String label;
  final IconData icon;
  final String path;
}
