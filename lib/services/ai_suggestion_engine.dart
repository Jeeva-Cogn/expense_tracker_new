import 'dart:math' as math;
import '../models/expense.dart';

/// 🤖 AI Suggestion Engine for Smart Expense Analysis
/// Provides personalized savings advice and motivational insights
/// Activated after "Analyze Transactions" with IST timestamping
class AISuggestionEngine {
  static const String timezone = 'Asia/Kolkata';
  static const String timezoneOffset = 'GMT+5:30';
  
  /// Generate AI-powered savings advice based on expense analysis
  static AIAnalysisResult generateSavingsAdvice(List<Expense> expenses) {
    final analysisTime = _getCurrentISTTime();
    final insights = _analyzeExpensePatterns(expenses);
    final suggestions = _generatePersonalizedSuggestions(insights);
    final achievements = _identifyAchievements(insights);
    
    return AIAnalysisResult(
      timestamp: analysisTime,
      insights: insights,
      suggestions: suggestions,
      achievements: achievements,
      motivationalQuote: _getMotivationalQuote(),
    );
  }
  
  /// Analyze expense patterns and generate insights
  static ExpenseInsights _analyzeExpensePatterns(List<Expense> expenses) {
    final now = DateTime.now();
    final thisMonth = expenses.where((e) => _isThisMonth(e.date)).toList();
    final lastMonth = expenses.where((e) => _isLastMonth(e.date)).toList();
    final thisWeek = expenses.where((e) => _isThisWeek(e.date)).toList();
    final lastWeek = expenses.where((e) => _isLastWeek(e.date)).toList();
    
    // Calculate totals
    final thisMonthTotal = thisMonth.fold(0.0, (sum, e) => sum + e.amount);
    final lastMonthTotal = lastMonth.fold(0.0, (sum, e) => sum + e.amount);
    final thisWeekTotal = thisWeek.fold(0.0, (sum, e) => sum + e.amount);
    final lastWeekTotal = lastWeek.fold(0.0, (sum, e) => sum + e.amount);
    
    // Category analysis
    final categoryTotals = <String, double>{};
    for (final expense in thisMonth) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    // Find top spending categories
    final topCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Calculate trends
    final monthlyTrend = lastMonthTotal > 0 
        ? ((thisMonthTotal - lastMonthTotal) / lastMonthTotal * 100)
        : 0.0;
    final weeklyTrend = lastWeekTotal > 0 
        ? ((thisWeekTotal - lastWeekTotal) / lastWeekTotal * 100)
        : 0.0;
    
    return ExpenseInsights(
      thisMonthTotal: thisMonthTotal,
      lastMonthTotal: lastMonthTotal,
      thisWeekTotal: thisWeekTotal,
      lastWeekTotal: lastWeekTotal,
      topCategories: topCategories,
      monthlyTrend: monthlyTrend,
      weeklyTrend: weeklyTrend,
      averageDailySpending: thisMonthTotal / DateTime.now().day,
      totalTransactions: thisMonth.length,
    );
  }
  
  /// Generate personalized AI suggestions
  static List<AISuggestion> _generatePersonalizedSuggestions(ExpenseInsights insights) {
    final suggestions = <AISuggestion>[];
    
    // Category-based suggestions
    for (final category in insights.topCategories.take(3)) {
      final categoryName = category.key;
      final amount = category.value;
      
      if (amount > 3000) {
        suggestions.add(_generateCategorySuggestion(categoryName, amount));
      }
    }
    
    // Trend-based suggestions
    if (insights.monthlyTrend > 20) {
      suggestions.add(AISuggestion(
        type: SuggestionType.warning,
        title: '📈 Spending Alert',
        message: 'Your spending increased by ${insights.monthlyTrend.toStringAsFixed(1)}% this month. Consider reviewing your budget to stay on track! 💪',
        potentialSavings: insights.thisMonthTotal * 0.1,
        priority: SuggestionPriority.high,
      ));
    } else if (insights.monthlyTrend < -10) {
      suggestions.add(AISuggestion(
        type: SuggestionType.achievement,
        title: '🎉 Great Progress!',
        message: 'Amazing! You reduced spending by ${insights.monthlyTrend.abs().toStringAsFixed(1)}% this month. Keep up the fantastic work! ✨',
        potentialSavings: 0,
        priority: SuggestionPriority.medium,
      ));
    }
    
    // Daily spending suggestions
    if (insights.averageDailySpending > 1500) {
      suggestions.add(AISuggestion(
        type: SuggestionType.tip,
        title: '💡 Daily Spending Tip',
        message: 'Your daily average is ₹${insights.averageDailySpending.toStringAsFixed(0)}. Try setting a daily limit of ₹1,200 to save ₹${((insights.averageDailySpending - 1200) * 30).toStringAsFixed(0)} monthly! 🎯',
        potentialSavings: (insights.averageDailySpending - 1200) * 30,
        priority: SuggestionPriority.medium,
      ));
    }
    
    // Weekly trend suggestions
    if (insights.weeklyTrend > 30) {
      suggestions.add(AISuggestion(
        type: SuggestionType.warning,
        title: '⚠️ Weekly Alert',
        message: 'This week\'s spending is ${insights.weeklyTrend.toStringAsFixed(1)}% higher than last week. Let\'s bring it back on track! 🚀',
        potentialSavings: insights.thisWeekTotal * 0.15,
        priority: SuggestionPriority.high,
      ));
    }
    
    // Add default encouragement if no specific suggestions
    if (suggestions.isEmpty) {
      suggestions.add(AISuggestion(
        type: SuggestionType.encouragement,
        title: '🌟 Keep Going!',
        message: 'You\'re doing great with your expense tracking! Consistency is key to financial success. Every entry brings you closer to your goals! 💫',
        potentialSavings: 0,
        priority: SuggestionPriority.low,
      ));
    }
    
    return suggestions;
  }
  
  /// Generate category-specific suggestions
  static AISuggestion _generateCategorySuggestion(String category, double amount) {
    final suggestions = {
      '🍔 Food & Dining': AISuggestion(
        type: SuggestionType.tip,
        title: '🍽️ Dining Smart',
        message: 'You spent ₹${amount.toStringAsFixed(0)} on dining this month. Try cooking 2-3 more meals at home to save ₹${(amount * 0.15).toStringAsFixed(0)}! Your wallet and health will thank you. 👨‍🍳',
        potentialSavings: amount * 0.15,
        priority: SuggestionPriority.medium,
      ),
      '🚗 Transportation': AISuggestion(
        type: SuggestionType.tip,
        title: '🚌 Smart Commuting',
        message: 'Transportation costs: ₹${amount.toStringAsFixed(0)}. Consider carpooling or public transport 2-3 times a week to save ₹${(amount * 0.2).toStringAsFixed(0)} monthly! 🌱',
        potentialSavings: amount * 0.2,
        priority: SuggestionPriority.medium,
      ),
      '🛍️ Shopping': AISuggestion(
        type: SuggestionType.tip,
        title: '🛒 Mindful Shopping',
        message: 'Shopping total: ₹${amount.toStringAsFixed(0)}. Try the 24-hour rule - wait a day before non-essential purchases. Could save you ₹${(amount * 0.25).toStringAsFixed(0)}! 🧠',
        potentialSavings: amount * 0.25,
        priority: SuggestionPriority.high,
      ),
      '🎬 Entertainment': AISuggestion(
        type: SuggestionType.tip,
        title: '🎭 Fun & Frugal',
        message: 'Entertainment: ₹${amount.toStringAsFixed(0)}. Mix paid activities with free ones like parks, libraries, or home movie nights. Save ₹${(amount * 0.3).toStringAsFixed(0)} while still having fun! 🎪',
        potentialSavings: amount * 0.3,
        priority: SuggestionPriority.low,
      ),
      '🏠 Housing & Utilities': AISuggestion(
        type: SuggestionType.tip,
        title: '💡 Energy Savings',
        message: 'Utilities: ₹${amount.toStringAsFixed(0)}. Small changes like LED bulbs and unplugging devices can reduce bills by ₹${(amount * 0.1).toStringAsFixed(0)} monthly! 🌿',
        potentialSavings: amount * 0.1,
        priority: SuggestionPriority.low,
      ),
    };
    
    return suggestions[category] ?? AISuggestion(
      type: SuggestionType.tip,
      title: '💰 General Savings',
      message: 'You spent ₹${amount.toStringAsFixed(0)} on ${category.replaceAll(RegExp(r'[🍔🚗🛍️🏠💊🎬💰📚💼💸]'), '').trim()}. Consider setting a monthly limit to optimize your spending! 📊',
      potentialSavings: amount * 0.1,
      priority: SuggestionPriority.medium,
    );
  }
  
  /// Identify user achievements
  static List<Achievement> _identifyAchievements(ExpenseInsights insights) {
    final achievements = <Achievement>[];
    
    // Savings achievements
    if (insights.monthlyTrend < -15) {
      achievements.add(Achievement(
        icon: '🏆',
        title: 'Super Saver!',
        description: 'Reduced monthly spending by ${insights.monthlyTrend.abs().toStringAsFixed(1)}%',
        type: AchievementType.savings,
      ));
    }
    
    if (insights.weeklyTrend < -20) {
      achievements.add(Achievement(
        icon: '⭐',
        title: 'Weekly Winner!',
        description: 'Cut weekly expenses by ${insights.weeklyTrend.abs().toStringAsFixed(1)}%',
        type: AchievementType.weekly,
      ));
    }
    
    // Consistency achievements
    if (insights.totalTransactions >= 20) {
      achievements.add(Achievement(
        icon: '📝',
        title: 'Tracking Champion!',
        description: 'Logged ${insights.totalTransactions} transactions this month',
        type: AchievementType.consistency,
      ));
    }
    
    // Budget achievements
    if (insights.averageDailySpending < 1000) {
      achievements.add(Achievement(
        icon: '🎯',
        title: 'Budget Master!',
        description: 'Daily average under ₹1,000 - excellent control!',
        type: AchievementType.budget,
      ));
    }
    
    return achievements;
  }
  
  /// Get motivational quote
  static String _getMotivationalQuote() {
    final quotes = [
      "💪 Small steps daily lead to big changes yearly!",
      "🌟 Every rupee saved is a rupee earned!",
      "🚀 Your future self will thank you for today's smart choices!",
      "💎 Discipline in spending creates wealth in time!",
      "🎯 Budget like a boss, spend like a pro!",
      "🌱 Plant seeds of savings today, harvest prosperity tomorrow!",
      "⚡ Smart spending = Smart living!",
      "🏆 Champions track every expense, winners save every rupee!",
      "🔥 Burn expenses, not your savings!",
      "✨ Financial freedom starts with financial awareness!",
    ];
    
    final random = math.Random();
    return quotes[random.nextInt(quotes.length)];
  }
  
  /// Get current Indian Standard Time
  static String _getCurrentISTTime() {
    final now = DateTime.now();
    // Convert to IST (UTC+5:30)
    final istTime = now.add(const Duration(hours: 5, minutes: 30));
    
    return '${istTime.day.toString().padLeft(2, '0')}-${_getMonthName(istTime.month)}-${istTime.year} ${istTime.hour.toString().padLeft(2, '0')}:${istTime.minute.toString().padLeft(2, '0')} IST';
  }
  
  static String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
  
  // Helper methods for date filtering
  static bool _isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
  
  static bool _isLastMonth(DateTime date) {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    return date.year == lastMonth.year && date.month == lastMonth.month;
  }
  
  static bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  static bool _isLastWeek(DateTime date) {
    final now = DateTime.now();
    final startOfLastWeek = now.subtract(Duration(days: now.weekday - 1 + 7));
    final endOfLastWeek = startOfLastWeek.add(const Duration(days: 6));
    return date.isAfter(startOfLastWeek.subtract(const Duration(days: 1))) && 
           date.isBefore(endOfLastWeek.add(const Duration(days: 1)));
  }
}

/// AI Analysis Result containing all insights and suggestions
class AIAnalysisResult {
  final String timestamp;
  final ExpenseInsights insights;
  final List<AISuggestion> suggestions;
  final List<Achievement> achievements;
  final String motivationalQuote;
  
  AIAnalysisResult({
    required this.timestamp,
    required this.insights,
    required this.suggestions,
    required this.achievements,
    required this.motivationalQuote,
  });
}

/// Detailed expense analysis insights
class ExpenseInsights {
  final double thisMonthTotal;
  final double lastMonthTotal;
  final double thisWeekTotal;
  final double lastWeekTotal;
  final List<MapEntry<String, double>> topCategories;
  final double monthlyTrend;
  final double weeklyTrend;
  final double averageDailySpending;
  final int totalTransactions;
  
  ExpenseInsights({
    required this.thisMonthTotal,
    required this.lastMonthTotal,
    required this.thisWeekTotal,
    required this.lastWeekTotal,
    required this.topCategories,
    required this.monthlyTrend,
    required this.weeklyTrend,
    required this.averageDailySpending,
    required this.totalTransactions,
  });
}

/// AI-generated suggestion with actionable advice
class AISuggestion {
  final SuggestionType type;
  final String title;
  final String message;
  final double potentialSavings;
  final SuggestionPriority priority;
  
  AISuggestion({
    required this.type,
    required this.title,
    required this.message,
    required this.potentialSavings,
    required this.priority,
  });
}

/// User achievement for positive reinforcement
class Achievement {
  final String icon;
  final String title;
  final String description;
  final AchievementType type;
  
  Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.type,
  });
}

/// Types of AI suggestions
enum SuggestionType {
  tip,
  warning,
  achievement,
  encouragement,
}

/// Priority levels for suggestions
enum SuggestionPriority {
  high,
  medium,
  low,
}

/// Types of achievements
enum AchievementType {
  savings,
  weekly,
  consistency,
  budget,
}
