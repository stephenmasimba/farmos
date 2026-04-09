import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.phone,
    this.lastLogin,
    this.farmId,
    this.permissions = const <String>[],
  });

  final int id;
  final String email;
  final String role; // admin | manager | user
  final String? name;
  final String? phone;
  final DateTime? lastLogin;
  final int? farmId;
  final List<String> permissions;

  bool get isAdmin =>
      role == 'admin' || role == 'super_admin' || hasPermission('admin.access');
  bool get isManager => role == 'manager' || role == 'super_admin' || isAdmin;

  bool hasPermission(String permission) {
    if (permissions.contains('*')) return true;
    if (permissions.contains(permission)) return true;

    final parts = permission.split('.');
    if (parts.length == 2 && permissions.contains('${parts.first}.*')) {
      return true;
    }

    // Backward-compatible fallback if permissions are not present in payload.
    if (permissions.isEmpty) {
      if (role == 'super_admin' || role == 'admin') return true;
      if (role == 'manager' &&
          (permission.endsWith('.read') || permission == 'reports.generate')) {
        return true;
      }
    }

    return false;
  }

  bool hasAnyPermission(Iterable<String> required) {
    for (final permission in required) {
      if (hasPermission(permission)) {
        return true;
      }
    }
    return false;
  }

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: _parseInt(j['id']),
        email: (j['email'] as String?) ?? '',
        role: j['role'] as String? ?? 'user',
        name: j['name'] as String?,
        phone: j['phone'] as String?,
        farmId: _tryParseInt(j['farm_id']),
        permissions: ((j['permissions'] as List<dynamic>?) ?? const <dynamic>[])
            .map((e) => e.toString())
            .toList(),
        lastLogin: j['last_login'] != null
            ? DateTime.tryParse(j['last_login'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role,
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (farmId != null) 'farm_id': farmId,
        'permissions': permissions,
      };

  @override
  List<Object?> get props => [id, email, role, name, farmId, permissions];
}

int _parseInt(dynamic v) => int.tryParse((v ?? '0').toString()) ?? 0;
int? _tryParseInt(dynamic v) => v == null ? null : int.tryParse(v.toString());
