import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/user.dart';
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
import '../../features/tasks/screens/task_detail_screen.dart';
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
import '../../features/timesheets/screens/timesheets_screen.dart';
import '../../features/veterinary/screens/veterinary_screen.dart';
import '../../features/hr/screens/hr_screen.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/inventory/screens/barcode_scanner_screen.dart';
import '../../features/weather/screens/weather_alerts_screen.dart';
import '../../features/livestock/screens/cost_analysis_screen.dart';

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
      final currentUser = auth.user;
      final onAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (isLoading) return '/splash';
      if (!isLoggedIn && !onAuth) return '/login';
      if (isLoggedIn && onAuth) return '/dashboard';
      if (isLoggedIn && !_canAccessRoute(currentUser, state.matchedLocation)) {
        return '/dashboard';
      }
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
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootKey,
                builder: (_, state) => TaskDetailScreen(
                  taskId: int.parse(state.pathParameters['id']!),
                ),
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
          GoRoute(path: '/timesheets', builder: (_, __) => const TimesheetsScreen()),
          GoRoute(path: '/veterinary', builder: (_, __) => const VeterinaryScreen()),
          GoRoute(path: '/hr', builder: (_, __) => const HrScreen()),
          GoRoute(path: '/feed', builder: (_, __) => const FeedScreen()),
          GoRoute(path: '/sync', builder: (_, __) => const SyncCenterScreen()),
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/barcode-scanner',
            builder: (_, __) => const BarcodeScanner(),
          ),
          GoRoute(
            path: '/weather-alerts',
            builder: (_, __) => const WeatherAlertsScreen(),
          ),
          GoRoute(
            path: '/cost-analysis',
            builder: (_, __) => const CostAnalysisScreen(),
          ),
        ],
      ),
    ],
  );
});

bool _canAccessRoute(User? user, String location) {
  if (user == null) return false;

  if (location.startsWith('/users')) {
    return user.hasAnyPermission(const [
      'users.view',
      'users.permissions.manage',
    ]);
  }

  if (location.startsWith('/analytics')) {
    return user.hasPermission('analytics.read');
  }

  if (location.startsWith('/reports')) {
    return user.hasAnyPermission(const [
      'reports.read',
      'reports.generate',
    ]);
  }

  if (location.startsWith('/settings')) {
    return user.hasPermission('settings.read');
  }

  if (location.startsWith('/notifications')) {
    return user.hasAnyPermission(const [
      'tasks.read',
      'reports.read',
      'users.view',
    ]);
  }

  if (location.startsWith('/timesheets')) {
    return user.hasPermission('tasks.read');
  }

  if (location.startsWith('/veterinary')) {
    return user.hasPermission('livestock.read');
  }

  if (location.startsWith('/hr')) {
    return user.hasPermission('tasks.read');
  }

  if (location.startsWith('/feed')) {
    return user.hasPermission('inventory.read');
  }

  if (location.startsWith('/barcode-scanner')) {
    return user.hasPermission('inventory.create');
  }

  if (location.startsWith('/weather-alerts')) {
    return true; // All users can view weather alerts
  }

  if (location.startsWith('/cost-analysis')) {
    return user.hasAnyPermission(const [
      'livestock.read',
      'reports.read',
    ]);
  }

  return true;
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
