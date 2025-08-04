import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 2)
class FinancialGoal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  double targetAmount;

  @HiveField(4)
  double currentAmount;

  @HiveField(5)
  DateTime targetDate;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  bool isCompleted;

  @HiveField(8)
  String category;

  @HiveField(9)
  int priority; // 1-5, where 5 is highest priority

  FinancialGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    required this.createdAt,
    this.isCompleted = false,
    required this.category,
    this.priority = 3,
  });

  double get progress => (currentAmount / targetAmount) * 100;
  double get remaining => targetAmount - currentAmount;
  int get daysLeft => targetDate.difference(DateTime.now()).inDays;
  
  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;
  bool get isAchievable {
    if (daysLeft <= 0) return false;
    final dailyRequired = remaining / daysLeft;
    return dailyRequired <= 100; // Assuming $100/day is reasonable
  }

  GoalStatus get status {
    if (isCompleted) return GoalStatus.completed;
    if (isOverdue) return GoalStatus.overdue;
    if (progress >= 75) return GoalStatus.onTrack;
    if (progress >= 25) return GoalStatus.behindSchedule;
    return GoalStatus.justStarted;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'category': category,
      'priority': priority,
    };
  }

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetAmount: json['targetAmount'].toDouble(),
      currentAmount: json['currentAmount']?.toDouble() ?? 0.0,
      targetDate: DateTime.parse(json['targetDate']),
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'] ?? false,
      category: json['category'],
      priority: json['priority'] ?? 3,
    );
  }
}

enum GoalStatus {
  justStarted,
  behindSchedule,
  onTrack,
  completed,
  overdue,
}

enum GoalCategory {
  emergency,
  vacation,
  home,
  car,
  education,
  retirement,
  investment,
  other,
}

extension GoalCategoryExtension on GoalCategory {
  String get displayName {
    switch (this) {
      case GoalCategory.emergency:
        return 'Emergency Fund';
      case GoalCategory.vacation:
        return 'Vacation';
      case GoalCategory.home:
        return 'Home Purchase';
      case GoalCategory.car:
        return 'Vehicle';
      case GoalCategory.education:
        return 'Education';
      case GoalCategory.retirement:
        return 'Retirement';
      case GoalCategory.investment:
        return 'Investment';
      case GoalCategory.other:
        return 'Other';
    }
  }
}
