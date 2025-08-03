import 'dart:math';
import '../models/expense.dart';
import '../models/budget.dart';

class FinancialAnalytics {
  static const int _defaultAnalysisPeriodDays = 90;
  
  // Comprehensive financial health analysis
  static FinancialHealthReport analyzeFinancialHealth(
    List<Expense> expenses,
    List<Budget> budgets,
    {int periodDays = _defaultAnalysisPeriodDays}
  ) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    final relevantExpenses = expenses.where((e) => 
      e.date.isAfter(startDate) && e.date.isBefore(endDate)
    ).toList();

    final totalIncome = _calculateTotalByType(relevantExpenses, ExpenseType.income);
    final totalExpenses = _calculateTotalByType(relevantExpenses, ExpenseType.expense);
    final totalTransfers = _calculateTotalByType(relevantExpenses, ExpenseType.transfer);

    final savingsRate = totalIncome > 0 ? (totalIncome - totalExpenses) / totalIncome : 0.0;
    final cashFlow = totalIncome - totalExpenses;
    
    return FinancialHealthReport(
      periodDays: periodDays,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      totalTransfers: totalTransfers,
      netCashFlow: cashFlow,
      savingsRate: savingsRate,
      expenseCategories: _analyzeCategorySpending(relevantExpenses),
      spendingTrends: _analyzeSpendingTrends(relevantExpenses),
      budgetPerformance: _analyzeBudgetPerformance(budgets),
      recommendations: _generateRecommendations(relevantExpenses, budgets, savingsRate),
      riskScore: _calculateRiskScore(relevantExpenses, budgets),
      healthScore: _calculateOverallHealthScore(savingsRate, budgets, relevantExpenses),
    );
  }

  // Advanced spending pattern analysis
  static SpendingPatternAnalysis analyzeSpendingPatterns(List<Expense> expenses) {
    final patterns = <String, dynamic>{};
    
    // Time-based patterns
    patterns['hourlySpending'] = _analyzeHourlySpending(expenses);
    patterns['dailySpending'] = _analyzeDailySpending(expenses);
    patterns['weeklySpending'] = _analyzeWeeklySpending(expenses);
    patterns['monthlySpending'] = _analyzeMonthlySpending(expenses);
    
    // Behavioral patterns
    patterns['averageTransactionSize'] = _calculateAverageTransactionSize(expenses);
    patterns['spendingFrequency'] = _analyzeSpendingFrequency(expenses);
    patterns['impulsivePurchases'] = _detectImpulsivePurchases(expenses);
    patterns['recurringExpenses'] = _identifyRecurringExpenses(expenses);
    
    // Merchant analysis
    patterns['topMerchants'] = _analyzeTopMerchants(expenses);
    patterns['merchantDiversity'] = _calculateMerchantDiversity(expenses);
    
    return SpendingPatternAnalysis(patterns);
  }

  // Predictive analytics
  static FinancialForecast generateForecast(
    List<Expense> expenses,
    List<Budget> budgets,
    {int forecastDays = 30}
  ) {
    final historicalData = expenses.where((e) => 
      e.date.isAfter(DateTime.now().subtract(const Duration(days: 90)))
    ).toList();

    final categoryForecasts = <String, CategoryForecast>{};
    final categories = historicalData.map((e) => e.category).toSet();

    for (final category in categories) {
      final categoryExpenses = historicalData.where((e) => e.category == category).toList();
      if (categoryExpenses.isNotEmpty) {
        categoryForecasts[category] = _forecastCategorySpending(categoryExpenses, forecastDays);
      }
    }

    final totalPredictedSpending = categoryForecasts.values
        .fold(0.0, (sum, forecast) => sum + forecast.predictedAmount);

    return FinancialForecast(
      forecastPeriodDays: forecastDays,
      totalPredictedSpending: totalPredictedSpending,
      categoryForecasts: categoryForecasts,
      confidence: _calculateForecastConfidence(historicalData),
      riskFactors: _identifyRiskFactors(historicalData, budgets),
    );
  }

  // Anomaly detection
  static List<SpendingAnomaly> detectAnomalies(List<Expense> expenses) {
    final anomalies = <SpendingAnomaly>[];
    
    // Group expenses by category for baseline analysis
    final categoryGroups = <String, List<Expense>>{};
    for (final expense in expenses) {
      categoryGroups[expense.category] ??= [];
      categoryGroups[expense.category]!.add(expense);
    }

    for (final entry in categoryGroups.entries) {
      final category = entry.key;
      final categoryExpenses = entry.value;
      
      if (categoryExpenses.length < 5) continue; // Need minimum data points
      
      final amounts = categoryExpenses.map((e) => e.amount).toList();
      final mean = amounts.reduce((a, b) => a + b) / amounts.length;
      final stdDev = _calculateStandardDeviation(amounts, mean);
      
      // Detect outliers (expenses > 2 standard deviations from mean)
      for (final expense in categoryExpenses) {
        final zScore = (expense.amount - mean) / stdDev;
        if (zScore.abs() > 2.0) {
          anomalies.add(SpendingAnomaly(
            expense: expense,
            type: zScore > 0 ? AnomalyType.unusuallyHigh : AnomalyType.unusuallyLow,
            severity: zScore.abs() > 3.0 ? AnomalySeverity.high : AnomalySeverity.medium,
            description: 'Expense of ₹${expense.amount.toStringAsFixed(0)} is ${zScore.toStringAsFixed(1)} standard deviations from your average $category spending',
            confidence: _calculateAnomalyConfidence(zScore),
          ));
        }
      }
    }

    // Detect suspicious SMS expenses
    for (final expense in expenses.where((e) => e.isFromSMS)) {
      if (expense.isSuspicious) {
        anomalies.add(SpendingAnomaly(
          expense: expense,
          type: AnomalyType.suspiciousTransaction,
          severity: AnomalySeverity.high,
          description: 'Potentially fraudulent transaction detected from SMS',
          confidence: 0.8,
        ));
      }
    }

    return anomalies..sort((a, b) => b.severity.index.compareTo(a.severity.index));
  }

  // Helper methods
  static double _calculateTotalByType(List<Expense> expenses, ExpenseType type) {
    return expenses
        .where((e) => e.type == type)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  static Map<String, CategoryAnalysis> _analyzeCategorySpending(List<Expense> expenses) {
    final categoryTotals = <String, double>{};
    final categoryCounts = <String, int>{};
    
    for (final expense in expenses.where((e) => e.isExpense)) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
      categoryCounts[expense.category] = (categoryCounts[expense.category] ?? 0) + 1;
    }

    final totalSpending = categoryTotals.values.fold(0.0, (a, b) => a + b);
    final result = <String, CategoryAnalysis>{};

    for (final category in categoryTotals.keys) {
      result[category] = CategoryAnalysis(
        totalSpent: categoryTotals[category]!,
        transactionCount: categoryCounts[category]!,
        averageTransaction: categoryTotals[category]! / categoryCounts[category]!,
        percentageOfTotal: totalSpending > 0 ? categoryTotals[category]! / totalSpending : 0.0,
      );
    }

    return result;
  }

  static List<TrendPoint> _analyzeSpendingTrends(List<Expense> expenses) {
    final dailyTotals = <DateTime, double>{};
    
    for (final expense in expenses.where((e) => e.isExpense)) {
      final day = DateTime(expense.date.year, expense.date.month, expense.date.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + expense.amount;
    }

    return dailyTotals.entries
        .map((e) => TrendPoint(date: e.key, value: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static double _calculateStandardDeviation(List<double> values, double mean) {
    if (values.isEmpty) return 0.0;
    
    final squaredDifferences = values.map((v) => pow(v - mean, 2)).toList();
    final variance = squaredDifferences.reduce((a, b) => a + b) / values.length;
    return sqrt(variance);
  }

  static double _calculateRiskScore(List<Expense> expenses, List<Budget> budgets) {
    double riskScore = 0.0;
    
    // Budget overruns increase risk
    final overBudgetCount = budgets.where((b) => b.isOverBudget).length;
    riskScore += (overBudgetCount / budgets.length) * 30;
    
    // High spending variability increases risk
    final amounts = expenses.map((e) => e.amount).toList();
    if (amounts.isNotEmpty) {
      final mean = amounts.reduce((a, b) => a + b) / amounts.length;
      final stdDev = _calculateStandardDeviation(amounts, mean);
      final coefficientOfVariation = mean > 0 ? stdDev / mean : 0;
      riskScore += coefficientOfVariation * 25;
    }
    
    // Suspicious transactions increase risk
    final suspiciousCount = expenses.where((e) => e.isSuspicious).length;
    riskScore += (suspiciousCount / expenses.length) * 20;
    
    return riskScore.clamp(0.0, 100.0);
  }

  static double _calculateOverallHealthScore(double savingsRate, List<Budget> budgets, List<Expense> expenses) {
    double score = 50.0; // Base score
    
    // Savings rate contribution (40 points max)
    score += (savingsRate * 40).clamp(-20, 40);
    
    // Budget adherence contribution (30 points max)
    if (budgets.isNotEmpty) {
      final budgetHealthScores = budgets.map((b) => b.calculateHealthScore()).toList();
      final avgBudgetHealth = budgetHealthScores.isNotEmpty 
          ? budgetHealthScores.reduce((a, b) => a + b) / budgetHealthScores.length
          : 0.0;
      score += (avgBudgetHealth / 100) * 30 - 15; // Normalize to -15 to +15
    }
    
    // Spending consistency (20 points max)
    final amounts = expenses.map((e) => e.amount).toList();
    if (amounts.isNotEmpty && amounts.length > 5) {
      final mean = amounts.reduce((a, b) => a + b) / amounts.length;
      final stdDev = _calculateStandardDeviation(amounts, mean);
      final consistency = mean > 0 ? 1 - (stdDev / mean).clamp(0, 1) : 0;
      score += consistency * 20;
    }
    
    return score.clamp(0.0, 100.0);
  }

  static List<String> _generateRecommendations(List<Expense> expenses, List<Budget> budgets, double savingsRate) {
    final recommendations = <String>[];
    
    if (savingsRate < 0.1) {
      recommendations.add('💡 Try to save at least 10% of your income. Consider reducing discretionary spending.');
    }
    
    if (savingsRate < 0) {
      recommendations.add('⚠️ You\'re spending more than you earn. Review and cut unnecessary expenses immediately.');
    }
    
    final overBudgets = budgets.where((b) => b.isOverBudget).toList();
    if (overBudgets.isNotEmpty) {
      recommendations.add('📊 ${overBudgets.length} budget(s) exceeded. Focus on ${overBudgets.first.category} spending.');
    }
    
    final suspiciousTransactions = expenses.where((e) => e.isSuspicious).length;
    if (suspiciousTransactions > 0) {
      recommendations.add('🔒 Review $suspiciousTransactions potentially suspicious transactions for fraud.');
    }
    
    if (savingsRate > 0.3) {
      recommendations.add('🎉 Excellent savings rate! Consider investing surplus funds for better returns.');
    }
    
    return recommendations;
  }

  // Additional helper methods for comprehensive analysis
  static Map<int, double> _analyzeHourlySpending(List<Expense> expenses) {
    final hourlyTotals = <int, double>{};
    for (final expense in expenses) {
      final hour = expense.date.hour;
      hourlyTotals[hour] = (hourlyTotals[hour] ?? 0) + expense.amount;
    }
    return hourlyTotals;
  }

  static Map<int, double> _analyzeDailySpending(List<Expense> expenses) {
    final dailyTotals = <int, double>{};
    for (final expense in expenses) {
      final weekday = expense.date.weekday;
      dailyTotals[weekday] = (dailyTotals[weekday] ?? 0) + expense.amount;
    }
    return dailyTotals;
  }

  static Map<int, double> _analyzeWeeklySpending(List<Expense> expenses) {
    final weeklyTotals = <int, double>{};
    for (final expense in expenses) {
      final week = _getWeekOfYear(expense.date);
      weeklyTotals[week] = (weeklyTotals[week] ?? 0) + expense.amount;
    }
    return weeklyTotals;
  }

  static Map<int, double> _analyzeMonthlySpending(List<Expense> expenses) {
    final monthlyTotals = <int, double>{};
    for (final expense in expenses) {
      final month = expense.date.month;
      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + expense.amount;
    }
    return monthlyTotals;
  }

  static double _calculateAverageTransactionSize(List<Expense> expenses) {
    if (expenses.isEmpty) return 0.0;
    return expenses.map((e) => e.amount).reduce((a, b) => a + b) / expenses.length;
  }

  static Map<String, int> _analyzeSpendingFrequency(List<Expense> expenses) {
    final frequency = <String, int>{};
    for (final expense in expenses) {
      frequency[expense.category] = (frequency[expense.category] ?? 0) + 1;
    }
    return frequency;
  }

  static List<Expense> _detectImpulsivePurchases(List<Expense> expenses) {
    // Simple heuristic: transactions above average amount in same category within short time
    return expenses.where((e) => e.amount > 2000 && e.isRecent).toList();
  }

  static List<Expense> _identifyRecurringExpenses(List<Expense> expenses) {
    return expenses.where((e) => e.isRecurring).toList();
  }

  static Map<String, double> _analyzeTopMerchants(List<Expense> expenses) {
    final merchantTotals = <String, double>{};
    for (final expense in expenses) {
      final merchant = expense.title;
      merchantTotals[merchant] = (merchantTotals[merchant] ?? 0) + expense.amount;
    }
    return Map.fromEntries(
      merchantTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(10)
    );
  }

  static double _calculateMerchantDiversity(List<Expense> expenses) {
    final uniqueMerchants = expenses.map((e) => e.title).toSet().length;
    return expenses.isNotEmpty ? uniqueMerchants / expenses.length : 0.0;
  }

  static CategoryForecast _forecastCategorySpending(List<Expense> categoryExpenses, int forecastDays) {
    final amounts = categoryExpenses.map((e) => e.amount).toList();
    final avgDaily = amounts.reduce((a, b) => a + b) / categoryExpenses.length;
    
    return CategoryForecast(
      category: categoryExpenses.first.category,
      predictedAmount: avgDaily * forecastDays,
      confidence: _calculateForecastConfidence(categoryExpenses),
      trend: _calculateTrend(amounts),
    );
  }

  static double _calculateForecastConfidence(List<Expense> expenses) {
    if (expenses.length < 10) return 0.3;
    if (expenses.length < 30) return 0.6;
    return 0.8;
  }

  static List<String> _identifyRiskFactors(List<Expense> expenses, List<Budget> budgets) {
    final risks = <String>[];
    
    if (budgets.where((b) => b.isOverBudget).length > budgets.length * 0.3) {
      risks.add('Multiple budget overruns');
    }
    
    if (expenses.where((e) => e.isSuspicious).length > 3) {
      risks.add('Multiple suspicious transactions');
    }
    
    return risks;
  }

  static double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;
    
    // Simple linear trend calculation
    final n = values.length;
    final x = List.generate(n, (i) => i.toDouble());
    final xMean = x.reduce((a, b) => a + b) / n;
    final yMean = values.reduce((a, b) => a + b) / n;
    
    double numerator = 0.0;
    double denominator = 0.0;
    
    for (int i = 0; i < n; i++) {
      numerator += (x[i] - xMean) * (values[i] - yMean);
      denominator += (x[i] - xMean) * (x[i] - xMean);
    }
    
    return denominator != 0 ? numerator / denominator : 0.0;
  }

  static double _calculateAnomalyConfidence(double zScore) {
    return (zScore.abs() / 3.0).clamp(0.0, 1.0);
  }

  static int _getWeekOfYear(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return (dayOfYear / 7).ceil();
  }

  static List<BudgetAnalysis> _analyzeBudgetPerformance(List<Budget> budgets) {
    return budgets.map((budget) => BudgetAnalysis(
      budget: budget,
      performance: budget.percentageUsed,
      efficiency: budget.percentageRemaining,
      predictedOutcome: budget.projectedSpending > budget.limit ? 'Over Budget' : 'Within Budget',
    )).toList();
  }
}

// Data classes for analytics results
class FinancialHealthReport {
  final int periodDays;
  final double totalIncome;
  final double totalExpenses;
  final double totalTransfers;
  final double netCashFlow;
  final double savingsRate;
  final Map<String, CategoryAnalysis> expenseCategories;
  final List<TrendPoint> spendingTrends;
  final List<BudgetAnalysis> budgetPerformance;
  final List<String> recommendations;
  final double riskScore;
  final double healthScore;

  FinancialHealthReport({
    required this.periodDays,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalTransfers,
    required this.netCashFlow,
    required this.savingsRate,
    required this.expenseCategories,
    required this.spendingTrends,
    required this.budgetPerformance,
    required this.recommendations,
    required this.riskScore,
    required this.healthScore,
  });

  String get healthGrade {
    if (healthScore >= 90) return 'A+';
    if (healthScore >= 80) return 'A';
    if (healthScore >= 70) return 'B';
    if (healthScore >= 60) return 'C';
    if (healthScore >= 50) return 'D';
    return 'F';
  }

  String get riskLevel {
    if (riskScore >= 70) return 'High';
    if (riskScore >= 40) return 'Medium';
    return 'Low';
  }
}

class CategoryAnalysis {
  final double totalSpent;
  final int transactionCount;
  final double averageTransaction;
  final double percentageOfTotal;

  CategoryAnalysis({
    required this.totalSpent,
    required this.transactionCount,
    required this.averageTransaction,
    required this.percentageOfTotal,
  });
}

class TrendPoint {
  final DateTime date;
  final double value;

  TrendPoint({required this.date, required this.value});
}

class BudgetAnalysis {
  final Budget budget;
  final double performance;
  final double efficiency;
  final String predictedOutcome;

  BudgetAnalysis({
    required this.budget,
    required this.performance,
    required this.efficiency,
    required this.predictedOutcome,
  });
}

class SpendingPatternAnalysis {
  final Map<String, dynamic> patterns;

  SpendingPatternAnalysis(this.patterns);

  Map<int, double> get hourlySpending => patterns['hourlySpending'] ?? {};
  Map<int, double> get dailySpending => patterns['dailySpending'] ?? {};
  Map<int, double> get weeklySpending => patterns['weeklySpending'] ?? {};
  Map<int, double> get monthlySpending => patterns['monthlySpending'] ?? {};
  double get averageTransactionSize => patterns['averageTransactionSize'] ?? 0.0;
  Map<String, int> get spendingFrequency => patterns['spendingFrequency'] ?? {};
  List<Expense> get impulsivePurchases => patterns['impulsivePurchases'] ?? [];
  List<Expense> get recurringExpenses => patterns['recurringExpenses'] ?? [];
  Map<String, double> get topMerchants => patterns['topMerchants'] ?? {};
  double get merchantDiversity => patterns['merchantDiversity'] ?? 0.0;
}

class FinancialForecast {
  final int forecastPeriodDays;
  final double totalPredictedSpending;
  final Map<String, CategoryForecast> categoryForecasts;
  final double confidence;
  final List<String> riskFactors;

  FinancialForecast({
    required this.forecastPeriodDays,
    required this.totalPredictedSpending,
    required this.categoryForecasts,
    required this.confidence,
    required this.riskFactors,
  });
}

class CategoryForecast {
  final String category;
  final double predictedAmount;
  final double confidence;
  final double trend;

  CategoryForecast({
    required this.category,
    required this.predictedAmount,
    required this.confidence,
    required this.trend,
  });

  String get trendDirection {
    if (trend > 0.1) return 'Increasing';
    if (trend < -0.1) return 'Decreasing';
    return 'Stable';
  }
}

class SpendingAnomaly {
  final Expense expense;
  final AnomalyType type;
  final AnomalySeverity severity;
  final String description;
  final double confidence;

  SpendingAnomaly({
    required this.expense,
    required this.type,
    required this.severity,
    required this.description,
    required this.confidence,
  });
}

enum AnomalyType {
  unusuallyHigh,
  unusuallyLow,
  suspiciousTransaction,
  frequencyAnomaly,
  timingAnomaly,
}

enum AnomalySeverity {
  low,
  medium,
  high,
}

enum BudgetHealth {
  excellent,
  good,
  warning,
  critical,
}

enum BudgetType {
  spending,
  saving,
  income,
}
