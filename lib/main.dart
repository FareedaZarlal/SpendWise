import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'models.dart';
import 'screens/budget_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/search_screen.dart';
import 'screens/transaction_form_screen.dart';
import 'store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await SpendWiseStore.load();
  runApp(SpendWiseApp(store: store));
}

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key, required this.store});

  final SpendWiseStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendWise',
      debugShowCheckedModeBanner: false,
      theme: spendWiseTheme(),
      home: AppShell(store: store),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.store});

  final SpendWiseStore store;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  Future<void> _openTransaction([SpendTransaction? initial]) async {
    final result = await Navigator.of(context).push<SpendTransaction>(
      MaterialPageRoute(
        builder: (context) => TransactionFormScreen(initial: initial),
      ),
    );
    if (result == null) return;
    final editing = initial != null;
    await widget.store.saveTransaction(result);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editing ? 'Transaction updated' : 'Transaction saved',
          ),
        ),
      );
      if (!editing) setState(() => _selectedIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentIndex =
        _selectedIndex <= 1 ? _selectedIndex : _selectedIndex - 1;
    return Scaffold(
      body: IndexedStack(
        index: contentIndex,
        children: [
          DashboardScreen(
            store: widget.store,
            onAdd: _openTransaction,
            onHistory: () => setState(() => _selectedIndex = 1),
            onBudgets: () => setState(() => _selectedIndex = 3),
          ),
          HistoryScreen(
            store: widget.store,
            onAdd: _openTransaction,
            onEdit: _openTransaction,
          ),
          BudgetsScreen(store: widget.store),
          SearchScreen(store: widget.store),
        ],
      ),
      bottomNavigationBar: _SpendNavigation(
        selectedIndex: _selectedIndex,
        onSelected: (index) {
          if (index == 2) {
            _openTransaction();
          } else {
            setState(() => _selectedIndex = index);
          }
        },
      ),
    );
  }
}

class _SpendNavigation extends StatelessWidget {
  const _SpendNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: SpendColors.line)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: selectedIndex == 0,
                onTap: () => onSelected(0),
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: 'History',
                selected: selectedIndex == 1,
                onTap: () => onSelected(1),
              ),
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Add transaction',
                  child: InkWell(
                    onTap: () => onSelected(2),
                    child: Transform.translate(
                      offset: const Offset(0, -13),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: SpendColors.lime,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33203F34),
                                  blurRadius: 16,
                                  offset: Offset(0, 7),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: SpendColors.brand,
                              size: 27,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Add',
                            style: TextStyle(
                              color: SpendColors.inkSubtle,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Budgets',
                selected: selectedIndex == 3,
                onTap: () => onSelected(3),
              ),
              _NavItem(
                icon: Icons.search_rounded,
                label: 'Search',
                selected: selectedIndex == 4,
                onTap: () => onSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? SpendColors.brand : SpendColors.muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          button: true,
          selected: selected,
          label: label,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 23),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
