import 'package:flutter/material.dart';
import '../../../core/widgets/common.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('Users & Roles')),
      body: EmptyState(
        icon: Icons.group_rounded,
        title: 'Users module ready',
        subtitle: 'Admin/user management screens can be expanded here.',
      ),
    );
  }
}
