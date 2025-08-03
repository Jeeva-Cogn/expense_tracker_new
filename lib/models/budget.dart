import 'package:hive/hive.dart';

part 'budget.g.dart';

enum BudgetType {
  monthly,
  weekly,
  daily,
  yearly,
  custom
}

enum BudgetHealth {
  excellent,
  good,
  warning,
  critical
}

enum BudgetPeriod { daily, weekly, monthly, yearly }

@HiveType(typeId: 2)
class Budget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  double limit;

  @HiveField(4)
  double spent;

  @HiveField(5)
  BudgetPeriod period;

  @HiveField(6)
  DateTime startDate;

  @HiveField(7)
  DateTime endDate;

  @HiveField(8)
  String? walletId;

  @HiveField(9)
  bool alertsEnabled;

  @HiveField(10)
  double alertThreshold;

  @HiveField(11)
  String color;

  @HiveField(12)
  bool isActive;

  @HiveField(13)
  DateTime createdAt;

  @HiveField(14)
  DateTime updatedAt;

  @HiveField(15)
  BudgetType type;

  @HiveField(16)
  List<String> excludedSubcategories;

  Budget({
    required this.id,
    required this.name,
    required this.category,
    required this.limit,
    this.spent = 0.0,
    this.period = BudgetPeriod.monthly,
    required this.startDate,
    required this.endDate,
    this.walletId,
    this.alertsEnabled = true,
    this.alertThreshold = 0.8,
    this.color = '#4CAF50',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.type = BudgetType.monthly,
    this.excludedSubcategories = const [],
  });

  // Core computed properties
  double get remaining => limit - spent;
  bool get isOverBudget => spent > limit;
  double get percentageUsed => (spent / limit * 100).clamp(0, 100);
  double get percentageRemaining => 100 - percentageUsed;
  double get spentPercentage => spent / limit;
  bool get shouldAlert => spentPercentage >= alertThreshold;

  // Time-based calculations
  int get totalDays => _getTotalDaysForPeriod();
  double get dailyBudget => limit / totalDays;
  
  int get daysLeft {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  int get daysElapsed {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    return now.difference(startDate).inDays + 1;
  }

  // Advanced analytics
  double get projectedSpending {
    if (daysElapsed == 0) return 0;
    final dailyRate = spent / daysElapsed;
    return dailyRate * totalDays;
  }

  double get suggestedDailySpending {
    if (daysLeft <= 0) return 0;
    return remaining / daysLeft;
  }

  bool get isOnTrack => projectedSpending <= limit;

  bool get isNearLimit => percentageUsed >= 85;

  double get averageDailySpending {
    return daysElapsed > 0 ? spent / daysElapsed : 0;
  }

  double get variance {
    return projectedSpending - limit;
  }

  BudgetHealth get health {
    if (percentageUsed <= 60) return BudgetHealth.excellent;
    if (percentageUsed <= 80) return BudgetHealth.good;
    if (percentageUsed <= 100) return BudgetHealth.warning;
    return BudgetHealth.critical;
  }

  int get daysRemaining => daysLeft;

  // AI-powered recommendations
  List<String> getRecommendations() {
    List<String> recommendations = [];
    
    if (isOverBudget) {
      recommendations.add("You've exceeded your budget by \$${(spent - limit).toStringAsFixed(2)}. Consider reviewing your spending patterns.");
    } else if (isNearLimit) {
      recommendations.add("You're close to your budget limit. Try to reduce spending for the remaining $daysLeft days.");
    }
    
    if (!isOnTrack) {
      recommendations.add("At your current rate, you'll exceed budget by \$${variance.toStringAsFixed(2)}. Consider reducing daily spending to \$${suggestedDailySpending.toStringAsFixed(2)}.");
    }
    
    if (averageDailySpending > dailyBudget * 1.5) {
      recommendations.add("Your daily spending is significantly higher than planned. Review your expenses for optimization opportunities.");
    }
    
    return recommendations;
  }

  // Performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'efficiency': percentageRemaining,
      'consistency': averageDailySpending > 0 ? (dailyBudget / averageDailySpending).clamp(0.0, 2.0) : 1.0,
      'predictability': variance.abs() / limit,
      'healthScore': calculateHealthScore(),
    };
  }

  double calculateHealthScore() {
    double score = 100.0;
    
    if (isOverBudget) {
      score -= 40;
    } else if (isNearLimit) {
      score -= 20;
    }
    
    if (averageDailySpending > dailyBudget) {
      score -= 15;
    }
    if (variance > limit * 0.1) {
      score -= 10;
    }
    
    return score.clamp(0.0, 100.0);
  }

  int _getTotalDaysForPeriod() {
    return endDate.difference(startDate).inDays + 1;
  }

  // Budget management methods
  void updateSpent(double amount) {
    spent += amount;
    updatedAt = DateTime.now();
  }

  void resetSpent() {
    spent = 0.0;
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'limit': limit,
      'spent': spent,
      'period': period.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'walletId': walletId,
      'alertsEnabled': alertsEnabled,
      'alertThreshold': alertThreshold,
      'color': color,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'type': type.toString(),
      'excludedSubcategories': excludedSubcategories,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      limit: map['limit']?.toDouble() ?? 0.0,
      spent: map['spent']?.toDouble() ?? 0.0,
      period: BudgetPeriod.values.firstWhere(
        (e) => e.toString() == map['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      walletId: map['walletId'],
      alertsEnabled: map['alertsEnabled'] ?? true,
      alertThreshold: map['alertThreshold']?.toDouble() ?? 0.8,
      color: map['color'] ?? '#4CAF50',
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      type: BudgetType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => BudgetType.monthly,
      ),
      excludedSubcategories: List<String>.from(map['excludedSubcategories'] ?? []),
    );
  }
}
