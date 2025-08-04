import '../models/expense.dart';
import '../models/budget.dart';

class SmartAnalysisService {
  static final SmartAnalysisService _instance = SmartAnalysisService._internal();
  factory SmartAnalysisService() => _instance;
  SmartAnalysisService._internal();

  // Smart budget recommendations
  Future<List<Budget>> generateSmartBudgets(
    List<Expense> expenses, 
    double monthlyIncome
  ) async {
    final recommendations = <Budget>[];
    
    if (expenses.isEmpty || monthlyIncome <= 0) {
      return _getDefaultBudgets(monthlyIncome);
    }

    // Analyze last 3 months of spending
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    final recentExpenses = expenses
        .where((e) => e.isExpense && e.date.isAfter(threeMonthsAgo))
        .toList();

    // Calculate average monthly spending by category
    final categorySpending = <String, double>{};
    for (final expense in recentExpenses) {
      categorySpending[expense.category] = 
          (categorySpending[expense.category] ?? 0) + expense.amount;
    }

    // Convert to monthly averages
    final monthlyAverages = categorySpending.map((k, v) => MapEntry(k, v / 3));

    // Generate budget recommendations based on 50/30/20 rule
    final needsCategories = ['Groceries', 'Bills & Utilities', 'Transportation', 'Healthcare'];
    final wantsCategories = ['Food & Dining', 'Entertainment', 'Shopping', 'Other'];
    
    final needsBudget = monthlyIncome * 0.5;
    final wantsBudget = monthlyIncome * 0.3;

    for (final entry in monthlyAverages.entries) {
      final category = entry.key;
      final averageSpent = entry.value;
      
      double recommendedAmount;
      if (needsCategories.contains(category)) {
        // For needs, recommend 10-20% above average or proportional to needs budget
        recommendedAmount = (averageSpent * 1.15).clamp(averageSpent, needsBudget * 0.3);
      } else {
        // For wants, be more conservative
        recommendedAmount = (averageSpent * 1.1).clamp(averageSpent * 0.8, wantsBudget * 0.4);
      }

      final budget = Budget(
        id: DateTime.now().millisecondsSinceEpoch.toString() + category.hashCode.toString(),
        category: category,
        amount: recommendedAmount,
        spent: 0,
        startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
        endDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
        isActive: true,
      );

      recommendations.add(budget);
    }

    // Add budgets for missing essential categories
    final essentialCategories = ['Groceries', 'Transportation', 'Bills & Utilities'];
    for (final category in essentialCategories) {
      if (!monthlyAverages.containsKey(category)) {
        final defaultAmount = _getDefaultBudgetAmount(category, monthlyIncome);
        final budget = Budget(
          id: DateTime.now().millisecondsSinceEpoch.toString() + category.hashCode.toString(),
          category: category,
          amount: defaultAmount,
          spent: 0,
          startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
          endDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
          isActive: true,
        );
        recommendations.add(budget);
      }
    }

    return recommendations;
  }

  // Generate spending insights using machine learning-like analysis
  Future<Map<String, dynamic>> generateSpendingInsights(List<Expense> expenses) async {
    if (expenses.isEmpty) {
      return {
        'patterns': [],
        'anomalies': [],
        'recommendations': ['Start tracking expenses to get insights'],
        'trends': {},
      };
    }

    final patterns = <String>[];
    final anomalies = <String>[];
    final recommendations = <String>[];
    final trends = <String, dynamic>{};

    // Analyze spending patterns
    final weeklySpending = _analyzeWeeklyPatterns(expenses);
    final monthlyTrends = _analyzeMonthlyTrends(expenses);
    final categoryPatterns = _analyzeCategoryPatterns(expenses);

    // Detect spending patterns
    patterns.addAll(_detectSpendingPatterns(weeklySpending, categoryPatterns));
    
    // Detect anomalies
    anomalies.addAll(_detectSpendingAnomalies(expenses));
    
    // Generate recommendations
    recommendations.addAll(_generateSpendingRecommendations(patterns, anomalies, categoryPatterns));

    trends['weeklySpending'] = weeklySpending;
    trends['monthlyTrends'] = monthlyTrends;
    trends['categoryPatterns'] = categoryPatterns;

    return {
      'patterns': patterns,
      'anomalies': anomalies,
      'recommendations': recommendations,
      'trends': trends,
    };
  }

  // Predict cashflow for next month
  Future<Map<String, dynamic>> predictCashflow(
    List<Expense> expenses, 
    double monthlyIncome
  ) async {
    final prediction = <String, dynamic>{};
    
    if (expenses.isEmpty) {
      prediction['totalExpenses'] = 0.0;
      prediction['netCashflow'] = monthlyIncome;
      prediction['confidence'] = 0.0;
      return prediction;
    }

    // Analyze last 3 months for prediction
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    final recentExpenses = expenses
        .where((e) => e.isExpense && e.date.isAfter(threeMonthsAgo))
        .toList();

    if (recentExpenses.isEmpty) {
      prediction['totalExpenses'] = 0.0;
      prediction['netCashflow'] = monthlyIncome;
      prediction['confidence'] = 0.0;
      return prediction;
    }

    // Calculate monthly averages with trend analysis
    final monthlyTotals = <double>[];
    for (int i = 0; i < 3; i++) {
      final monthStart = DateTime.now().subtract(Duration(days: 30 * (i + 1)));
      final monthEnd = DateTime.now().subtract(Duration(days: 30 * i));
      
      final monthExpenses = recentExpenses
          .where((e) => e.date.isAfter(monthStart) && e.date.isBefore(monthEnd))
          .fold(0.0, (sum, e) => sum + e.amount);
      
      monthlyTotals.add(monthExpenses);
    }

    // Calculate prediction with trend
    double predictedExpenses;
    double confidence;
    
    if (monthlyTotals.length >= 2) {
      final average = monthlyTotals.fold(0.0, (a, b) => a + b) / monthlyTotals.length;
      final recent = monthlyTotals.first;
      final previous = monthlyTotals.length > 1 ? monthlyTotals[1] : average;
      
      // Apply trend
      final trendFactor = recent / previous;
      predictedExpenses = average * trendFactor;
      
      // Calculate confidence based on consistency
      final variance = monthlyTotals.map((x) => (x - average) * (x - average)).fold(0.0, (a, b) => a + b) / monthlyTotals.length;
      final standardDeviation = variance > 0 ? variance : 1.0;
      confidence = (1.0 / (1.0 + standardDeviation / average)).clamp(0.0, 1.0);
    } else {
      predictedExpenses = monthlyTotals.isNotEmpty ? monthlyTotals.first : 0.0;
      confidence = 0.5; // Medium confidence with limited data
    }

    prediction['totalExpenses'] = predictedExpenses;
    prediction['netCashflow'] = monthlyIncome - predictedExpenses;
    prediction['confidence'] = confidence;
    prediction['categoryBreakdown'] = await _predictCategorySpending(recentExpenses);

    return prediction;
  }

  // Private helper methods
  List<Budget> _getDefaultBudgets(double monthlyIncome) {
    final defaultBudgets = <Budget>[];
    final categories = {
      'Groceries': monthlyIncome * 0.15,
      'Transportation': monthlyIncome * 0.10,
      'Bills & Utilities': monthlyIncome * 0.20,
      'Food & Dining': monthlyIncome * 0.10,
      'Entertainment': monthlyIncome * 0.05,
      'Shopping': monthlyIncome * 0.10,
    };

    for (final entry in categories.entries) {
      final budget = Budget(
        id: DateTime.now().millisecondsSinceEpoch.toString() + entry.key.hashCode.toString(),
        category: entry.key,
        amount: entry.value,
        spent: 0,
        startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
        endDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
        isActive: true,
      );
      defaultBudgets.add(budget);
    }

    return defaultBudgets;
  }

  double _getDefaultBudgetAmount(String category, double monthlyIncome) {
    switch (category) {
      case 'Groceries': return monthlyIncome * 0.15;
      case 'Transportation': return monthlyIncome * 0.10;
      case 'Bills & Utilities': return monthlyIncome * 0.20;
      case 'Food & Dining': return monthlyIncome * 0.10;
      case 'Entertainment': return monthlyIncome * 0.05;
      case 'Healthcare': return monthlyIncome * 0.08;
      case 'Shopping': return monthlyIncome * 0.10;
      default: return monthlyIncome * 0.05;
    }
  }

  Map<int, double> _analyzeWeeklyPatterns(List<Expense> expenses) {
    final weeklyTotals = <int, double>{};
    for (final expense in expenses) {
      if (expense.isExpense) {
        final weekday = expense.date.weekday;
        weeklyTotals[weekday] = (weeklyTotals[weekday] ?? 0) + expense.amount;
      }
    }
    return weeklyTotals;
  }

  Map<String, double> _analyzeMonthlyTrends(List<Expense> expenses) {
    final monthlyTotals = <String, double>{};
    for (final expense in expenses) {
      if (expense.isExpense) {
        final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
        monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
      }
    }
    return monthlyTotals;
  }

  Map<String, double> _analyzeCategoryPatterns(List<Expense> expenses) {
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      if (expense.isExpense) {
        categoryTotals[expense.category] = 
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }
    }
    return categoryTotals;
  }

  List<String> _detectSpendingPatterns(
    Map<int, double> weeklySpending, 
    Map<String, double> categoryPatterns
  ) {
    final patterns = <String>[];
    
    if (weeklySpending.isNotEmpty) {
      final maxDay = weeklySpending.entries.reduce((a, b) => a.value > b.value ? a : b);
      final dayNames = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      patterns.add('You tend to spend most on ${dayNames[maxDay.key]}');
    }

    if (categoryPatterns.isNotEmpty) {
      final topCategory = categoryPatterns.entries.reduce((a, b) => a.value > b.value ? a : b);
      patterns.add('Your primary spending category is ${topCategory.key}');
    }

    return patterns;
  }

  List<String> _detectSpendingAnomalies(List<Expense> expenses) {
    final anomalies = <String>[];
    
    if (expenses.isEmpty) return anomalies;

    // Calculate average expense amount
    final expenseAmounts = expenses.where((e) => e.isExpense).map((e) => e.amount).toList();
    if (expenseAmounts.isEmpty) return anomalies;

    final average = expenseAmounts.fold(0.0, (a, b) => a + b) / expenseAmounts.length;
    final threshold = average * 3; // 3x average is considered anomaly

    final largeExpenses = expenses
        .where((e) => e.isExpense && e.amount > threshold)
        .toList();

    for (final expense in largeExpenses) {
      anomalies.add('Unusually large expense: \$${expense.amount.toStringAsFixed(2)} in ${expense.category}');
    }

    return anomalies;
  }

  List<String> _generateSpendingRecommendations(
    List<String> patterns,
    List<String> anomalies,
    Map<String, double> categoryPatterns
  ) {
    final recommendations = <String>[];
    
    if (categoryPatterns.isNotEmpty) {
      final totalSpending = categoryPatterns.values.fold(0.0, (a, b) => a + b);
      
      for (final entry in categoryPatterns.entries) {
        final percentage = (entry.value / totalSpending) * 100;
        if (percentage > 30) {
          recommendations.add('Consider diversifying spending - ${entry.key} represents ${percentage.toStringAsFixed(1)}% of total expenses');
        }
      }
    }

    if (anomalies.isNotEmpty) {
      recommendations.add('Review large expenses and consider if they align with your financial goals');
    }

    recommendations.addAll([
      'Set up budget alerts to stay within limits',
      'Track expenses regularly to identify trends early',
      'Consider automating savings to build financial security',
    ]);

    return recommendations;
  }

  Future<Map<String, double>> _predictCategorySpending(List<Expense> expenses) async {
    final categoryPredictions = <String, double>{};
    
    // Group by category and calculate averages
    final categoryTotals = <String, List<double>>{};
    
    for (int i = 0; i < 3; i++) {
      final monthStart = DateTime.now().subtract(Duration(days: 30 * (i + 1)));
      final monthEnd = DateTime.now().subtract(Duration(days: 30 * i));
      
      final monthExpenses = expenses
          .where((e) => e.date.isAfter(monthStart) && e.date.isBefore(monthEnd))
          .toList();
      
      final monthlyByCategory = <String, double>{};
      for (final expense in monthExpenses) {
        if (expense.isExpense) {
          monthlyByCategory[expense.category] = 
              (monthlyByCategory[expense.category] ?? 0) + expense.amount;
        }
      }
      
      for (final entry in monthlyByCategory.entries) {
        categoryTotals[entry.key] ??= [];
        categoryTotals[entry.key]!.add(entry.value);
      }
    }

    // Calculate predictions
    for (final entry in categoryTotals.entries) {
      final amounts = entry.value;
      if (amounts.isNotEmpty) {
        final average = amounts.fold(0.0, (a, b) => a + b) / amounts.length;
        categoryPredictions[entry.key] = average;
      }
    }

    return categoryPredictions;
  }
}
