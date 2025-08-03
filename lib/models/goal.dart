import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 7)
class FinancialGoal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  GoalType type;

  @HiveField(4)
  double targetAmount;

  @HiveField(5)
  double currentAmount;

  @HiveField(6)
  DateTime targetDate;

  @HiveField(7)
  DateTime startDate;

  @HiveField(8)
  GoalPriority priority;

  @HiveField(9)
  String category; // For expense reduction goals

  @HiveField(10)
  bool isActive;

  @HiveField(11)
  List<GoalMilestone> milestones;

  @HiveField(12)
  String color;

  @HiveField(13)
  String? iconEmoji;

  @HiveField(14)
  DateTime createdAt;

  @HiveField(15)
  DateTime updatedAt;

  FinancialGoal({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    required this.startDate,
    this.priority = GoalPriority.medium,
    this.category = '',
    this.isActive = true,
    this.milestones = const [],
    this.color = '#4CAF50',
    this.iconEmoji,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  double get remaining => (targetAmount - currentAmount).clamp(0.0, double.infinity);
  bool get isCompleted => currentAmount >= targetAmount;
  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;
  bool get isOnTrack => _calculateExpectedProgress() <= progress + 0.05; // 5% tolerance
  
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays.clamp(0, double.infinity.toInt());
  int get totalDays => targetDate.difference(startDate).inDays;
  int get daysElapsed => DateTime.now().difference(startDate).inDays.clamp(0, totalDays);
  
  double get dailyTarget => daysRemaining > 0 ? remaining / daysRemaining : 0.0;
  double get weeklyTarget => dailyTarget * 7;
  double get monthlyTarget => dailyTarget * 30;
  
  GoalStatus get status {
    if (isCompleted) return GoalStatus.completed;
    if (isOverdue) return GoalStatus.overdue;
    if (!isOnTrack) return GoalStatus.behindSchedule;
    if (progress > 0.8) return GoalStatus.almostComplete;
    return GoalStatus.inProgress;
  }

  String get statusMessage {
    switch (status) {
      case GoalStatus.completed:
        return '🎉 Goal completed!';
      case GoalStatus.overdue:
        return '⚠️ Goal is overdue';
      case GoalStatus.behindSchedule:
        return '📉 Behind schedule';
      case GoalStatus.almostComplete:
        return '🎯 Almost there!';
      case GoalStatus.inProgress:
        return '📈 On track';
    }
  }

  // Calculate expected progress based on time elapsed
  double _calculateExpectedProgress() {
    if (totalDays <= 0) return 1.0;
    return (daysElapsed / totalDays).clamp(0.0, 1.0);
  }

  // Get next milestone
  GoalMilestone? get nextMilestone {
    final uncompletedMilestones = milestones.where((m) => !m.isCompleted).toList();
    uncompletedMilestones.sort((a, b) => a.targetAmount.compareTo(b.targetAmount));
    return uncompletedMilestones.isNotEmpty ? uncompletedMilestones.first : null;
  }

  // Update progress
  void updateProgress(double amount, {String? note}) {
    currentAmount = amount.clamp(0.0, double.infinity);
    updatedAt = DateTime.now();

    // Check and update milestones
    for (final milestone in milestones) {
      if (!milestone.isCompleted && currentAmount >= milestone.targetAmount) {
        milestone.complete(note: note);
      }
    }
  }

  // Add milestone
  void addMilestone(GoalMilestone milestone) {
    milestones.add(milestone);
    milestones.sort((a, b) => a.targetAmount.compareTo(b.targetAmount));
    updatedAt = DateTime.now();
  }

  // Generate smart recommendations
  List<String> getRecommendations() {
    final recommendations = <String>[];

    if (status == GoalStatus.behindSchedule) {
      final deficit = _calculateExpectedProgress() - progress;
      final catchUpAmount = deficit * targetAmount;
      recommendations.add('You need to save an additional ₹${catchUpAmount.toStringAsFixed(0)} to get back on track.');
      
      if (type == GoalType.savings) {
        recommendations.add('Consider increasing your daily savings to ₹${(dailyTarget * 1.2).toStringAsFixed(0)} to catch up.');
      }
    }

    if (daysRemaining <= 30 && progress < 0.8) {
      recommendations.add('With only $daysRemaining days left, focus on reaching ₹${dailyTarget.toStringAsFixed(0)} daily.');
    }

    if (type == GoalType.expenseReduction && category.isNotEmpty) {
      recommendations.add('Focus on reducing $category expenses to meet your goal.');
    }

    if (progress > 0.5 && nextMilestone != null) {
      final next = nextMilestone!;
      recommendations.add('Next milestone: ₹${next.targetAmount.toStringAsFixed(0)} - only ₹${(next.targetAmount - currentAmount).toStringAsFixed(0)} to go!');
    }

    return recommendations;
  }

  // Calculate goal analytics
  Map<String, dynamic> getAnalytics() {
    return {
      'progressPercentage': progress * 100,
      'remainingAmount': remaining,
      'daysRemaining': daysRemaining,
      'dailyTarget': dailyTarget,
      'weeklyTarget': weeklyTarget,
      'monthlyTarget': monthlyTarget,
      'isOnTrack': isOnTrack,
      'expectedProgress': _calculateExpectedProgress() * 100,
      'status': status.name,
      'completedMilestones': milestones.where((m) => m.isCompleted).length,
      'totalMilestones': milestones.length,
      'averageDailyProgress': daysElapsed > 0 ? currentAmount / daysElapsed : 0.0,
    };
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'targetDate': targetDate.toIso8601String(),
    'startDate': startDate.toIso8601String(),
    'priority': priority.name,
    'category': category,
    'isActive': isActive,
    'milestones': milestones.map((m) => m.toJson()).toList(),
    'color': color,
    'iconEmoji': iconEmoji,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory FinancialGoal.fromJson(Map<String, dynamic> json) => FinancialGoal(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    type: GoalType.values.firstWhere((e) => e.name == json['type']),
    targetAmount: json['targetAmount'].toDouble(),
    currentAmount: json['currentAmount']?.toDouble() ?? 0.0,
    targetDate: DateTime.parse(json['targetDate']),
    startDate: DateTime.parse(json['startDate']),
    priority: GoalPriority.values.firstWhere((e) => e.name == json['priority']),
    category: json['category'] ?? '',
    isActive: json['isActive'] ?? true,
    milestones: (json['milestones'] as List?)?.map((m) => GoalMilestone.fromJson(m)).toList() ?? [],
    color: json['color'] ?? '#4CAF50',
    iconEmoji: json['iconEmoji'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

@HiveType(typeId: 8)
class GoalMilestone extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime? completedAt;

  @HiveField(5)
  String? completionNote;

  @HiveField(6)
  String reward; // Optional reward for reaching milestone

  GoalMilestone({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.isCompleted = false,
    this.completedAt,
    this.completionNote,
    this.reward = '',
  });

  void complete({String? note}) {
    isCompleted = true;
    completedAt = DateTime.now();
    completionNote = note;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
    'completionNote': completionNote,
    'reward': reward,
  };

  factory GoalMilestone.fromJson(Map<String, dynamic> json) => GoalMilestone(
    id: json['id'],
    name: json['name'],
    targetAmount: json['targetAmount'].toDouble(),
    isCompleted: json['isCompleted'] ?? false,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    completionNote: json['completionNote'],
    reward: json['reward'] ?? '',
  );
}

@HiveType(typeId: 9)
enum GoalType {
  @HiveField(0)
  savings,
  @HiveField(1)
  expenseReduction,
  @HiveField(2)
  investment,
  @HiveField(3)
  debtPayoff,
  @HiveField(4)
  incomeIncrease,
  @HiveField(5)
  emergency,
}

@HiveType(typeId: 10)
enum GoalPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
  @HiveField(3)
  critical,
}

enum GoalStatus {
  inProgress,
  almostComplete,
  completed,
  behindSchedule,
  overdue,
}

class GoalManager {
  static List<FinancialGoal> activeGoals = [];
  static List<FinancialGoal> completedGoals = [];

  // Create smart goal suggestions
  static List<FinancialGoal> generateSmartGoals(List<Map<String, dynamic>> expenseHistory, double monthlyIncome) {
    final suggestions = <FinancialGoal>[];
    final now = DateTime.now();

    // Emergency fund goal (3-6 months of expenses)
    if (expenseHistory.isNotEmpty) {
      final avgMonthlyExpenses = expenseHistory.fold(0.0, (sum, e) => sum + e['amount']) / expenseHistory.length;
      final emergencyTarget = avgMonthlyExpenses * 6;
      
      suggestions.add(FinancialGoal(
        id: 'emergency_${now.millisecondsSinceEpoch}',
        name: 'Emergency Fund',
        description: 'Build an emergency fund to cover 6 months of expenses',
        type: GoalType.emergency,
        targetAmount: emergencyTarget,
        targetDate: now.add(const Duration(days: 365)),
        startDate: now,
        priority: GoalPriority.high,
        iconEmoji: '🚨',
        createdAt: now,
        updatedAt: now,
      ));
    }

    // Savings goal (20% of income)
    if (monthlyIncome > 0) {
      final yearlyTarget = monthlyIncome * 12 * 0.2;
      suggestions.add(FinancialGoal(
        id: 'savings_${now.millisecondsSinceEpoch}',
        name: 'Annual Savings',
        description: 'Save 20% of your annual income',
        type: GoalType.savings,
        targetAmount: yearlyTarget,
        targetDate: DateTime(now.year, 12, 31),
        startDate: now,
        priority: GoalPriority.medium,
        iconEmoji: '💰',
        createdAt: now,
        updatedAt: now,
      ));
    }

    // Category-specific expense reduction goals
    final categoryTotals = <String, double>{};
    for (final expense in expenseHistory) {
      final category = expense['category'] as String;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + expense['amount'];
    }

    // Suggest reducing highest spending category by 10%
    if (categoryTotals.isNotEmpty) {
      final highestCategory = categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
      final reductionTarget = highestCategory.value * 0.1;
      
      suggestions.add(FinancialGoal(
        id: 'reduce_${now.millisecondsSinceEpoch}',
        name: 'Reduce ${highestCategory.key} Spending',
        description: 'Cut down ${highestCategory.key} expenses by 10%',
        type: GoalType.expenseReduction,
        targetAmount: reductionTarget,
        targetDate: now.add(const Duration(days: 90)),
        startDate: now,
        category: highestCategory.key,
        priority: GoalPriority.medium,
        iconEmoji: '📉',
        createdAt: now,
        updatedAt: now,
      ));
    }

    return suggestions;
  }

  // Track goal progress based on expenses
  static void updateGoalProgress(List<FinancialGoal> goals, List<Map<String, dynamic>> recentExpenses) {
    for (final goal in goals.where((g) => g.isActive)) {
      switch (goal.type) {
        case GoalType.savings:
          // Calculate savings as income minus expenses
          final income = recentExpenses.where((e) => e['type'] == 'income').fold(0.0, (sum, e) => sum + e['amount']);
          final expenses = recentExpenses.where((e) => e['type'] == 'expense').fold(0.0, (sum, e) => sum + e['amount']);
          final savings = income - expenses;
          if (savings > 0) {
            goal.updateProgress(goal.currentAmount + savings);
          }
          break;

        case GoalType.expenseReduction:
          // Track reduction in specific category
          final categoryExpenses = recentExpenses
              .where((e) => e['category'] == goal.category && e['type'] == 'expense')
              .fold(0.0, (sum, e) => sum + e['amount']);
          // Progress is the amount NOT spent (reduction achieved)
          goal.updateProgress(goal.targetAmount - categoryExpenses);
          break;

        case GoalType.emergency:
        case GoalType.investment:
          // These typically require manual updates
          break;

        case GoalType.debtPayoff:
          // Track debt payments (transfers to debt accounts)
          final debtPayments = recentExpenses
              .where((e) => e['type'] == 'transfer' && e['note']?.toLowerCase().contains('debt') == true)
              .fold(0.0, (sum, e) => sum + e['amount']);
          goal.updateProgress(goal.currentAmount + debtPayments);
          break;

        case GoalType.incomeIncrease:
          // Track income growth
          final currentIncome = recentExpenses.where((e) => e['type'] == 'income').fold(0.0, (sum, e) => sum + e['amount']);
          goal.updateProgress(currentIncome);
          break;
      }
    }
  }

  // Get goal insights and recommendations
  static GoalInsights getGoalInsights(List<FinancialGoal> goals) {
    final activeGoals = goals.where((g) => g.isActive).toList();
    final completedGoals = goals.where((g) => g.isCompleted).toList();
    final overdue = activeGoals.where((g) => g.isOverdue).toList();
    final onTrack = activeGoals.where((g) => g.isOnTrack).toList();

    final totalTargetAmount = activeGoals.fold(0.0, (sum, g) => sum + g.targetAmount);
    final totalProgress = activeGoals.fold(0.0, (sum, g) => sum + g.currentAmount);
    final overallProgress = totalTargetAmount > 0 ? totalProgress / totalTargetAmount : 0.0;

    return GoalInsights(
      totalGoals: goals.length,
      activeGoals: activeGoals.length,
      completedGoals: completedGoals.length,
      overdueGoals: overdue.length,
      goalsOnTrack: onTrack.length,
      overallProgress: overallProgress,
      totalTargetAmount: totalTargetAmount,
      totalAchievedAmount: totalProgress,
      recommendations: _generateGoalRecommendations(activeGoals),
    );
  }

  static List<String> _generateGoalRecommendations(List<FinancialGoal> activeGoals) {
    final recommendations = <String>[];

    if (activeGoals.isEmpty) {
      recommendations.add('Set your first financial goal to start building better money habits.');
      return recommendations;
    }

    final highPriorityGoals = activeGoals.where((g) => g.priority == GoalPriority.high || g.priority == GoalPriority.critical).toList();
    if (highPriorityGoals.isNotEmpty) {
      recommendations.add('Focus on your high-priority goals: ${highPriorityGoals.map((g) => g.name).join(', ')}');
    }

    final behindSchedule = activeGoals.where((g) => g.status == GoalStatus.behindSchedule).toList();
    if (behindSchedule.isNotEmpty) {
      recommendations.add('${behindSchedule.length} goal(s) are behind schedule. Consider adjusting your strategy.');
    }

    final almostComplete = activeGoals.where((g) => g.status == GoalStatus.almostComplete).toList();
    if (almostComplete.isNotEmpty) {
      recommendations.add('You\'re almost there! Push to complete: ${almostComplete.first.name}');
    }

    return recommendations;
  }
}

class GoalInsights {
  final int totalGoals;
  final int activeGoals;
  final int completedGoals;
  final int overdueGoals;
  final int goalsOnTrack;
  final double overallProgress;
  final double totalTargetAmount;
  final double totalAchievedAmount;
  final List<String> recommendations;

  GoalInsights({
    required this.totalGoals,
    required this.activeGoals,
    required this.completedGoals,
    required this.overdueGoals,
    required this.goalsOnTrack,
    required this.overallProgress,
    required this.totalTargetAmount,
    required this.totalAchievedAmount,
    required this.recommendations,
  });

  String get performanceGrade {
    final onTrackRate = activeGoals > 0 ? goalsOnTrack / activeGoals : 0.0;
    if (onTrackRate >= 0.8) return 'A';
    if (onTrackRate >= 0.6) return 'B';
    if (onTrackRate >= 0.4) return 'C';
    return 'D';
  }
}
