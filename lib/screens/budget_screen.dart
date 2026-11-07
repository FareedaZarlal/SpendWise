import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../catalog.dart';
import '../models.dart';
import '../store.dart';
import '../utils.dart';
import '../widgets/common.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key, required this.store});

  final SpendWiseStore store;

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  DateTime _month = demoMonth;

  Future<void> _openBudgetEditor([CategoryBudget? existing]) async {
    final controller = TextEditingController(
      text: existing == null ? '' : (existing.limitMinor / 100).toString(),
    );
    var categoryId = existing?.categoryId ?? 'food';
    String? error;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            12,
            22,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: SpendColors.line,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  existing == null ? 'Create budget' : 'Edit budget',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  formatMonth(_month),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categoriesFor(TransactionType.expense)
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  onChanged: existing == null
                      ? (value) => setSheetState(() => categoryId = value!)
                      : null,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Monthly limit',
                    prefixText: 'Rs. ',
                    errorText: error,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final amount = parseMinorUnits(controller.text);
                      if (amount == null || amount <= 0) {
                        setSheetState(
                          () => error =
                              'Enter a valid amount greater than Rs. 0.',
                        );
                        return;
                      }
                      await widget.store.saveBudget(
                        month: _month,
                        categoryId: categoryId,
                        limitMinor: amount,
                      );
                      if (context.mounted) Navigator.pop(context, true);
                    },
                    child: Text(
                      existing == null ? 'Create budget' : 'Update budget',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    controller.dispose();
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existing == null ? 'Budget created' : 'Budget updated'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final budgets = widget.store.budgets
            .where((item) => sameMonth(item.month, _month))
            .toList();
        final expenses = widget.store.transactions
            .where(
              (item) =>
                  item.type == TransactionType.expense &&
                  sameMonth(item.date, _month),
            )
            .toList();
        final totalBudget =
            budgets.fold<int>(0, (total, item) => total + item.limitMinor);
        final totalSpent =
            expenses.fold<int>(0, (total, item) => total + item.amountMinor);
        final remaining = totalBudget - totalSpent;

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 112),
            children: [
              PageHeading(
                eyebrow: 'Plan before you spend',
                title: 'Monthly budgets',
                trailing: FilledButton.tonalIcon(
                  onPressed: _openBudgetEditor,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                ),
              ),
              const SizedBox(height: 17),
              MonthPicker(
                month: _month,
                onChanged: (month) => setState(() => _month = month),
              ),
              const SizedBox(height: 5),
              _BudgetSummary(
                totalBudget: totalBudget,
                totalSpent: totalSpent,
                remaining: remaining,
              ),
              const SizedBox(height: 25),
              SectionHeading(
                title: 'Categories',
                subtitle: '${budgets.length} active budgets',
              ),
              const SizedBox(height: 13),
              if (budgets.isEmpty)
                Card(
                  child: AppEmptyState(
                    title: 'Give every category a limit',
                    body:
                        'Budgets help you make confident choices before the month gets away from you.',
                    action: 'Create budget',
                    onAction: _openBudgetEditor,
                  ),
                )
              else
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: budgets.map((budget) {
                      final spent = expenses
                          .where(
                            (item) => item.categoryId == budget.categoryId,
                          )
                          .fold<int>(
                            0,
                            (total, item) => total + item.amountMinor,
                          );
                      return _BudgetRow(
                        budget: budget,
                        spent: spent,
                        onEdit: () => _openBudgetEditor(budget),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BudgetSummary extends StatelessWidget {
  const _BudgetSummary({
    required this.totalBudget,
    required this.totalSpent,
    required this.remaining,
  });

  final int totalBudget;
  final int totalSpent;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final progress = totalBudget == 0 ? 0.0 : totalSpent / totalBudget;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            SizedBox(
              width: 94,
              height: 94,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress.clamp(0.0, 1.0).toDouble(),
                      strokeWidth: 10,
                      backgroundColor: SpendColors.canvas,
                      valueColor: AlwaysStoppedAnimation(
                        progress > 1 ? SpendColors.danger : SpendColors.lime,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          color: SpendColors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'used',
                        style:
                            TextStyle(color: SpendColors.muted, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly budget',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    child: Text(
                      formatMoney(totalBudget),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 24,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SummaryLine(label: 'Spent', value: formatMoney(totalSpent)),
                  const SizedBox(height: 4),
                  _SummaryLine(
                    label: 'Remaining',
                    value: formatMoney(remaining),
                    danger: remaining < 0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.danger = false,
  });

  final String label;
  final String value;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? SpendColors.danger : SpendColors.inkSubtle;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: color, fontSize: 10),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.budget,
    required this.spent,
    required this.onEdit,
  });

  final CategoryBudget budget;
  final int spent;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final category = categoryById(budget.categoryId);
    final progress = budget.limitMinor == 0 ? 0.0 : spent / budget.limitMinor;
    final over = spent > budget.limitMinor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SpendColors.line)),
      ),
      child: Row(
        children: [
          CategoryAvatar(category: category),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          color: SpendColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      over
                          ? '${formatMoney(spent - budget.limitMinor)} over limit'
                          : '${formatMoney(budget.limitMinor - spent)} left',
                      style: TextStyle(
                        color: over ? SpendColors.danger : SpendColors.positive,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '${formatMoney(spent)} spent',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      'of ${formatMoney(budget.limitMinor)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0).toDouble(),
                    minHeight: 5,
                    backgroundColor: SpendColors.canvas,
                    valueColor: AlwaysStoppedAnimation(
                      over ? SpendColors.danger : SpendColors.positive,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit ${category.name} budget',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, size: 19),
          ),
        ],
      ),
    );
  }
}
