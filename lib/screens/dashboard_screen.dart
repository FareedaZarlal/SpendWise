import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../catalog.dart';
import '../models.dart';
import '../store.dart';
import '../utils.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.store,
    required this.onAdd,
    required this.onHistory,
    required this.onBudgets,
  });

  final SpendWiseStore store;
  final VoidCallback onAdd;
  final VoidCallback onHistory;
  final VoidCallback onBudgets;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _month = demoMonth;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final transactions = widget.store.transactions
            .where((item) => sameMonth(item.date, _month))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        final expenses = transactions
            .where((item) => item.type == TransactionType.expense)
            .toList();
        final income = transactions
            .where((item) => item.type == TransactionType.income)
            .fold<int>(0, (total, item) => total + item.amountMinor);
        final spent =
            expenses.fold<int>(0, (total, item) => total + item.amountMinor);
        final budgets = widget.store.budgets
            .where((item) => sameMonth(item.month, _month))
            .toList();
        final totalBudget =
            budgets.fold<int>(0, (total, item) => total + item.limitMinor);
        final remaining = totalBudget - spent;

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 112),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SPENDWISE',
                          style: TextStyle(
                            color: SpendColors.positive,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'Your spending',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: SpendColors.lime,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Text(
                      'AJ',
                      style: TextStyle(
                        color: SpendColors.brand,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              MonthPicker(
                month: _month,
                onChanged: (month) => setState(() => _month = month),
              ),
              const SizedBox(height: 4),
              _BalanceCard(
                income: income,
                spent: spent,
                totalBudget: totalBudget,
                remaining: remaining,
              ),
              const SizedBox(height: 26),
              SectionHeading(
                title: 'Budget snapshot',
                subtitle: 'How your categories are doing',
                action: 'View all',
                onAction: widget.onBudgets,
              ),
              const SizedBox(height: 13),
              if (budgets.isEmpty)
                Card(
                  child: AppEmptyState(
                    compact: true,
                    title: 'No budgets yet',
                    body:
                        'Create a category budget to see your monthly snapshot.',
                    action: 'Set a budget',
                    onAction: widget.onBudgets,
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 11,
                    mainAxisSpacing: 11,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: budgets.length > 4 ? 4 : budgets.length,
                  itemBuilder: (context, index) {
                    final budget = budgets[index];
                    final category = categoryById(budget.categoryId);
                    final categorySpent = expenses
                        .where((item) => item.categoryId == budget.categoryId)
                        .fold<int>(
                          0,
                          (total, item) => total + item.amountMinor,
                        );
                    return _BudgetSnapshotCard(
                      category: category,
                      spent: categorySpent,
                      limit: budget.limitMinor,
                    );
                  },
                ),
              const SizedBox(height: 28),
              SectionHeading(
                title: 'Recent activity',
                subtitle: '${transactions.length} transactions this month',
                action: 'See all',
                onAction: widget.onHistory,
              ),
              const SizedBox(height: 13),
              if (transactions.isEmpty)
                Card(
                  child: AppEmptyState(
                    compact: true,
                    title: 'No activity yet',
                    body: 'Add your first transaction to get started.',
                    action: 'Add transaction',
                    onAction: widget.onAdd,
                  ),
                )
              else
                TransactionListCard(
                  children: transactions
                      .take(4)
                      .map((item) => TransactionTile(transaction: item))
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.income,
    required this.spent,
    required this.totalBudget,
    required this.remaining,
  });

  final int income;
  final int spent;
  final int totalBudget;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final progress = totalBudget == 0 ? 0.0 : spent / totalBudget;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SpendColors.brand,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33203F34),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Left to spend',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 5),
          FittedBox(
            child: Text(
              formatMoney(remaining),
              style: TextStyle(
                color: remaining < 0 ? const Color(0xFFFFC2BA) : Colors.white,
                fontSize: 35,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            totalBudget == 0
                ? 'Set up budgets to track your month'
                : '${formatMoney(spent)} of ${formatMoney(totalBudget)} used',
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          if (remaining < 0) ...[
            const SizedBox(height: 11),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: SpendColors.danger.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                'You’re ${formatMoney(remaining.abs())} over budget',
                style: const TextStyle(
                  color: Color(0xFFFFD7D2),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0).toDouble(),
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(SpendColors.lime),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _BalanceStat(
                  icon: Icons.south_rounded,
                  label: 'Income',
                  value: formatMoney(income),
                  color: SpendColors.lime,
                ),
              ),
              Expanded(
                child: _BalanceStat(
                  icon: Icons.north_rounded,
                  label: 'Spent',
                  value: formatMoney(spent),
                  color: const Color(0xFFFFC2BA),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  const _BalanceStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 1),
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BudgetSnapshotCard extends StatelessWidget {
  const _BudgetSnapshotCard({
    required this.category,
    required this.spent,
    required this.limit,
  });

  final SpendCategory category;
  final int spent;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final percent = limit == 0 ? 0.0 : spent / limit;
    final over = spent > limit;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryAvatar(category: category, compact: true),
                const Spacer(),
                Text(
                  '${(percent * 100).round()}%',
                  style: TextStyle(
                    color: over ? SpendColors.danger : SpendColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              category.name,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 2),
            FittedBox(
              child: Text(
                '${formatMoney(spent)} / ${formatMoney(limit)}',
                style: const TextStyle(
                  color: SpendColors.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 9),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: percent.clamp(0.0, 1.0).toDouble(),
                minHeight: 4,
                backgroundColor: SpendColors.canvas,
                valueColor: AlwaysStoppedAnimation(
                  over ? SpendColors.danger : SpendColors.positive,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
