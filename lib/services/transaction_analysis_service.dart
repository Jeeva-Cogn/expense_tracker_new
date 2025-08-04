import '../models/expense.dart';
import '../models/budget.dart';

class TransactionAnalysisService {
  static final TransactionAnalysisService _instance = TransactionAnalysisService._internal();
  factory TransactionAnalysisService() => _instance;
  TransactionAnalysisService._internal();

  // Analyze spending patterns
  Map<String, double> analyzeCategorySpending(List<Expense> expenses) {
    final Map<String, double> categoryTotals = {};
    
    for (final expense in expenses) {
      if (expense.isExpense) {
        categoryTotals[expense.category] = 
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }
    }
    
    return categoryTotals;
  }

  // Calculate monthly spending trends
  Map<String, double> getMonthlySpending(List<Expense> expenses) {
    final Map<String, double> monthlyTotals = {};
    
    for (final expense in expenses) {
      if (expense.isExpense) {
        final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
        monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
      }
    }
    
    return monthlyTotals;
  }

  // Get spending insights
  List<String> getSpendingInsights(List<Expense> expenses) {
    final insights = <String>[];
    final categorySpending = analyzeCategorySpending(expenses);
    
    if (categorySpending.isNotEmpty) {
      final topCategory = categorySpending.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      insights.add('Your highest spending category is ${topCategory.key} with \$${topCategory.value.toStringAsFixed(2)}');
    }
    
    // Calculate average daily spending
    if (expenses.isNotEmpty) {
      final totalExpenses = expenses.where((e) => e.isExpense).fold(0.0, (sum, e) => sum + e.amount);
      final dayCount = expenses.isNotEmpty ? 
          DateTime.now().difference(expenses.first.date).inDays + 1 : 1;
      final avgDaily = totalExpenses / dayCount;
      
      insights.add('Your average daily spending is \$${avgDaily.toStringAsFixed(2)}');
    }
    
    return insights;
  }

  // Calculate budget progress
  BudgetProgress calculateBudgetProgress(Budget budget, List<Expense> expenses) {
    final categoryExpenses = expenses
        .where((e) => e.isExpense && 
                     e.category == budget.category &&
                     e.date.isAfter(budget.startDate) &&
                     e.date.isBefore(budget.endDate))
        .fold(0.0, (sum, e) => sum + e.amount);

    budget.spent = categoryExpenses;
    
    return BudgetProgress.fromBudget(budget);
  }

  // Predict future spending
  double predictMonthlySpending(List<Expense> expenses, String category) {
    final recentExpenses = expenses
        .where((e) => e.isExpense && 
                     e.category == category &&
                     e.date.isAfter(DateTime.now().subtract(const Duration(days: 90))))
        .toList();

    if (recentExpenses.isEmpty) return 0.0;

    final totalAmount = recentExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final monthlyAverage = totalAmount / 3; // 3 months average

    return monthlyAverage;
  }

  // Get spending alerts
  List<String> getSpendingAlerts(List<Budget> budgets, List<Expense> expenses) {
    final alerts = <String>[];
    
    for (final budget in budgets) {
      final progress = calculateBudgetProgress(budget, expenses);
      
      if (progress.status == BudgetStatus.exceeded) {
        alerts.add('Budget exceeded for ${budget.category}! You\'ve spent \$${progress.spentAmount.toStringAsFixed(2)} of \$${progress.budgetAmount.toStringAsFixed(2)}');
      } else if (progress.status == BudgetStatus.warning) {
        alerts.add('Budget warning for ${budget.category}! You\'ve used ${progress.percentage.toStringAsFixed(1)}% of your budget');
      }
    }
    
    return alerts;
  }
}
