import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog.dart';
import 'models.dart';

class SpendWiseStore extends ChangeNotifier {
  SpendWiseStore._(this._preferences, this.transactions, this.budgets);

  static const _storageKey = 'spendwise_flutter_store_v1';
  final SharedPreferences _preferences;
  List<SpendTransaction> transactions;
  List<CategoryBudget> budgets;

  static Future<SpendWiseStore> load() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_storageKey);
    if (value == null) {
      return SpendWiseStore._(
        preferences,
        seedTransactions(),
        seedBudgets(),
      );
    }
    try {
      final json = jsonDecode(value) as Map<String, dynamic>;
      return SpendWiseStore._(
        preferences,
        (json['transactions'] as List<dynamic>)
            .map((item) =>
                SpendTransaction.fromJson(item as Map<String, dynamic>))
            .toList(),
        (json['budgets'] as List<dynamic>)
            .map(
                (item) => CategoryBudget.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      return SpendWiseStore._(
        preferences,
        seedTransactions(),
        seedBudgets(),
      );
    }
  }

  Future<void> saveTransaction(SpendTransaction transaction) async {
    final index = transactions.indexWhere((item) => item.id == transaction.id);
    if (index == -1) {
      transactions = [transaction, ...transactions];
    } else {
      transactions = [...transactions]..[index] = transaction;
    }
    await _persist();
  }

  Future<void> deleteTransaction(String id) async {
    transactions = transactions.where((item) => item.id != id).toList();
    await _persist();
  }

  Future<void> saveBudget({
    required DateTime month,
    required String categoryId,
    required int limitMinor,
  }) async {
    final index = budgets.indexWhere(
      (item) =>
          item.month.year == month.year &&
          item.month.month == month.month &&
          item.categoryId == categoryId,
    );
    if (index == -1) {
      budgets = [
        ...budgets,
        CategoryBudget(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          month: DateTime(month.year, month.month),
          categoryId: categoryId,
          limitMinor: limitMinor,
        ),
      ];
    } else {
      budgets = [...budgets]..[index] =
          budgets[index].copyWith(limitMinor: limitMinor);
    }
    await _persist();
  }

  Future<void> _persist() async {
    await _preferences.setString(
      _storageKey,
      jsonEncode({
        'version': 1,
        'transactions': transactions.map((item) => item.toJson()).toList(),
        'budgets': budgets.map((item) => item.toJson()).toList(),
      }),
    );
    notifyListeners();
  }
}
