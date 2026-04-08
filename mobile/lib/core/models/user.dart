import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.phone,
    this.lastLogin,
  });

  final int id;
  final String email;
  final String role; // admin | manager | user
  final String? name;
  final String? phone;
  final DateTime? lastLogin;

  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager' || role == 'admin';

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'] as int,
        email: j['email'] as String,
        role: j['role'] as String? ?? 'user',
        name: j['name'] as String?,
        phone: j['phone'] as String?,
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
      };

  @override
  List<Object?> get props => [id, email, role, name];
}
