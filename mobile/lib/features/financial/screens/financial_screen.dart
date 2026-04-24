import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/financial.dart';
import '../../../core/providers/auth_provider.dart';
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

final _accountingSnapshotProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.read(financialServiceProvider).getAccountingSnapshot();
});

final _budgetVarianceProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  final user = ref.watch(authProvider).user;
  return ref.read(financialServiceProvider).getBudgetVariance(
        farmId: user?.farmId,
        year: DateTime.now().year,
        month: DateTime.now().month,
      );
});

final _financialPeriodsProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) {
  final user = ref.watch(authProvider).user;
  return ref.read(financialServiceProvider).getFinancialPeriods(
        farmId: user?.farmId,
      );
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
    final accountingSnapshot = ref.watch(_accountingSnapshotProvider);
    final budgetVariance = ref.watch(_budgetVarianceProvider);
    final financialPeriods = ref.watch(_financialPeriodsProvider);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_rounded),
            tooltip: 'Accounting tools',
            onPressed: () => _openAccountingTools(context),
          ),
        ],
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
          accountingSnapshot.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (snapshot) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card(
                child: ListTile(
                  leading: Icon(
                    (snapshot['is_balanced'] == true)
                        ? Icons.balance_rounded
                        : Icons.warning_amber_rounded,
                    color: (snapshot['is_balanced'] == true)
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                  title: const Text('Accounting Platform'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Trial balance: ${snapshot['is_balanced'] == true ? 'Balanced' : 'Unbalanced'} · "
                        "AR Open: ${snapshot['open_receivables']} · "
                        "AP Open: ${snapshot['open_payables']} · "
                        "Currencies: ${snapshot['currency_count'] ?? 0} · "
                        "Banks: ${snapshot['bank_account_count'] ?? 0} · "
                        "Assets: ${snapshot['fixed_asset_count'] ?? 0}",
                      ),
                      const SizedBox(height: 4),
                      budgetVariance.when(
                        loading: () => const Text('Budget health: loading...', style: TextStyle(fontSize: 12)),
                        error: (_, __) => const Text('Budget health unavailable', style: TextStyle(fontSize: 12)),
                        data: (budget) {
                          final totals = budget['totals'] as Map<String, dynamic>?;
                          final overBudget = totals != null
                              ? (int.tryParse((totals['over_budget_count'] ?? 0).toString()) ?? 0)
                              : 0;
                          final variance = totals != null
                              ? double.tryParse((totals['variance'] ?? 0).toString()) ?? 0.0
                              : 0.0;
                          return Text(
                            'Over budget: $overBudget · Variance: ${Fmt.currency(variance)}',
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                      const SizedBox(height: 2),
                      financialPeriods.when(
                        loading: () => const Text('Loading period history...', style: TextStyle(fontSize: 12)),
                        error: (_, __) => const Text('Period history unavailable', style: TextStyle(fontSize: 12)),
                        data: (periods) => Text(
                          'Closed periods: ${periods.length}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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

  Future<void> _openAccountingTools(BuildContext context) async {
    final user = ref.read(authProvider).user;
    final farmId = user?.farmId;
    if (farmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No farm_id on this user session')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AccountingToolsSheet(farmId: farmId),
    );
  }
}

class _AccountingToolsSheet extends ConsumerStatefulWidget {
  const _AccountingToolsSheet({required this.farmId});
  final int farmId;

  @override
  ConsumerState<_AccountingToolsSheet> createState() => _AccountingToolsSheetState();
}

class _AccountingToolsSheetState extends ConsumerState<_AccountingToolsSheet> {
  String _report = 'pl';
  DateTime _start = DateTime.now().subtract(const Duration(days: 30));
  DateTime _end = DateTime.now();
  DateTime _asOf = DateTime.now();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Accounting tools',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _busy ? null : _seedCoa,
                  child: Text(_busy ? 'Working...' : 'Seed COA'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _seedCoa(force: true),
                  child: const Text('Seed (force)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _report,
            items: const [
              DropdownMenuItem(value: 'pl', child: Text('Profit & Loss')),
              DropdownMenuItem(value: 'bs', child: Text('Balance Sheet')),
              DropdownMenuItem(value: 'cf', child: Text('Cash Flow')),
            ],
            onChanged: (v) => setState(() => _report = v ?? 'pl'),
            decoration: const InputDecoration(labelText: 'Report'),
          ),
          const SizedBox(height: 8),
          if (_report == 'pl' || _report == 'cf')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _start,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked == null) return;
                      setState(() => _start = picked);
                    },
                    child: Text('Start: ${_start.toIso8601String().split('T').first}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _end,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked == null) return;
                      setState(() => _end = picked);
                    },
                    child: Text('End: ${_end.toIso8601String().split('T').first}'),
                  ),
                ),
              ],
            ),
          if (_report == 'bs')
            OutlinedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _asOf,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked == null) return;
                setState(() => _asOf = picked);
              },
              child: Text('As of: ${_asOf.toIso8601String().split('T').first}'),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _busy ? null : _runReport,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Run report'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seedCoa({bool force = false}) async {
    setState(() => _busy = true);
    try {
      await ref.read(financialServiceProvider).seedChartOfAccounts(
            farmId: widget.farmId,
            force: force,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chart of accounts seeded')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runReport() async {
    setState(() => _busy = true);
    try {
      Map<String, dynamic> data;
      if (_report == 'pl') {
        data = await ref.read(financialServiceProvider).getProfitLoss(
              farmId: widget.farmId,
              startDate: _start,
              endDate: _end,
            );
      } else if (_report == 'bs') {
        data = await ref.read(financialServiceProvider).getBalanceSheet(
              farmId: widget.farmId,
              asOf: _asOf,
            );
      } else {
        data = await ref.read(financialServiceProvider).getCashFlow(
              farmId: widget.farmId,
              startDate: _start,
              endDate: _end,
            );
      }

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Report'),
          content: SingleChildScrollView(
            child: Text(const JsonEncoder.withIndent('  ').convert(data)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
