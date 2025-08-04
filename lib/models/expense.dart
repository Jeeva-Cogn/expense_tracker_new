import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String category;

  @HiveField(5)
  String? description;

  @HiveField(6)
  bool isExpense;

  @HiveField(7)
  String? receipt;

  @HiveField(8)
  Map<String, dynamic>? tags;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.description,
    this.isExpense = true,
    this.receipt,
    this.tags,
  });

  bool get isIncome => !isExpense;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'description': description,
      'isExpense': isExpense,
      'receipt': receipt,
      'tags': tags,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      category: json['category'],
      description: json['description'],
      isExpense: json['isExpense'] ?? true,
      receipt: json['receipt'],
      tags: json['tags'],
    );
  }
}

enum ExpenseType {
  food,
  transport,
  entertainment,
  shopping,
  bills,
  health,
  education,
  travel,
  investment,
  other,
}

extension ExpenseTypeExtension on ExpenseType {
  String get displayName {
    switch (this) {
      case ExpenseType.food:
        return 'Food & Dining';
      case ExpenseType.transport:
        return 'Transportation';
      case ExpenseType.entertainment:
        return 'Entertainment';
      case ExpenseType.shopping:
        return 'Shopping';
      case ExpenseType.bills:
        return 'Bills & Utilities';
      case ExpenseType.health:
        return 'Healthcare';
      case ExpenseType.education:
        return 'Education';
      case ExpenseType.travel:
        return 'Travel';
      case ExpenseType.investment:
        return 'Investment';
      case ExpenseType.other:
        return 'Other';
    }
  }

  String get iconPath {
    switch (this) {
      case ExpenseType.food:
        return 'assets/icons/food.png';
      case ExpenseType.transport:
        return 'assets/icons/transport.png';
      case ExpenseType.entertainment:
        return 'assets/icons/entertainment.png';
      case ExpenseType.shopping:
        return 'assets/icons/shopping.png';
      case ExpenseType.bills:
        return 'assets/icons/bills.png';
      case ExpenseType.health:
        return 'assets/icons/health.png';
      case ExpenseType.education:
        return 'assets/icons/other.png';
      case ExpenseType.travel:
        return 'assets/icons/transport.png';
      case ExpenseType.investment:
        return 'assets/icons/other.png';
      case ExpenseType.other:
        return 'assets/icons/other.png';
    }
  }
}
