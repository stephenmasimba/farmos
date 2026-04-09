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

  Future<List<String>> getCategories() async {
    final list = await _api.getList(ApiEndpoints.financialCategories);
    return list.map((e) => e.toString()).toList();
  }

  Future<Map<String, dynamic>> getAccountingSnapshot() async {
    final trial = await _api.get(ApiEndpoints.accountingTrialBalance);
    final receivables = await _api.get(ApiEndpoints.accountingReceivables);
    final payables = await _api.get(ApiEndpoints.accountingPayables);

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
    };
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
