import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.transactionCode,
    required this.transactionType,
    required this.category,
    required this.amount,
    required this.transactionDate,
    this.description,
    this.paymentMethod,
    this.referenceId,
    this.createdBy,
  });

  final int id;
  final String transactionCode;
  final String transactionType; // income | expense
  final String category;
  final double amount;
  final DateTime transactionDate;
  final String? description;
  final String? paymentMethod;
  final String? referenceId;
  final int? createdBy;

  bool get isIncome => transactionType == 'income';

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
        id: j['id'] as int,
        transactionCode: j['transaction_code'] as String? ?? '',
        transactionType: j['transaction_type'] as String? ?? 'expense',
        category: j['category'] as String? ?? '',
        amount: _parseDouble(j['amount']),
        transactionDate: _parseDate(j['transaction_date']) ?? DateTime.now(),
        description: j['description'] as String?,
        paymentMethod: j['payment_method'] as String?,
        referenceId: j['reference_id'] as String?,
        createdBy: j['created_by'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'transaction_type': transactionType,
        'category': category,
        'amount': amount,
        'transaction_date': transactionDate.toIso8601String(),
        if (description != null) 'description': description,
        if (paymentMethod != null) 'payment_method': paymentMethod,
        if (referenceId != null) 'reference_id': referenceId,
      };

  @override
  List<Object?> get props => [id, transactionCode, amount];
}

class FinancialSummary extends Equatable {
  const FinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
  });

  final double totalIncome;
  final double totalExpenses;
  final double netProfit;
  final double profitMargin;

  factory FinancialSummary.fromJson(Map<String, dynamic> j) => FinancialSummary(
        totalIncome: _parseDouble(j['total_income']),
        totalExpenses: _parseDouble(j['total_expenses']),
        netProfit: _parseDouble(j['net_profit']),
        profitMargin: _parseDouble(j['profit_margin']),
      );

  @override
  List<Object?> get props => [totalIncome, totalExpenses, netProfit];
}

class MonthlyReport extends Equatable {
  const MonthlyReport({
    required this.month,
    required this.year,
    required this.income,
    required this.expenses,
    required this.profit,
  });

  final int month;
  final int year;
  final double income;
  final double expenses;
  final double profit;

  factory MonthlyReport.fromJson(Map<String, dynamic> j) => MonthlyReport(
        month: _parseInt(j['month']),
        year: _parseInt(j['year']),
        income: _parseDouble(j['income']),
        expenses: _parseDouble(j['expenses']),
        profit: _parseDouble(j['profit']),
      );

  @override
  List<Object?> get props => [year, month];
}

double _parseDouble(dynamic v) =>
    v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

int _parseInt(dynamic v) => v == null ? 0 : int.tryParse(v.toString()) ?? 0;

DateTime? _parseDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());
