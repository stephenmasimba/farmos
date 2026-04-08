import 'package:flutter/material.dart';
import '../../../core/widgets/common.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('Analytics')),
      body: EmptyState(
        icon: Icons.analytics_rounded,
        title: 'Analytics module ready',
        subtitle: 'Hook this to /api/analytics/dashboard.',
      ),
    );
  }
}
