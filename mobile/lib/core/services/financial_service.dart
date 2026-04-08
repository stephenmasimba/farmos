import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/financial.dart';

class FinancialService {
  const FinancialService(this._api);
  final ApiClient _api;

  Future<List<Transaction>> getRecords({
    int page = 1,
    int perPage = 20,
    String? type,
    String? category,
  }) async {
    final list = await _api.getList(ApiEndpoints.financialRecords, params: {
      'page': page,
      'per_page': perPage,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
    });
    return list
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Transaction> create(Map<String, dynamic> body) async {
    final data = await _api.post(ApiEndpoints.financialRecords, data: body);
    return Transaction.fromJson(
        data['record'] as Map<String, dynamic>? ?? data);
  }

  Future<Transaction> update(int id, Map<String, dynamic> body) async {
    final data = await _api.put(ApiEndpoints.financialRecordById(id), data: body);
    return Transaction.fromJson(
        data['record'] as Map<String, dynamic>? ?? data);
  }

  Future<void> delete(int id) =>
      _api.delete(ApiEndpoints.financialRecordById(id));

  Future<FinancialSummary> getSummary() async {
    final data = await _api.get(ApiEndpoints.financialSummary);
    return FinancialSummary.fromJson(
        data['summary'] as Map<String, dynamic>? ?? data);
  }

  Future<List<MonthlyReport>> getMonthlyReport() async {
    final list = await _api.getList(ApiEndpoints.financialMonthly);
    return list
        .map((e) => MonthlyReport.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> getCategories() async {
    final list = await _api.getList(ApiEndpoints.financialCategories);
    return list.map((e) => e.toString()).toList();
  }
}
