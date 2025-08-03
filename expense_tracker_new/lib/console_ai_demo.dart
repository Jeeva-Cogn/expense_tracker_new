import 'services/ai_suggestion_engine.dart';
import 'models/expense.dart';
import 'dart:math' as math;

/// Console-based AI Analysis Demo
/// Tests the AI Suggestion Engine without GUI requirements
/// Perfect for headless environments and command-line testing
void main() async {
  print('🤖 AI Analysis & Savings Advice - Console Demo');
  print('=================================================');
  print('');
  
  // Generate demo expense data
  print('📊 Generating demo expense data...');
  final expenses = _generateDemoExpenses();
  print('✅ Generated ${expenses.length} demo transactions');
  print('');
  
  // Perform AI analysis
  print('🧠 Running AI analysis...');
  final analysisResult = AISuggestionEngine.generateSavingsAdvice(expenses);
  print('✅ Analysis complete!');
  print('');
  
  // Display results
  _displayResults(analysisResult);
  
  print('');
  print('🎯 Demo completed successfully!');
  print('The AI Analysis feature is ready for integration.');
}

/// Generate comprehensive demo expense data
List<Expense> _generateDemoExpenses() {
  final now = DateTime.now();
  final expenses = <Expense>[];
  final random = math.Random();
  
  final categories = [
    '🍔 Food & Dining',
    '🚗 Transportation', 
    '🛍️ Shopping',
    '🏠 Housing & Utilities',
    '💊 Healthcare',
    '🎬 Entertainment',
    '💰 Savings & Investment',
    '📚 Education',
    '💼 Business',
    '💸 Others',
  ];
  
  final foodExpenses = [
    'Restaurant Dinner', 'Coffee Shop', 'Grocery Shopping', 'Food Delivery',
    'Street Food', 'Breakfast', 'Lunch', 'Fast Food'
  ];
  
  final transportExpenses = [
    'Uber Ride', 'Metro Card', 'Bus Ticket', 'Petrol', 'Auto Rickshaw',
    'Taxi', 'Train Ticket', 'Parking Fee'
  ];
  
  final shoppingExpenses = [
    'Clothes Shopping', 'Electronics', 'Books', 'Gadgets', 'Shoes',
    'Accessories', 'Home Decor', 'Gifts'
  ];

  // Generate expenses for the last 2 months
  for (int month = 0; month < 2; month++) {
    final targetMonth = DateTime(now.year, now.month - month);
    final daysInMonth = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
    
    for (int day = 1; day <= (month == 0 ? now.day : daysInMonth); day++) {
      final transactionCount = random.nextInt(4) + 1;
      
      for (int i = 0; i < transactionCount; i++) {
        final category = categories[random.nextInt(categories.length)];
        String title;
        double amount;
        
        if (category.contains('Food')) {
          title = foodExpenses[random.nextInt(foodExpenses.length)];
          amount = (random.nextInt(800) + 100).toDouble();
        } else if (category.contains('Transportation')) {
          title = transportExpenses[random.nextInt(transportExpenses.length)];
          amount = (random.nextInt(400) + 50).toDouble();
        } else if (category.contains('Shopping')) {
          title = shoppingExpenses[random.nextInt(shoppingExpenses.length)];
          amount = (random.nextInt(3000) + 500).toDouble();
        } else {
          title = 'General Expense';
          amount = (random.nextInt(1500) + 200).toDouble();
        }
        
        expenses.add(Expense(
          id: 'demo_${month}_${day}_$i',
          title: title,
          amount: amount,
          category: category,
          date: DateTime(targetMonth.year, targetMonth.month, day),
          type: ExpenseType.expense,
          createdAt: now,
          updatedAt: now,
        ));
      }
    }
  }
  
  // Add some income entries
  for (int i = 0; i < 2; i++) {
    expenses.add(Expense(
      id: 'income_$i',
      title: 'Salary Credit',
      amount: 50000.0,
      category: '💰 Savings & Investment',
      date: DateTime(now.year, now.month, 1),
      type: ExpenseType.income,
      createdAt: now,
      updatedAt: now,
    ));
  }

  return expenses;
}

/// Display AI analysis results in formatted console output
void _displayResults(AIAnalysisResult result) {
  print('📅 Analysis Timestamp: ${result.timestamp}');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('');
  
  // Motivational Quote
  print('💫 MOTIVATION');
  print('────────────');
  print(result.motivationalQuote);
  print('');
  
  // Achievements
  if (result.achievements.isNotEmpty) {
    print('🏆 YOUR ACHIEVEMENTS');
    print('────────────────────');
    for (final achievement in result.achievements) {
      print('${achievement.icon} ${achievement.title}');
      print('   ${achievement.description}');
      print('');
    }
  }
  
  // AI Suggestions
  print('💡 AI SUGGESTIONS');
  print('─────────────────');
  for (int i = 0; i < result.suggestions.length; i++) {
    final suggestion = result.suggestions[i];
    final priority = suggestion.priority == SuggestionPriority.high ? '🔴 HIGH' :
                    suggestion.priority == SuggestionPriority.medium ? '🟡 MED' : '🟢 LOW';
    
    print('${i + 1}. ${suggestion.title} [$priority]');
    print('   ${suggestion.message}');
    if (suggestion.potentialSavings > 0) {
      print('   💰 Potential Savings: ₹${suggestion.potentialSavings.toStringAsFixed(0)}');
    }
    print('');
  }
  
  // Insights Summary
  print('📊 SPENDING INSIGHTS');
  print('────────────────────');
  final insights = result.insights;
  print('This Month Total: ₹${insights.thisMonthTotal.toStringAsFixed(0)}');
  print('Last Month Total: ₹${insights.lastMonthTotal.toStringAsFixed(0)}');
  print('Monthly Trend: ${insights.monthlyTrend.toStringAsFixed(1)}%');
  print('Daily Average: ₹${insights.averageDailySpending.toStringAsFixed(0)}');
  print('Total Transactions: ${insights.totalTransactions}');
  print('');
  
  // Top Categories
  print('🎯 TOP SPENDING CATEGORIES');
  print('──────────────────────────');
  for (int i = 0; i < math.min(5, insights.topCategories.length); i++) {
    final category = insights.topCategories[i];
    final percentage = (category.value / insights.thisMonthTotal * 100);
    print('${i + 1}. ${category.key}: ₹${category.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)');
  }
  print('');
  
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}
