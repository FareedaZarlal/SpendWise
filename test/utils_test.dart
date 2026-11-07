import 'package:flutter_test/flutter_test.dart';
import 'package:spending_tracker/catalog.dart';
import 'package:spending_tracker/models.dart';
import 'package:spending_tracker/utils.dart';

void main() {
  test('parses rupee input into integer minor units', () {
    expect(parseMinorUnits('1250'), 125000);
    expect(parseMinorUnits('1250.5'), 125050);
    expect(parseMinorUnits('1250.50'), 125050);
    expect(parseMinorUnits('0'), 0);
    expect(parseMinorUnits('-1'), isNull);
    expect(parseMinorUnits('12.345'), isNull);
    expect(parseMinorUnits('not a number'), isNull);
  });

  test('November 2026 sample totals are consistent', () {
    final transactions = seedTransactions();
    final budgets = seedBudgets();
    final income = transactions
        .where((item) => item.type == TransactionType.income)
        .fold<int>(0, (total, item) => total + item.amountMinor);
    final expenses = transactions
        .where((item) => item.type == TransactionType.expense)
        .fold<int>(0, (total, item) => total + item.amountMinor);
    final budget =
        budgets.fold<int>(0, (total, item) => total + item.limitMinor);

    expect(income, 16500000);
    expect(expenses, 3555000);
    expect(budget, 7200000);
    expect(budget - expenses, 3645000);
    expect(
      transactions.every((item) => !item.date.isAfter(demoToday)),
      isTrue,
    );
  });

  test('money formatting keeps negative remaining values visible', () {
    expect(formatMoney(3645000), 'Rs. 36,450');
    expect(formatMoney(-200000), '−Rs. 2,000');
  });
}
