import 'package:flutter/material.dart';
import '../../../core/widgets/common.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('Reports')),
      body: EmptyState(
        icon: Icons.summarize_rounded,
        title: 'Reports module ready',
        subtitle:
            'Generate/download reports using /api/reports/generate and /api/reports/download.',
      ),
    );
  }
}
