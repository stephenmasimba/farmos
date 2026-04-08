import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/shell/screens/main_shell.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/livestock/screens/livestock_screen.dart';
import '../../features/livestock/screens/livestock_detail_screen.dart';
import '../../features/livestock/screens/add_livestock_screen.dart';
import '../../features/inventory/screens/inventory_screen.dart';
import '../../features/inventory/screens/inventory_detail_screen.dart';
import '../../features/tasks/screens/tasks_screen.dart';
import '../../features/tasks/screens/add_task_screen.dart';
import '../../features/financial/screens/financial_screen.dart';
import '../../features/financial/screens/add_transaction_screen.dart';
import '../../features/weather/screens/weather_screen.dart';
import '../../features/iot/screens/iot_screen.dart';
import '../../features/fields/screens/fields_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/users/screens/users_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/more/screens/more_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/sync/screens/sync_center_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoading = auth.status == AuthStatus.loading;
      final isLoggedIn = auth.status == AuthStatus.authenticated;
      final onAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (isLoading) return '/splash';
      if (!isLoggedIn && !onAuth) return '/login';
      if (isLoggedIn && onAuth) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const _SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/livestock',
            builder: (_, __) => const LivestockScreen(),
            routes: [
              GoRoute(
                path: 'add',
                parentNavigatorKey: _rootKey,
                builder: (_, __) => const AddLivestockScreen(),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootKey,
                builder: (_, state) => LivestockDetailScreen(
                  id: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/tasks',
            builder: (_, __) => const TasksScreen(),
            routes: [
              GoRoute(
                path: 'add',
                parentNavigatorKey: _rootKey,
                builder: (_, __) => const AddTaskScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/financial',
            builder: (_, __) => const FinancialScreen(),
            routes: [
              GoRoute(
                path: 'add',
                parentNavigatorKey: _rootKey,
                builder: (_, __) => const AddTransactionScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/more',
            builder: (_, __) => const MoreScreen(),
          ),
          // Sub-routes from More
          GoRoute(
            path: '/inventory',
            builder: (_, __) => const InventoryScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootKey,
                builder: (_, state) => InventoryDetailScreen(
                  id: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(path: '/weather', builder: (_, __) => const WeatherScreen()),
          GoRoute(path: '/iot', builder: (_, __) => const IoTScreen()),
          GoRoute(path: '/fields', builder: (_, __) => const FieldsScreen()),
          GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
          GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
          GoRoute(path: '/users', builder: (_, __) => const UsersScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
          GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
          GoRoute(path: '/sync', builder: (_, __) => const SyncCenterScreen()),
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
        ],
      ),
    ],
  );
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
