import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../catalog.dart';
import '../models.dart';
import '../store.dart';
import '../utils.dart';
import '../widgets/common.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.store,
    required this.onAdd,
    required this.onEdit,
  });

  final SpendWiseStore store;
  final VoidCallback onAdd;
  final ValueChanged<SpendTransaction> onEdit;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  TransactionType? _type;
  String? _categoryId;
  String? _monthKey;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(SpendTransaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: SpendColors.danger,
        ),
        title: const Text('Delete transaction?'),
        content: Text(
          '“${transaction.note.isEmpty ? 'This transaction' : transaction.note}” '
          'for ${formatMoney(transaction.amountMinor)} will be removed permanently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: SpendColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.store.deleteTransaction(transaction.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final monthKeys = widget.store.transactions
            .map((item) =>
                '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}')
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));
        final query = _searchController.text.trim().toLowerCase();
        final filtered = widget.store.transactions.where((item) {
          final matchesType = _type == null || item.type == _type;
          final matchesCategory =
              _categoryId == null || item.categoryId == _categoryId;
          final itemMonth =
              '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}';
          final matchesMonth = _monthKey == null || itemMonth == _monthKey;
          final matchesQuery = item.note.toLowerCase().contains(query);
          return matchesType && matchesCategory && matchesMonth && matchesQuery;
        }).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 112),
            children: [
              PageHeading(
                eyebrow: 'Every rupee, accounted for',
                title: 'Transaction history',
                trailing: FilledButton.tonalIcon(
                  onPressed: widget.onAdd,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search notes',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 13),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _TypeChip(
                      label: 'All',
                      selected: _type == null,
                      onSelected: () => setState(() => _type = null),
                    ),
                    _TypeChip(
                      label: 'Expenses',
                      selected: _type == TransactionType.expense,
                      onSelected: () =>
                          setState(() => _type = TransactionType.expense),
                    ),
                    _TypeChip(
                      label: 'Income',
                      selected: _type == TransactionType.income,
                      onSelected: () =>
                          setState(() => _type = TransactionType.income),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _categoryId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All categories'),
                        ),
                        ...categories.map(
                          (category) => DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => _categoryId = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _monthKey,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Month'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All months'),
                        ),
                        ...monthKeys.map((key) {
                          final parts = key.split('-');
                          final month = DateTime(
                              int.parse(parts[0]), int.parse(parts[1]));
                          return DropdownMenuItem(
                            value: key,
                            child: Text(formatMonth(month)),
                          );
                        }),
                      ],
                      onChanged: (value) => setState(() => _monthKey = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${filtered.length} '
                '${filtered.length == 1 ? 'transaction' : 'transactions'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                Card(
                  child: AppEmptyState(
                    title: widget.store.transactions.isEmpty
                        ? 'No transactions yet'
                        : 'Nothing matches',
                    body: widget.store.transactions.isEmpty
                        ? 'Record your first income or expense to begin tracking.'
                        : 'Try a different search or clear one of the filters.',
                    action: widget.store.transactions.isEmpty
                        ? 'Add transaction'
                        : null,
                    onAction: widget.onAdd,
                  ),
                )
              else
                TransactionListCard(
                  children: filtered
                      .map(
                        (item) => TransactionTile(
                          transaction: item,
                          onEdit: () => widget.onEdit(item),
                          onDelete: () => _confirmDelete(item),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
