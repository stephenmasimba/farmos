import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class MobileUserSummary {
  const MobileUserSummary({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String status;

  factory MobileUserSummary.fromJson(Map<String, dynamic> json) {
    return MobileUserSummary(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      name: (json['name'] as String?) ?? 'User',
      email: (json['email'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'user',
      status: (json['status'] as String?) ?? 'active',
    );
  }
}

class AccessCatalog {
  const AccessCatalog({
    required this.roles,
    required this.permissions,
    required this.templates,
  });

  final List<String> roles;
  final List<String> permissions;
  final Map<String, List<String>> templates;

  factory AccessCatalog.fromJson(Map<String, dynamic> json) {
    final roles = ((json['roles'] as List<dynamic>?) ?? const <dynamic>[])
        .map((e) => e.toString())
        .toList();
    final permissions =
        ((json['permissions'] as List<dynamic>?) ?? const <dynamic>[])
            .map((e) => e.toString())
            .toList();

    final templates = <String, List<String>>{};
    final rawTemplates = json['templates'];
    if (rawTemplates is Map) {
      rawTemplates.forEach((key, value) {
        final list = (value as List<dynamic>? ?? const <dynamic>[])
            .map((e) => e.toString())
            .toList();
        templates[key.toString()] = list;
      });
    }

    return AccessCatalog(
      roles: roles,
      permissions: permissions,
      templates: templates,
    );
  }
}

class AccessProfile {
  const AccessProfile({
    required this.user,
    required this.farmId,
    required this.rolePermissions,
    required this.effectivePermissions,
    required this.catalog,
  });

  final MobileUserSummary user;
  final int farmId;
  final List<String> rolePermissions;
  final List<String> effectivePermissions;
  final List<String> catalog;

  factory AccessProfile.fromJson(Map<String, dynamic> json) {
    return AccessProfile(
      user: MobileUserSummary.fromJson(
          (json['user'] as Map<String, dynamic>?) ?? const {}),
      farmId: int.tryParse((json['farm_id'] ?? '1').toString()) ?? 1,
      rolePermissions:
          ((json['role_permissions'] as List<dynamic>?) ?? const <dynamic>[])
              .map((e) => e.toString())
              .toList(),
      effectivePermissions:
          ((json['effective_permissions'] as List<dynamic>?) ??
                  const <dynamic>[])
              .map((e) => e.toString())
              .toList(),
      catalog: ((json['catalog'] as List<dynamic>?) ?? const <dynamic>[])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class AccessAuditEvent {
  const AccessAuditEvent({
    required this.id,
    required this.eventType,
    required this.targetUserId,
    required this.actorUserId,
    required this.farmId,
    required this.metadataJson,
    required this.createdAt,
  });

  final int id;
  final String eventType;
  final int? targetUserId;
  final int? actorUserId;
  final int? farmId;
  final String? metadataJson;
  final DateTime? createdAt;

  factory AccessAuditEvent.fromJson(Map<String, dynamic> json) {
    return AccessAuditEvent(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      eventType: (json['event_type'] as String?) ?? '',
      targetUserId: _tryParseInt(json['target_user_id']),
      actorUserId: _tryParseInt(json['actor_user_id']),
      farmId: _tryParseInt(json['farm_id']),
      metadataJson: json['metadata_json'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

int? _tryParseInt(dynamic v) => v == null ? null : int.tryParse(v.toString());

class UserAccessService {
  const UserAccessService(this._api);

  final ApiClient _api;

  Future<List<MobileUserSummary>> listUsers() async {
    final list = await _api.getList(ApiEndpoints.users);
    return list
        .map((e) => MobileUserSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AccessCatalog> getCatalog() async {
    final data = await _api.get(ApiEndpoints.accessCatalog);
    return AccessCatalog.fromJson(data);
  }

  Future<AccessProfile> getUserProfile(int userId, {int? farmId}) async {
    final data = await _api.get(
      ApiEndpoints.userAccess(userId),
      params: {
        if (farmId != null) 'farm_id': farmId,
      },
    );
    return AccessProfile.fromJson(data);
  }

  Future<void> assignRole(int userId, String role) async {
    await _api.put(ApiEndpoints.userRole(userId), data: {
      'role': role,
    });
  }

  Future<void> replacePermissions(
    int userId,
    List<Map<String, String>> permissions,
  ) async {
    await _api.put(ApiEndpoints.userPermissions(userId), data: {
      'permissions': permissions,
    });
  }

  Future<List<AccessAuditEvent>> listAudit({int limit = 100}) async {
    final data = await _api.get(ApiEndpoints.accessAudit, params: {'limit': limit});
    final events = (data['events'] as List<dynamic>? ?? const <dynamic>[])
        .map((e) => AccessAuditEvent.fromJson(e as Map<String, dynamic>))
        .toList();
    return events;
  }
}
