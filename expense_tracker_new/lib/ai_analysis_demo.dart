import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/settings_service.dart';
import 'services/ai_analysis_service.dart';
import 'models/user_settings.dart';
import 'screens/ai_analysis_screen.dart';
import 'widgets/calm_messaging.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';

/// Demo app specifically for showcasing the AI Analysis and Savings Advice feature
/// This demonstrates the 🤖 AI Suggestion Engine with IST timestamping
void main() {
  runApp(AIAnalysisDemoApp());
}

class AIAnalysisDemoApp extends StatelessWidget {
  const AIAnalysisDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🤖 AI Analysis Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: AIAnalysisDemoScreen(),
    );
  }
}

class AIAnalysisDemoScreen extends StatelessWidget {
  const AIAnalysisDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Analysis Demo'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '🤖',
                      style: TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'AI Analysis & Savings Advice',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Get personalized insights and motivational savings advice based on your spending patterns',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Feature highlights
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildFeature('📊', 'Smart Expense Analysis'),
                          const SizedBox(height: 8),
                          _buildFeature('💡', 'Personalized Savings Tips'),
                          const SizedBox(height: 8),
                          _buildFeature('🏆', 'Achievement Recognition'),
                          const SizedBox(height: 8),
                          _buildFeature('⏱️', 'IST Timestamping'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Launch buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _launchAIAnalysis(context, false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Column(
                              children: [
                                Text('🤖', style: TextStyle(fontSize: 20)),
                                SizedBox(height: 4),
                                Text('Quick Demo'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _launchAIAnalysis(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Column(
                              children: [
                                Text('📈', style: TextStyle(fontSize: 20)),
                                SizedBox(height: 4),
                                Text('Rich Data'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Info card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.amber.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All times are shown in Indian Timezone (Asia/Kolkata, GMT+5:30)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  void _launchAIAnalysis(BuildContext context, bool useRichData) {
    final expenses = useRichData ? _generateRichDemoExpenses() : _generateBasicDemoExpenses();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIAnalysisWidget(expenses: expenses),
      ),
    );
  }

  /// Generate basic demo expenses for quick demo
  List<Expense> _generateBasicDemoExpenses() {
    final now = DateTime.now();
    final expenses = <Expense>[];
    
    // Add some basic expenses for this month
    expenses.addAll([
      Expense(
        id: 'demo_1',
        title: 'Lunch at Restaurant',
        amount: 450.0,
        category: '🍔 Food & Dining',
        date: now.subtract(const Duration(days: 1)),
        type: ExpenseType.expense,
        createdAt: now,
        updatedAt: now,
      ),
      Expense(
        id: 'demo_2',
        title: 'Uber Ride',
        amount: 180.0,
        category: '🚗 Transportation',
        date: now.subtract(const Duration(days: 2)),
        type: ExpenseType.expense,
        createdAt: now,
        updatedAt: now,
      ),
      Expense(
        id: 'demo_3',
        title: 'Shopping - Clothes',
        amount: 2500.0,
        category: '🛍️ Shopping',
        date: now.subtract(const Duration(days: 3)),
        type: ExpenseType.expense,
        createdAt: now,
        updatedAt: now,
      ),
    ]);

    return expenses;
  }

  /// Generate rich demo expenses with comprehensive data
  List<Expense> _generateRichDemoExpenses() {
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
            id: 'rich_demo_${month}_${day}_$i',
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
    for (int i = 0; i < 3; i++) {
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
}
