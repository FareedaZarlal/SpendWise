import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../catalog.dart';
import '../models.dart';
import '../utils.dart';
import '../widgets/common.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, this.initial});

  final SpendTransaction? initial;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late TransactionType _type;
  late String _categoryId;
  late DateTime _date;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _type = initial?.type ?? TransactionType.expense;
    _categoryId = initial?.categoryId ?? 'food';
    _date = initial?.date ?? demoToday;
    _amountController = TextEditingController(
      text: initial == null ? '' : (initial.amountMinor / 100).toString(),
    );
    _noteController = TextEditingController(text: initial?.note ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _changeType(TransactionType type) {
    setState(() {
      _type = type;
      final options = categoriesFor(type);
      if (!options.any((item) => item.id == _categoryId)) {
        _categoryId = options.first.id;
      }
    });
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: demoToday,
    );
    if (value != null) setState(() => _date = value);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final amount = parseMinorUnits(_amountController.text);
    if (amount == null || amount <= 0 || _date.isAfter(demoToday)) return;
    Navigator.pop(
      context,
      SpendTransaction(
        id: widget.initial?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        type: _type,
        amountMinor: amount,
        date: _date,
        categoryId: _categoryId,
        note: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = categoriesFor(_type);
    return Scaffold(
      backgroundColor: SpendColors.surface,
      appBar: AppBar(
        backgroundColor: SpendColors.brandSoft,
        title: Text(_editing ? 'Edit transaction' : 'New transaction'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        label: 'Expense',
                        icon: Icons.north_rounded,
                        selected: _type == TransactionType.expense,
                        onTap: () => _changeType(TransactionType.expense),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _TypeButton(
                        label: 'Income',
                        icon: Icons.south_rounded,
                        selected: _type == TransactionType.income,
                        onTap: () => _changeType(TransactionType.income),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'Amount',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SpendColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              TextFormField(
                controller: _amountController,
                autofocus: !_editing,
                textAlign: TextAlign.center,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d{0,2}'),
                  ),
                ],
                style: const TextStyle(
                  color: SpendColors.ink,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
                decoration: const InputDecoration(
                  prefixText: 'Rs. ',
                  hintText: '0.00',
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                validator: (value) {
                  final amount = parseMinorUnits(value ?? '');
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount greater than Rs. 0.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
                  child: Column(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            prefixIcon: Icon(Icons.calendar_today_rounded),
                          ),
                          child: Text(formatDate(_date)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _categoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: options
                            .map(
                              (category) => DropdownMenuItem(
                                value: category.id,
                                child: Row(
                                  children: [
                                    CategoryAvatar(
                                      category: category,
                                      compact: true,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(category.name),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _categoryId = value!),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _noteController,
                        maxLength: 80,
                        decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                          hintText: 'What was this for?',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 17),
              const Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: SpendColors.positiveSoft,
                    child: Icon(
                      Icons.check_rounded,
                      size: 17,
                      color: SpendColors.positive,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stored safely on this device',
                          style: TextStyle(
                            color: SpendColors.inkSubtle,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Your entries remain available when you’re offline.',
                          style:
                              TextStyle(color: SpendColors.muted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              FilledButton(
                onPressed: _save,
                child: Text(
                  _editing ? 'Update transaction' : 'Save transaction',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return selected
        ? FilledButton.tonalIcon(
            onPressed: onTap,
            icon: Icon(icon, size: 17),
            label: Text(label),
          )
        : TextButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 17),
            label: Text(label),
          );
  }
}
