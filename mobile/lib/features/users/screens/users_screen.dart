import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/user_access_service.dart';
import '../../../core/widgets/common.dart';

final _usersProvider = FutureProvider.autoDispose<List<MobileUserSummary>>((ref) {
  return ref.read(userAccessServiceProvider).listUsers();
});

final _auditProvider = FutureProvider.autoDispose<List<AccessAuditEvent>>((ref) {
  return ref.read(userAccessServiceProvider).listAudit(limit: 120);
});

final _catalogProvider = FutureProvider.autoDispose<AccessCatalog>((ref) {
  return ref.read(userAccessServiceProvider).getCatalog();
});

final _selectedUserIdProvider = StateProvider<int?>((ref) => null);

final _selectedUserProfileProvider =
    FutureProvider.autoDispose<AccessProfile?>((ref) async {
  final userId = ref.watch(_selectedUserIdProvider);
  if (userId == null) return null;
  return ref.read(userAccessServiceProvider).getUserProfile(userId);
});

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(authProvider).user;
    final canView = _canViewUsers(current);
    final canManage = _canManagePermissions(current);

    if (!canView) {
      return const Scaffold(
        appBar: AppBar(title: Text('Users & Roles')),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Access denied',
          subtitle: 'Your account does not have permission to view users.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users & Roles'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Audit'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _UsersTab(canManage: canManage),
          _AuditTab(canManage: canManage),
        ],
      ),
    );
  }
}

class _UsersTab extends ConsumerWidget {
  const _UsersTab({required this.canManage});

  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(_usersProvider);
    return users.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(_usersProvider),
      ),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.group_rounded,
            title: 'No users available',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(_usersProvider);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final user = list[i];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_rounded),
                  ),
                  title: Text(user.name),
                  subtitle: Text('${user.email}\nRole: ${user.role}'),
                  isThreeLine: true,
                  trailing: canManage
                      ? IconButton(
                          icon: const Icon(Icons.admin_panel_settings_rounded),
                          tooltip: 'Manage access',
                          onPressed: () => _openAccessEditor(context, ref, user),
                        )
                      : null,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openAccessEditor(
    BuildContext context,
    WidgetRef ref,
    MobileUserSummary user,
  ) async {
    ref.read(_selectedUserIdProvider.notifier).state = user.id;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AccessEditorSheet(user: user),
    );
    ref.read(_selectedUserIdProvider.notifier).state = null;
    ref.invalidate(_usersProvider);
    ref.invalidate(_auditProvider);
  }
}

class _AccessEditorSheet extends ConsumerStatefulWidget {
  const _AccessEditorSheet({required this.user});

  final MobileUserSummary user;

  @override
  ConsumerState<_AccessEditorSheet> createState() => _AccessEditorSheetState();
}

class _AccessEditorSheetState extends ConsumerState<_AccessEditorSheet> {
  String? _selectedRole;
  final Set<String> _allowed = <String>{};
  final Set<String> _denied = <String>{};
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(_catalogProvider);
    final profile = ref.watch(_selectedUserProfileProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.82,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage Access: ${widget.user.name}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Expanded(
              child: catalog.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ErrorView(message: e.toString(), onRetry: null),
                data: (cat) => profile.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => ErrorView(message: e.toString(), onRetry: null),
                  data: (p) {
                    if (p == null) {
                      return const EmptyState(
                        icon: Icons.person_off_rounded,
                        title: 'Profile not available',
                      );
                    }
                    _selectedRole ??= p.user.role;

                    final effective = p.effectivePermissions.toSet();
                    for (final permission in effective) {
                      if (!p.rolePermissions.contains(permission)) {
                        _allowed.add(permission);
                      }
                    }

                    for (final permission in p.rolePermissions) {
                      if (!effective.contains(permission)) {
                        _denied.add(permission);
                      }
                    }

                    return ListView(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(labelText: 'Role'),
                          items: cat.roles
                              .map(
                                (r) => DropdownMenuItem<String>(
                                  value: r,
                                  child: Text(r),
                                ),
                              )
                              .toList(),
                          onChanged: _busy
                              ? null
                              : (v) => setState(() => _selectedRole = v),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Permission Overrides',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        ...cat.permissions.map((permission) {
                          final state = _allowed.contains(permission)
                              ? 'allow'
                              : (_denied.contains(permission) ? 'deny' : 'inherit');
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(permission, style: const TextStyle(fontSize: 13)),
                            subtitle: Text('Mode: $state'),
                            trailing: DropdownButton<String>(
                              value: state,
                              items: const [
                                DropdownMenuItem(value: 'inherit', child: Text('Inherit')),
                                DropdownMenuItem(value: 'allow', child: Text('Allow')),
                                DropdownMenuItem(value: 'deny', child: Text('Deny')),
                              ],
                              onChanged: _busy
                                  ? null
                                  : (value) {
                                      if (value == null) return;
                                      setState(() {
                                        _allowed.remove(permission);
                                        _denied.remove(permission);
                                        if (value == 'allow') {
                                          _allowed.add(permission);
                                        } else if (value == 'deny') {
                                          _denied.add(permission);
                                        }
                                      });
                                    },
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _busy ? null : () => _save(context, ref),
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_busy ? 'Saving...' : 'Save Access'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    setState(() => _busy = true);
    try {
      final service = ref.read(userAccessServiceProvider);
      final role = _selectedRole;
      if (role != null && role.isNotEmpty && role != widget.user.role) {
        await service.assignRole(widget.user.id, role);
      }

      final overrides = <Map<String, String>>[];
      for (final permission in _allowed) {
        overrides.add({'permission': permission, 'effect': 'allow'});
      }
      for (final permission in _denied) {
        overrides.add({'permission': permission, 'effect': 'deny'});
      }
      await service.replacePermissions(widget.user.id, overrides);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _AuditTab extends ConsumerWidget {
  const _AuditTab({required this.canManage});

  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!canManage) {
      return const EmptyState(
        icon: Icons.lock_clock_rounded,
        title: 'Audit access restricted',
        subtitle: 'You need permission to view access audit events.',
      );
    }

    final events = ref.watch(_auditProvider);
    return events.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(_auditProvider),
      ),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.fact_check_rounded,
            title: 'No access audit events',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(_auditProvider);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final item = list[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.history_toggle_off_rounded),
                  title: Text(item.eventType),
                  subtitle: Text(
                    'Target: ${item.targetUserId?.toString() ?? '-'} | '
                    'Actor: ${item.actorUserId?.toString() ?? '-'}\n'
                    'At: ${item.createdAt?.toIso8601String() ?? '-'}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

bool _canViewUsers(User? user) {
  if (user == null) return false;
  return user.hasAnyPermission(const [
    'users.view',
    'users.permissions.manage',
  ]);
}

bool _canManagePermissions(User? user) {
  if (user == null) return false;
  return user.hasPermission('users.permissions.manage');
}
