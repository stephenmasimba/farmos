import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/financial.dart';
import 'cache_status_service.dart';
import 'sync_service.dart';

class FinancialService {
  const FinancialService(this._api, this._sync, this._cacheStatus);
  final ApiClient _api;
  final SyncService _sync;
  final CacheStatusService _cacheStatus;

  static const recordsStatusKey = 'financial:records';
  static const summaryStatusKey = 'financial:summary';
  static const monthlyStatusKey = 'financial:monthly';

  String _recordsCacheKey(String? type, String? category) =>
      'financial_records_${type ?? 'all'}_${category ?? 'all'}';
  String _summaryCacheKey() => 'financial_summary';
  String _monthlyCacheKey() => 'financial_monthly';

  Future<List<Transaction>> getRecords({
    int page = 1,
    int perPage = 20,
    String? type,
    String? category,
  }) async {
    try {
      final list = await _api.getList(ApiEndpoints.financialRecords, params: {
        'page': page,
        'per_page': perPage,
        if (type != null) 'type': type,
        if (category != null) 'category': category,
      });
      await _sync.cache(_recordsCacheKey(type, category), {'items': list});
      _cacheStatus.markFresh(recordsStatusKey);
      final base = list
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();
      return _applyQueuedChanges(base, type: type, category: category);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_recordsCacheKey(type, category));
      final items = cached?.payload['items'] as List<dynamic>?;
      if (items != null) {
        _cacheStatus.markOffline(
          recordsStatusKey,
          lastUpdatedAt: cached?.updatedAt,
        );
        final base = items
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
        return _applyQueuedChanges(base, type: type, category: category);
      }
      rethrow;
    }
  }

  Future<Transaction> create(Map<String, dynamic> body) async {
    try {
      final data = await _api.post(ApiEndpoints.financialRecords, data: body);
      return Transaction.fromJson(
          data['record'] as Map<String, dynamic>? ?? data);
    } on ApiException catch (e) {
      if (!_shouldQueue(e)) rethrow;
      await _sync.enqueue(
        method: 'POST',
        path: ApiEndpoints.financialRecords,
        body: body,
      );
      return _optimisticTransaction(body);
    }
  }

  Future<Transaction> update(int id, Map<String, dynamic> body) async {
    try {
      final data = await _api.put(ApiEndpoints.financialRecordById(id), data: body);
      return Transaction.fromJson(
          data['record'] as Map<String, dynamic>? ?? data);
    } on ApiException catch (e) {
      if (!_shouldQueue(e)) rethrow;
      await _sync.enqueue(
        method: 'PUT',
        path: ApiEndpoints.financialRecordById(id),
        body: body,
      );
      return _optimisticTransaction(body, fallbackId: id);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _api.delete(ApiEndpoints.financialRecordById(id));
    } on ApiException catch (e) {
      if (!_shouldQueue(e)) rethrow;
      await _sync.enqueue(
        method: 'DELETE',
        path: ApiEndpoints.financialRecordById(id),
      );
    }
  }

  Future<FinancialSummary> getSummary() async {
    try {
      final data = await _api.get(ApiEndpoints.financialSummary);
      final payload = data['summary'] as Map<String, dynamic>? ?? data;
      await _sync.cache(_summaryCacheKey(), payload);
      _cacheStatus.markFresh(summaryStatusKey);
      return FinancialSummary.fromJson(payload);
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_summaryCacheKey());
      if (cached != null) {
        _cacheStatus.markOffline(
          summaryStatusKey,
          lastUpdatedAt: cached.updatedAt,
        );
        return FinancialSummary.fromJson(cached.payload);
      }
      rethrow;
    }
  }

  Future<List<MonthlyReport>> getMonthlyReport() async {
    try {
      final list = await _api.getList(ApiEndpoints.financialMonthly);
      await _sync.cache(_monthlyCacheKey(), {'items': list});
      _cacheStatus.markFresh(monthlyStatusKey);
      return list
          .map((e) => MonthlyReport.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode != null) rethrow;
      final cached = await _sync.readCacheEntry(_monthlyCacheKey());
      final items = cached?.payload['items'] as List<dynamic>?;
      if (items != null) {
        _cacheStatus.markOffline(
          monthlyStatusKey,
          lastUpdatedAt: cached?.updatedAt,
        );
        return items
            .map((e) => MonthlyReport.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBudgetVariance({int? farmId, int? year, int? month}) async {
    final params = <String, dynamic>{
      if (farmId != null) 'farm_id': farmId,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
    };
    return _api.get(
      ApiEndpoints.financialBudgetVariance,
      params: params.isNotEmpty ? params : null,
    );
  }

  Future<List<dynamic>> getCategoryMappings({int? farmId}) async {
    return _api.getList(
      ApiEndpoints.financialCategoryMappings,
      params: farmId != null ? {'farm_id': farmId} : null,
    );
  }

  Future<List<dynamic>> getFinancialPeriods({int? farmId}) async {
    return _api.getList(
      ApiEndpoints.financialPeriods,
      params: farmId != null ? {'farm_id': farmId} : null,
    );
  }

  Future<List<String>> getCategories() async {
    final list = await _api.getList(ApiEndpoints.financialCategories);
    return list.map((e) => e.toString()).toList();
  }

  Future<Map<String, dynamic>> getAccountingSnapshot() async {
    final trial = await _api.get(ApiEndpoints.accountingTrialBalance);
    final receivables = await _api.get(ApiEndpoints.accountingReceivables);
    final payables = await _api.get(ApiEndpoints.accountingPayables);

    final entities = await _safeGetList(ApiEndpoints.accountingEntities);
    final currencies = await _safeGetList(ApiEndpoints.accountingCurrencies);
    final bankAccounts = await _safeGetList(ApiEndpoints.accountingBankAccounts);
    final fixedAssets = await _safeGetList(ApiEndpoints.accountingFixedAssets);
    final taxCodes = await _safeGetList(ApiEndpoints.accountingTaxCodes);
    final approvals = await _safeGetList(ApiEndpoints.accountingJournalApprovals);

    final arItems =
        (receivables['items'] as List<dynamic>?) ?? const <dynamic>[];
    final apItems = (payables['items'] as List<dynamic>?) ?? const <dynamic>[];

    int countOpen(List<dynamic> items) {
      return items.where((e) {
        if (e is! Map) return false;
        return (e['status']?.toString().toLowerCase() ?? 'open') == 'open';
      }).length;
    }

    return {
      'is_balanced': trial['is_balanced'] == true,
      'total_debits':
          double.tryParse((trial['total_debits'] ?? '0').toString()) ?? 0.0,
      'total_credits':
          double.tryParse((trial['total_credits'] ?? '0').toString()) ?? 0.0,
      'open_receivables': countOpen(arItems),
      'open_payables': countOpen(apItems),
      'entity_count': entities.length,
      'currency_count': currencies.length,
      'bank_account_count': bankAccounts.length,
      'fixed_asset_count': fixedAssets.length,
      'tax_code_count': taxCodes.length,
      'journal_approval_count': approvals.length,
    };
  }

  Future<Map<String, dynamic>> seedChartOfAccounts({
    required int farmId,
    bool force = false,
  }) async {
    return _api.post(ApiEndpoints.accountingSeedCoa, data: {
      'farm_id': farmId,
      if (force) 'force': 1,
    });
  }

  Future<Map<String, dynamic>> getProfitLoss({
    required int farmId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return _api.get(ApiEndpoints.accountingProfitLoss, params: {
      'farm_id': farmId,
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate),
    });
  }

  Future<Map<String, dynamic>> getBalanceSheet({
    required int farmId,
    required DateTime asOf,
  }) async {
    return _api.get(ApiEndpoints.accountingBalanceSheet, params: {
      'farm_id': farmId,
      'as_of': _formatDate(asOf),
    });
  }

  Future<Map<String, dynamic>> getCashFlow({
    required int farmId,
    required DateTime startDate,
    required DateTime endDate,
    List<int>? cashAccountIds,
  }) async {
    return _api.get(ApiEndpoints.accountingCashFlow, params: {
      'farm_id': farmId,
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate),
      if (cashAccountIds != null && cashAccountIds.isNotEmpty)
        'cash_account_ids': cashAccountIds.join(','),
    });
  }

  Future<Map<String, dynamic>> getJournalEntryDetails({
    required int farmId,
    required int entryId,
  }) async {
    return _api.get(ApiEndpoints.accountingJournalEntryById(entryId), params: {
      'farm_id': farmId,
    });
  }

  Future<Map<String, dynamic>> reverseJournalEntry({
    required int farmId,
    required int entryId,
    DateTime? reverseDate,
  }) async {
    return _api.post(ApiEndpoints.accountingJournalEntryReverse(entryId), data: {
      'farm_id': farmId,
      'reverse_date': _formatDate(reverseDate ?? DateTime.now()),
    });
  }

  String _formatDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<List<dynamic>> _safeGetList(String path) async {
    try {
      return await _api.getList(path);
    } on ApiException {
      return const <dynamic>[];
    }
  }

  bool _shouldQueue(ApiException e) => e.statusCode == null;

  Future<List<Transaction>> _applyQueuedChanges(
    List<Transaction> base, {
    String? type,
    String? category,
  }) async {
    final queue =
        await _sync.getPendingItemsByPathPrefix(ApiEndpoints.financialRecords);
    var list = List<Transaction>.from(base);

    for (final item in queue) {
      final body = item.body;
      final id = _extractId(item.path);

      if (item.method == 'POST' && item.path == ApiEndpoints.financialRecords && body != null) {
        list.insert(0, _optimisticTransaction(body, localId: -item.id));
        continue;
      }

      if (item.method == 'PUT' && id != null && body != null) {
        final index = list.indexWhere((entry) => entry.id == id);
        final optimistic = _optimisticTransaction(body, fallbackId: id);
        if (index >= 0) {
          list[index] = optimistic;
        } else {
          list.insert(0, optimistic);
        }
        continue;
      }

      if (item.method == 'DELETE' && id != null) {
        list.removeWhere((entry) => entry.id == id);
      }
    }

    return list.where((entry) {
      if (type != null && entry.transactionType != type) return false;
      if (category != null && entry.category != category) return false;
      return true;
    }).toList();
  }

  int? _extractId(String path) {
    final match = RegExp(r'^/api/financial/records/(\d+)').firstMatch(path);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  Transaction _optimisticTransaction(Map<String, dynamic> body,
      {int? fallbackId, int? localId}) {
    double toDouble(dynamic v) =>
        v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

    final txDate = DateTime.tryParse((body['transaction_date'] ?? '').toString()) ??
        DateTime.now();

    return Transaction(
      id: fallbackId ?? localId ?? -DateTime.now().millisecondsSinceEpoch,
      transactionCode: 'PENDING-${DateTime.now().millisecondsSinceEpoch}',
      transactionType: (body['transaction_type'] as String?) ?? 'expense',
      category: (body['category'] as String?) ?? 'Other',
      amount: toDouble(body['amount']),
      transactionDate: txDate,
      description: body['description'] as String?,
      paymentMethod: body['payment_method'] as String?,
      referenceId: body['reference_id'] as String?,
    );
  }
}
