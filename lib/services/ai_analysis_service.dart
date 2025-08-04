import '../models/expense.dart';

class AIAnalysisService {
  static final AIAnalysisService _instance = AIAnalysisService._internal();
  factory AIAnalysisService() => _instance;
  AIAnalysisService._internal();

  // Analyze spending patterns using AI
  Future<Map<String, dynamic>> analyzeSpendingPatterns(List<Expense> expenses) async {
    if (expenses.isEmpty) {
      return {
        'insights': ['No expenses to analyze'],
        'recommendations': ['Start tracking your expenses to get insights'],
        'trends': {},
      };
    }

    final insights = <String>[];
    final recommendations = <String>[];
    final trends = <String, dynamic>{};

    // Analyze spending by category
    final categorySpending = <String, double>{};
    for (final expense in expenses) {
      if (expense.isExpense) {
        categorySpending[expense.category] = 
            (categorySpending[expense.category] ?? 0) + expense.amount;
      }
    }

    // Find top spending categories
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedCategories.isNotEmpty) {
      final topCategory = sortedCategories.first;
      insights.add('Your highest spending category is ${topCategory.key} (\$${topCategory.value.toStringAsFixed(2)})');
      
      if (sortedCategories.length > 1) {
        final secondCategory = sortedCategories[1];
        insights.add('Your second highest spending is in ${secondCategory.key} (\$${secondCategory.value.toStringAsFixed(2)})');
      }
    }

    // Analyze spending frequency
    final expensesByDay = <String, int>{};
    for (final expense in expenses) {
      if (expense.isExpense) {
        final dayKey = expense.date.weekday.toString();
        expensesByDay[dayKey] = (expensesByDay[dayKey] ?? 0) + 1;
      }
    }

    final mostActiveDay = expensesByDay.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    final dayNames = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    insights.add('You spend most frequently on ${dayNames[int.parse(mostActiveDay.key)]}');

    // Generate recommendations
    if (categorySpending.isNotEmpty) {
      final totalSpending = categorySpending.values.fold(0.0, (a, b) => a + b);
      final avgCategorySpending = totalSpending / categorySpending.length;
      
      for (final entry in sortedCategories.take(3)) {
        if (entry.value > avgCategorySpending * 1.5) {
          recommendations.add('Consider reducing spending in ${entry.key} - it\'s significantly above average');
        }
      }
    }

    // Add general recommendations
    recommendations.addAll([
      'Set budget limits for your top spending categories',
      'Review your expenses weekly to stay on track',
      'Consider using the savings goals feature to build financial discipline',
    ]);

    // Calculate trends
    trends['categorySpending'] = categorySpending;
    trends['totalExpenses'] = expenses.where((e) => e.isExpense).length;
    trends['averageExpense'] = expenses.isNotEmpty 
        ? expenses.where((e) => e.isExpense).fold(0.0, (sum, e) => sum + e.amount) / expenses.where((e) => e.isExpense).length
        : 0.0;

    return {
      'insights': insights,
      'recommendations': recommendations,
      'trends': trends,
    };
  }

  // Predict future spending
  Future<Map<String, double>> predictNextMonthSpending(List<Expense> expenses) async {
    final predictions = <String, double>{};
    
    if (expenses.isEmpty) return predictions;

    // Get last 3 months of data for better prediction
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    final recentExpenses = expenses
        .where((e) => e.isExpense && e.date.isAfter(threeMonthsAgo))
        .toList();

    if (recentExpenses.isEmpty) return predictions;

    // Group by category and calculate monthly averages
    final categoryTotals = <String, List<double>>{};
    
    for (int i = 0; i < 3; i++) {
      final monthStart = DateTime.now().subtract(Duration(days: 30 * (i + 1)));
      final monthEnd = DateTime.now().subtract(Duration(days: 30 * i));
      
      final monthExpenses = recentExpenses
          .where((e) => e.date.isAfter(monthStart) && e.date.isBefore(monthEnd))
          .toList();
      
      final monthlyByCategory = <String, double>{};
      for (final expense in monthExpenses) {
        monthlyByCategory[expense.category] = 
            (monthlyByCategory[expense.category] ?? 0) + expense.amount;
      }
      
      for (final entry in monthlyByCategory.entries) {
        categoryTotals[entry.key] ??= [];
        categoryTotals[entry.key]!.add(entry.value);
      }
    }

    // Calculate predictions based on averages with trend analysis
    for (final entry in categoryTotals.entries) {
      final amounts = entry.value;
      if (amounts.isNotEmpty) {
        final average = amounts.fold(0.0, (a, b) => a + b) / amounts.length;
        
        // Simple trend analysis - if recent months show increase, adjust prediction
        double trendMultiplier = 1.0;
        if (amounts.length >= 2) {
          final recent = amounts.last;
          final previous = amounts[amounts.length - 2];
          if (recent > previous * 1.1) {
            trendMultiplier = 1.1; // 10% increase if trending up
          } else if (recent < previous * 0.9) {
            trendMultiplier = 0.9; // 10% decrease if trending down
          }
        }
        
        predictions[entry.key] = average * trendMultiplier;
      }
    }

    return predictions;
  }

  // Smart categorization suggestions
  Future<String> suggestCategory(String description, double amount) async {
    final desc = description.toLowerCase();
    
    // Simple rule-based categorization
    if (desc.contains('restaurant') || desc.contains('food') || 
        desc.contains('cafe') || desc.contains('dining')) {
      return 'Food & Dining';
    }
    
    if (desc.contains('gas') || desc.contains('fuel') || 
        desc.contains('transport') || desc.contains('uber') || 
        desc.contains('taxi') || desc.contains('bus')) {
      return 'Transportation';
    }
    
    if (desc.contains('grocery') || desc.contains('supermarket') || 
        desc.contains('market')) {
      return 'Groceries';
    }
    
    if (desc.contains('movie') || desc.contains('cinema') || 
        desc.contains('entertainment') || desc.contains('game')) {
      return 'Entertainment';
    }
    
    if (desc.contains('medical') || desc.contains('doctor') || 
        desc.contains('pharmacy') || desc.contains('hospital')) {
      return 'Healthcare';
    }
    
    if (desc.contains('shopping') || desc.contains('store') || 
        desc.contains('mall') || desc.contains('amazon')) {
      return 'Shopping';
    }
    
    if (desc.contains('bill') || desc.contains('electric') || 
        desc.contains('water') || desc.contains('internet') || 
        desc.contains('phone')) {
      return 'Bills & Utilities';
    }
    
    // Amount-based categorization
    if (amount > 1000) {
      return 'Large Purchase';
    } else if (amount < 10) {
      return 'Miscellaneous';
    }
    
    return 'Other';
  }

  // Financial health score
  Future<Map<String, dynamic>> calculateFinancialHealth(
    List<Expense> expenses, 
    double monthlyIncome
  ) async {
    if (expenses.isEmpty || monthlyIncome <= 0) {
      return {
        'score': 0,
        'grade': 'N/A',
        'factors': ['Insufficient data to calculate financial health'],
      };
    }

    int score = 100;
    final factors = <String>[];
    
    // Calculate monthly expenses
    final lastMonth = DateTime.now().subtract(const Duration(days: 30));
    final monthlyExpenses = expenses
        .where((e) => e.isExpense && e.date.isAfter(lastMonth))
        .fold(0.0, (sum, e) => sum + e.amount);
    
    // Spending ratio (should be < 80% of income)
    final spendingRatio = monthlyExpenses / monthlyIncome;
    if (spendingRatio > 0.9) {
      score -= 30;
      factors.add('High spending ratio (${(spendingRatio * 100).toStringAsFixed(1)}% of income)');
    } else if (spendingRatio > 0.8) {
      score -= 15;
      factors.add('Moderate spending ratio (${(spendingRatio * 100).toStringAsFixed(1)}% of income)');
    } else {
      factors.add('Good spending ratio (${(spendingRatio * 100).toStringAsFixed(1)}% of income)');
    }
    
    // Savings potential
    final savingsRate = 1 - spendingRatio;
    if (savingsRate < 0.1) {
      score -= 20;
      factors.add('Low savings rate (${(savingsRate * 100).toStringAsFixed(1)}%)');
    } else if (savingsRate > 0.2) {
      score += 10;
      factors.add('Excellent savings rate (${(savingsRate * 100).toStringAsFixed(1)}%)');
    }
    
    // Expense consistency
    final categorySpending = <String, double>{};
    for (final expense in expenses.where((e) => e.date.isAfter(lastMonth))) {
      if (expense.isExpense) {
        categorySpending[expense.category] = 
            (categorySpending[expense.category] ?? 0) + expense.amount;
      }
    }
    
    if (categorySpending.isNotEmpty) {
      final maxCategorySpending = categorySpending.values.reduce((a, b) => a > b ? a : b);
      final categoryConcentration = maxCategorySpending / monthlyExpenses;
      
      if (categoryConcentration > 0.5) {
        score -= 10;
        factors.add('High concentration in single category (${(categoryConcentration * 100).toStringAsFixed(1)}%)');
      }
    }
    
    // Determine grade
    String grade;
    if (score >= 90) grade = 'A+';
    else if (score >= 80) grade = 'A';
    else if (score >= 70) grade = 'B';
    else if (score >= 60) grade = 'C';
    else if (score >= 50) grade = 'D';
    else grade = 'F';
    
    return {
      'score': score.clamp(0, 100),
      'grade': grade,
      'factors': factors,
      'monthlyIncome': monthlyIncome,
      'monthlyExpenses': monthlyExpenses,
      'savingsRate': savingsRate,
      'spendingRatio': spendingRatio,
    };
  }

  // Budget optimization suggestions
  Future<List<String>> optimizeBudgets(
    List<Expense> expenses, 
    double monthlyIncome
  ) async {
    final suggestions = <String>[];
    
    if (expenses.isEmpty) {
      suggestions.add('Start tracking expenses to get budget optimization suggestions');
      return suggestions;
    }
    
    // Analyze last 3 months
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    final recentExpenses = expenses
        .where((e) => e.isExpense && e.date.isAfter(threeMonthsAgo))
        .toList();
    
    if (recentExpenses.isEmpty) return suggestions;
    
    // Calculate category averages
    final categoryTotals = <String, double>{};
    for (final expense in recentExpenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    final monthlyTotals = categoryTotals.map((k, v) => MapEntry(k, v / 3));
    final totalMonthlyExpenses = monthlyTotals.values.fold(0.0, (a, b) => a + b);
    
    // 50/30/20 rule suggestions
    final recommendedNeeds = monthlyIncome * 0.5; // 50% for needs
    final recommendedWants = monthlyIncome * 0.3; // 30% for wants
    final recommendedSavings = monthlyIncome * 0.2; // 20% for savings
    
    if (totalMonthlyExpenses > recommendedNeeds + recommendedWants) {
      suggestions.add('Consider reducing total expenses to follow the 50/30/20 rule');
      suggestions.add('Target: \$${recommendedNeeds.toStringAsFixed(2)} for needs, \$${recommendedWants.toStringAsFixed(2)} for wants, \$${recommendedSavings.toStringAsFixed(2)} for savings');
    }
    
    // Category-specific suggestions
    for (final entry in monthlyTotals.entries) {
      final category = entry.key;
      final amount = entry.value;
      final percentage = (amount / monthlyIncome) * 100;
      
      if (category == 'Food & Dining' && percentage > 15) {
        suggestions.add('Food spending (${percentage.toStringAsFixed(1)}%) is high - consider meal planning');
      } else if (category == 'Transportation' && percentage > 15) {
        suggestions.add('Transportation costs (${percentage.toStringAsFixed(1)}%) could be optimized');
      } else if (category == 'Entertainment' && percentage > 10) {
        suggestions.add('Entertainment spending (${percentage.toStringAsFixed(1)}%) might be reduced');
      }
    }
    
    return suggestions;
  }
}
