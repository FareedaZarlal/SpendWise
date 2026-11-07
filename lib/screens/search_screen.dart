import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../catalog.dart';
import '../models.dart';
import '../store.dart';
import '../widgets/common.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.store});

  final SpendWiseStore store;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  TransactionType? _type;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final query = _controller.text.trim().toLowerCase();
        final results = query.isEmpty
            ? <SpendTransaction>[]
            : widget.store.transactions.where((item) {
                final category = categoryById(item.categoryId);
                return (_type == null || item.type == _type) &&
                    (item.note.toLowerCase().contains(query) ||
                        category.name.toLowerCase().contains(query));
              }).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 112),
            children: [
              const PageHeading(
                eyebrow: 'Find it in seconds',
                title: 'Search transactions',
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search notes or categories',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _controller.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: _SearchFilter(
                      label: 'All',
                      selected: _type == null,
                      onTap: () => setState(() => _type = null),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _SearchFilter(
                      label: 'Expenses',
                      selected: _type == TransactionType.expense,
                      onTap: () =>
                          setState(() => _type = TransactionType.expense),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _SearchFilter(
                      label: 'Income',
                      selected: _type == TransactionType.income,
                      onTap: () =>
                          setState(() => _type = TransactionType.income),
                    ),
                  ),
                ],
              ),
              if (query.isEmpty)
                _SearchWelcome(
                  onSuggestion: (value) {
                    _controller.text = value;
                    setState(() {});
                  },
                )
              else ...[
                const SizedBox(height: 27),
                SectionHeading(
                  title: 'Search results',
                  subtitle:
                      '${results.length} ${results.length == 1 ? 'match' : 'matches'} '
                      'for “${_controller.text.trim()}”',
                ),
                const SizedBox(height: 13),
                if (results.isEmpty)
                  Card(
                    child: AppEmptyState(
                      title: 'No matching transactions',
                      body:
                          'Try another note, category name, or transaction type.',
                      action: 'Clear search',
                      onAction: () {
                        _controller.clear();
                        setState(() {});
                      },
                    ),
                  )
                else
                  TransactionListCard(
                    children: results
                        .map((item) => TransactionTile(transaction: item))
                        .toList(),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SearchFilter extends StatelessWidget {
  const _SearchFilter({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return selected
        ? FilledButton.tonal(onPressed: onTap, child: Text(label))
        : TextButton(onPressed: onTap, child: Text(label));
  }
}

class _SearchWelcome extends StatelessWidget {
  const _SearchWelcome({required this.onSuggestion});

  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 390,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: SpendColors.positiveSoft,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: SpendColors.positive,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Search your spending',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 7),
          Text(
            'Find any transaction using its note or category, then narrow '
            'the results by income or expense.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 7,
            children: ['Food', 'Transport', 'Salary']
                .map(
                  (item) => ActionChip(
                    label: Text(item),
                    onPressed: () => onSuggestion(item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
