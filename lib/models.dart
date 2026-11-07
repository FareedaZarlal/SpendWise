enum TransactionType { income, expense }

class SpendTransaction {
  const SpendTransaction({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.date,
    required this.categoryId,
    required this.note,
  });

  final String id;
  final TransactionType type;
  final int amountMinor;
  final DateTime date;
  final String categoryId;
  final String note;

  Map<String, Object?> toJson() => {
        'id': id,
        'type': type.name,
        'amountMinor': amountMinor,
        'date': date.toIso8601String(),
        'categoryId': categoryId,
        'note': note,
      };

  factory SpendTransaction.fromJson(Map<String, dynamic> json) {
    return SpendTransaction(
      id: json['id'] as String,
      type: TransactionType.values.byName(json['type'] as String),
      amountMinor: json['amountMinor'] as int,
      date: DateTime.parse(json['date'] as String),
      categoryId: json['categoryId'] as String,
      note: json['note'] as String,
    );
  }
}

class CategoryBudget {
  const CategoryBudget({
    required this.id,
    required this.month,
    required this.categoryId,
    required this.limitMinor,
  });

  final String id;
  final DateTime month;
  final String categoryId;
  final int limitMinor;

  CategoryBudget copyWith({int? limitMinor}) => CategoryBudget(
        id: id,
        month: month,
        categoryId: categoryId,
        limitMinor: limitMinor ?? this.limitMinor,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'month': month.toIso8601String(),
        'categoryId': categoryId,
        'limitMinor': limitMinor,
      };

  factory CategoryBudget.fromJson(Map<String, dynamic> json) {
    return CategoryBudget(
      id: json['id'] as String,
      month: DateTime.parse(json['month'] as String),
      categoryId: json['categoryId'] as String,
      limitMinor: json['limitMinor'] as int,
    );
  }
}
