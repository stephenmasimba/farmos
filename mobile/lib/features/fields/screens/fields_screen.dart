import 'package:flutter/material.dart';
import '../../../core/widgets/common.dart';

class FieldsScreen extends StatelessWidget {
  const FieldsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('Fields & Crops')),
      body: EmptyState(
        icon: Icons.grass_rounded,
        title: 'Fields module ready',
        subtitle:
            'Connect this screen to field endpoints once backend routes are exposed.',
      ),
    );
  }
}
