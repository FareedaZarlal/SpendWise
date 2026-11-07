import 'package:flutter/material.dart';

import 'models.dart';

final demoToday = DateTime(2026, 11, 2);
final demoMonth = DateTime(2026, 11);

class SpendCategory {
  const SpendCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.type,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final TransactionType? type;
}

const categories = <SpendCategory>[
  SpendCategory(
    id: 'food',
    name: 'Food',
    icon: Icons.restaurant_rounded,
    color: Color(0xFFEC765F),
    type: TransactionType.expense,
  ),
  SpendCategory(
    id: 'transport',
    name: 'Transport',
    icon: Icons.directions_bus_rounded,
    color: Color(0xFF5C8FCE),
    type: TransactionType.expense,
  ),
  SpendCategory(
    id: 'study',
    name: 'Study',
    icon: Icons.school_rounded,
    color: Color(0xFF8A72C7),
    type: TransactionType.expense,
  ),
  SpendCategory(
    id: 'shopping',
    name: 'Shopping',
    icon: Icons.shopping_bag_rounded,
    color: Color(0xFFC96F85),
    type: TransactionType.expense,
  ),
  SpendCategory(
    id: 'coffee',
    name: 'Coffee',
    icon: Icons.coffee_rounded,
    color: Color(0xFF4F9F80),
    type: TransactionType.expense,
  ),
  SpendCategory(
    id: 'entertainment',
    name: 'Entertainment',
    icon: Icons.sports_esports_rounded,
    color: Color(0xFFDB9D3E),
    type: TransactionType.expense,
  ),
  SpendCategory(
    id: 'salary',
    name: 'Salary',
    icon: Icons.payments_rounded,
    color: Color(0xFF2C8A64),
    type: TransactionType.income,
  ),
  SpendCategory(
    id: 'freelancing',
    name: 'Freelancing',
    icon: Icons.laptop_mac_rounded,
    color: Color(0xFF5C8FCE),
    type: TransactionType.income,
  ),
  SpendCategory(
    id: 'other',
    name: 'Other',
    icon: Icons.more_horiz_rounded,
    color: Color(0xFF87928C),
  ),
];

SpendCategory categoryById(String id) =>
    categories.firstWhere((category) => category.id == id);

List<SpendCategory> categoriesFor(TransactionType type) => categories
    .where((category) => category.type == null || category.type == type)
    .toList();

List<SpendTransaction> seedTransactions() => [
      SpendTransaction(
        id: 'sample-1',
        type: TransactionType.expense,
        amountMinor: 850000,
        date: DateTime(2026, 11, 2),
        categoryId: 'food',
        note: 'Monthly groceries',
      ),
      SpendTransaction(
        id: 'sample-2',
        type: TransactionType.expense,
        amountMinor: 85000,
        date: DateTime(2026, 11, 2),
        categoryId: 'coffee',
        note: 'Coffee with classmates',
      ),
      SpendTransaction(
        id: 'sample-3',
        type: TransactionType.income,
        amountMinor: 4500000,
        date: DateTime(2026, 11, 2),
        categoryId: 'freelancing',
        note: 'Website project',
      ),
      SpendTransaction(
        id: 'sample-4',
        type: TransactionType.expense,
        amountMinor: 320000,
        date: DateTime(2026, 11, 2),
        categoryId: 'transport',
        note: 'Monthly bus pass',
      ),
      SpendTransaction(
        id: 'sample-5',
        type: TransactionType.income,
        amountMinor: 12000000,
        date: DateTime(2026, 11, 1),
        categoryId: 'salary',
        note: 'November salary',
      ),
      SpendTransaction(
        id: 'sample-6',
        type: TransactionType.expense,
        amountMinor: 650000,
        date: DateTime(2026, 11, 1),
        categoryId: 'study',
        note: 'Semester books',
      ),
      SpendTransaction(
        id: 'sample-7',
        type: TransactionType.expense,
        amountMinor: 1200000,
        date: DateTime(2026, 11, 1),
        categoryId: 'shopping',
        note: 'Winter clothes',
      ),
      SpendTransaction(
        id: 'sample-8',
        type: TransactionType.expense,
        amountMinor: 450000,
        date: DateTime(2026, 11, 1),
        categoryId: 'entertainment',
        note: 'Cinema tickets',
      ),
    ];

List<CategoryBudget> seedBudgets() => [
      CategoryBudget(
        id: 'budget-food',
        month: demoMonth,
        categoryId: 'food',
        limitMinor: 2500000,
      ),
      CategoryBudget(
        id: 'budget-transport',
        month: demoMonth,
        categoryId: 'transport',
        limitMinor: 1000000,
      ),
      CategoryBudget(
        id: 'budget-study',
        month: demoMonth,
        categoryId: 'study',
        limitMinor: 1500000,
      ),
      CategoryBudget(
        id: 'budget-shopping',
        month: demoMonth,
        categoryId: 'shopping',
        limitMinor: 1000000,
      ),
      CategoryBudget(
        id: 'budget-coffee',
        month: demoMonth,
        categoryId: 'coffee',
        limitMinor: 400000,
      ),
      CategoryBudget(
        id: 'budget-entertainment',
        month: demoMonth,
        categoryId: 'entertainment',
        limitMinor: 800000,
      ),
    ];
