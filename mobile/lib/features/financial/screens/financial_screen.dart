import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/financial.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/providers/sync_providers.dart';
import '../../../core/services/cache_status_service.dart';
import '../../../core/services/financial_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';

final _transactionsProvider =
    FutureProvider.autoDispose<List<Transaction>>((ref) {
  return ref.read(financialServiceProvider).getRecords(perPage: 30);
});

final _summaryProvider = FutureProvider.autoDispose<FinancialSummary>((ref) {
  return ref.read(financialServiceProvider).getSummary();
});

final _monthlyProvider =
    FutureProvider.autoDispose<List<MonthlyReport>>((ref) {
  return ref.read(financialServiceProvider).getMonthlyReport();
});

class FinancialScreen extends ConsumerStatefulWidget {
  const FinancialScreen({super.key});

  @override
  ConsumerState<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends ConsumerState<FinancialScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingChanges =
        ref.watch(pendingModuleChangesProvider(ApiEndpoints.financialRecords));
    final cacheStatus = latestOfflineStatus(
      ref.watch(cacheStatusServiceProvider),
      const [
        FinancialService.recordsStatusKey,
        FinancialService.summaryStatusKey,
        FinancialService.monthlyStatusKey,
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Transactions'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (cacheStatus != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: OfflineDataBanner(
                lastUpdatedAt: cacheStatus.lastUpdatedAt,
              ),
            ),
          pendingChanges.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (count) => count > 0
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: UnsyncedChangesChip(
                      count: count,
                      onTap: () => context.push('/sync?module=financial'),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _OverviewTab(),
                _TransactionsTab(),
                _ReportsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/financial/add');
          ref.invalidate(_transactionsProvider);
          ref.invalidate(_summaryProvider);
          ref.invalidate(_monthlyProvider);
        },
        icon: const Icon(Icons.add),
        label: const Text('Record'),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(_summaryProvider);
    final monthly = ref.watch(_monthlyProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(_summaryProvider);
        ref.invalidate(_monthlyProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
          summary.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorView(message: e.toString(), onRetry: null),
            data: (s) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Total Income',
                        value: Fmt.currency(s.totalIncome),
                        icon: Icons.trending_up_rounded,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Total Expenses',
                        value: Fmt.currency(s.totalExpenses),
                        icon: Icons.trending_down_rounded,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StatCard(
                  label: 'Net Profit',
                  value: Fmt.currency(s.netProfit),
                  icon: Icons.account_balance_wallet_rounded,
                  color: s.netProfit >= 0 ? AppColors.success : AppColors.error,
                  subtitle: 'Margin: ${Fmt.percent(s.profitMargin / 100)}',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader(title: 'Monthly P&L'),
          const SizedBox(height: 12),

          // Bar chart
          monthly.when(
            loading: () => const SizedBox(
                height: 200, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
            data: (reports) {
              if (reports.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: reports.take(6).toList().asMap().entries.map((e) {
                      final r = e.value;
                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: r.income,
                            color: AppColors.success,
                            width: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          BarChartRodData(
                            toY: r.expenses,
                            color: AppColors.error,
                            width: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) {
                            final idx = v.toInt();
                            if (idx < 0 || idx >= reports.length) {
                              return const SizedBox();
                            }
                            final months = [
                              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                            ];
                            final m = reports[idx].month;
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                m >= 1 && m <= 12 ? months[m - 1] : '',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 48,
                          getTitlesWidget: (v, _) => Text(
                            Fmt.compact(v),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TransactionsTab extends ConsumerWidget {
  const _TransactionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(_transactionsProvider);

    return transactions.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(_transactionsProvider),
      ),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'No transactions',
            subtitle: 'Tap + to record income or expenses',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(_transactionsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) => _TransactionTile(tx: list[i]),
          ),
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.tx});

  final Transaction tx;

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.isIncome;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              (isIncome ? AppColors.success : AppColors.error).withAlpha(25),
          child: Icon(
            isIncome
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: isIncome ? AppColors.success : AppColors.error,
            size: 20,
          ),
        ),
        title: Text(tx.category,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Text(tx.description ?? tx.transactionCode,
            maxLines: 1, style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Fmt.currency(tx.amount),
              style: TextStyle(
                  color: isIncome ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
            Text(Fmt.date(tx.transactionDate),
                style: const TextStyle(
                    fontSize: 10, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthly = ref.watch(_monthlyProvider);

    return monthly.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: null),
      data: (reports) {
        if (reports.isEmpty) {
          return const EmptyState(
            icon: Icons.bar_chart_rounded,
            title: 'No report data',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (_, i) => _MonthlyReportTile(report: reports[i]),
        );
      },
    );
  }
}

class _MonthlyReportTile extends StatelessWidget {
  const _MonthlyReportTile({required this.report});

  final MonthlyReport report;

  @override
  Widget build(BuildContext context) {
    final isProfit = report.profit >= 0;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final monthName = report.month >= 1 && report.month <= 12
        ? months[report.month - 1]
        : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$monthName ${report.year}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _Item(
                        'Income', Fmt.currency(report.income), AppColors.success)),
                Expanded(
                    child: _Item('Expenses', Fmt.currency(report.expenses),
                        AppColors.error)),
                Expanded(
                    child: _Item('Profit', Fmt.currency(report.profit),
                        isProfit ? AppColors.success : AppColors.error)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
