import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/cost_analysis.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

final _herdCostsProvider = FutureProvider.autoDispose<List<AnimalCostAnalysis>>((ref) {
  final start = DateTime.now().subtract(const Duration(days: 90));
  return ref.read(costAnalysisServiceProvider).getHerdCosts(startDate: start);
});

final _batchCostProvider = FutureProvider.autoDispose
    .family<BatchCostSummary?, int>((ref, batchId) async {
  try {
    return await ref
        .read(costAnalysisServiceProvider)
        .getBatchCostsummary(batchId);
  } catch (e) {
    return null;
  }
});

class CostAnalysisScreen extends ConsumerWidget {
  const CostAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final costs = ref.watch(_herdCostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cost Analysis'),
      ),
      body: costs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                'No cost data available',
                style: TextStyle(color: Colors.grey[500]),
              ),
            );
          }

          // Calculate aggregates
          final totalFeedCost = items.fold<double>(0, (s, i) => s + i.feedCost);
          final totalVetCost =
              items.fold<double>(0, (s, i) => s + i.veterinaryCost);
          final totalLaborCost =
              items.fold<double>(0, (s, i) => s + i.laborCost);
          final totalCost =
              items.fold<double>(0, (s, i) => s + i.totalCost);

          return ListView(
            children: [
              _buildSummaryCards(
                totalFeedCost,
                totalVetCost,
                totalLaborCost,
                totalCost,
              ),
              const SizedBox(height: 24),
              _buildCostBreakdownChart(
                totalFeedCost,
                totalVetCost,
                totalLaborCost,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Individual Animals',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...items.map((item) => _AnimalCostTile(analysis: item)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(
    double feedCost,
    double vetCost,
    double laborCost,
    double totalCost,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _CostCard(
                  title: 'Feed Cost',
                  amount: feedCost,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CostCard(
                  title: 'Veterinary',
                  amount: vetCost,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CostCard(
                  title: 'Labor',
                  amount: laborCost,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CostCard(
                  title: 'Total',
                  amount: totalCost,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostBreakdownChart(
    double feedCost,
    double vetCost,
    double laborCost,
  ) {
    final total = feedCost + vetCost + laborCost;
    if (total == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cost Breakdown',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: feedCost,
                    color: Colors.orange,
                    title: 'Feed',
                  ),
                  PieChartSectionData(
                    value: vetCost,
                    color: Colors.red,
                    title: 'Vet',
                  ),
                  PieChartSectionData(
                    value: laborCost,
                    color: Colors.blue,
                    title: 'Labor',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  const _CostCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  final String title;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Fmt.currency(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimalCostTile extends StatelessWidget {
  const _AnimalCostTile({required this.analysis});

  final AnimalCostAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.pets),
      title: Text('#${analysis.animalTag}'),
      subtitle: Text(
        'Feed: ${Fmt.currency(analysis.feedCost)} • Vet: ${Fmt.currency(analysis.veterinaryCost)} • Labor: ${Fmt.currency(analysis.laborCost)}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Fmt.currency(analysis.totalCost),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            '${Fmt.currency(analysis.costPerDay)}/day',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
