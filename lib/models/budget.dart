import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 1)
class Budget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String category;

  @HiveField(2)
  double amount;

  @HiveField(3)
  double spent;

  @HiveField(4)
  DateTime startDate;

  @HiveField(5)
  DateTime endDate;

  @HiveField(6)
  String? description;

  @HiveField(7)
  bool isActive;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    this.spent = 0.0,
    required this.startDate,
    required this.endDate,
    this.description,
    this.isActive = true,
  });

  double get remaining => amount - spent;
  double get percentageUsed => (spent / amount) * 100;
  
  BudgetStatus get status {
    if (percentageUsed >= 100) return BudgetStatus.exceeded;
    if (percentageUsed >= 80) return BudgetStatus.warning;
    if (percentageUsed >= 50) return BudgetStatus.onTrack;
    return BudgetStatus.good;
  }

  bool get isExpired => DateTime.now().isAfter(endDate);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'spent': spent,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'description': description,
      'isActive': isActive,
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      category: json['category'],
      amount: json['amount'].toDouble(),
      spent: json['spent']?.toDouble() ?? 0.0,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      description: json['description'],
      isActive: json['isActive'] ?? true,
    );
  }
}

enum BudgetStatus {
  good,
  onTrack,
  warning,
  exceeded,
}

class BudgetProgress {
  final String category;
  final double budgetAmount;
  final double spentAmount;
  final double remainingAmount;
  final double percentage;
  final BudgetStatus status;

  BudgetProgress({
    required this.category,
    required this.budgetAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.percentage,
    required this.status,
  });

  factory BudgetProgress.fromBudget(Budget budget) {
    return BudgetProgress(
      category: budget.category,
      budgetAmount: budget.amount,
      spentAmount: budget.spent,
      remainingAmount: budget.remaining,
      percentage: budget.percentageUsed,
      status: budget.status,
    );
  }
}
