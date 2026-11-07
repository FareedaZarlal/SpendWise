import 'package:intl/intl.dart';

final _numberFormat = NumberFormat('#,##0.##', 'en_PK');
final _monthFormat = DateFormat('MMMM yyyy');
final _dateFormat = DateFormat('MMM d, yyyy');

String formatMoney(int minor, {bool showPlus = false}) {
  final prefix = minor < 0
      ? '−'
      : showPlus && minor > 0
          ? '+'
          : '';
  return '${prefix}Rs. ${_numberFormat.format(minor.abs() / 100)}';
}

String formatMonth(DateTime value) => _monthFormat.format(value);
String formatDate(DateTime value) => _dateFormat.format(value);

DateTime monthOnly(DateTime value) => DateTime(value.year, value.month);
bool sameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

DateTime shiftMonth(DateTime month, int offset) =>
    DateTime(month.year, month.month + offset);

int? parseMinorUnits(String input) {
  final normalized = input.trim();
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(normalized)) return null;
  final parts = normalized.split('.');
  final whole = int.parse(parts.first);
  final minor = parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0'));
  return whole * 100 + minor;
}
