import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/models/weight_record.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.records});

  final List<WeightRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(child: Text('No weight records yet.'));
    }

    final sorted = List<WeightRecord>.of(records)
      ..sort((a, b) => a.date.compareTo(b.date));
    final spots = <FlSpot>[];
    for (int i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), sorted[i].weightKg));
    }

    final maxY = spots
            .map((s) => s.y)
            .reduce((a, b) => a > b ? a : b) *
        1.1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weight Over Time',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withAlpha(40),
                  ),
                  dotData: const FlDotData(show: true),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= sorted.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          Fmt.date(sorted[idx].date),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      return Text(
                        '${value.toInt()} kg',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: maxY,
            ),
          ),
        ),
      ],
    );
  }
}
