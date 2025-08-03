import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../services/sms_transaction_analyzer.dart';
import '../services/demo_transaction_generator.dart';
import '../services/notification_service.dart';
import '../services/ai_suggestion_engine.dart';
import '../widgets/ai_analysis_widget.dart';
import 'package:timezone/timezone.dart' as tz;

class TransactionAnalysisService {
  static const String _expenseBoxName = 'expenses';
  static const String _settingsBoxName = 'settings';
  
  /// Main function to analyze transactions from SMS
  static Future<TransactionAnalysisResult> analyzeTransactions(
    BuildContext context, {
    bool useDemo = true, // Set to false to use real SMS
  }) async {
    try {
      // Show loading state
      final analysisDialog = _showAnalysisDialog(context);
      
      List<ParsedTransaction> parsedTransactions;
      
      if (useDemo) {
        // Use demo data for testing
        parsedTransactions = await DemoTransactionGenerator.generateDemoTransactions();
      } else {
        // Use real SMS analysis
        parsedTransactions = await SMSTransactionAnalyzer.analyzeTransactions();
      }
      
      // Process uncertain transactions
      final processedTransactions = <ParsedTransaction>[];
      final uncertainTransactions = <ParsedTransaction>[];
      
      for (final transaction in parsedTransactions) {
        if (transaction.needsManualReview) {
          uncertainTransactions.add(transaction);
        } else {
          processedTransactions.add(transaction);
        }
      }
      
      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();
      
      // Handle uncertain transactions
      if (uncertainTransactions.isNotEmpty) {
        final reviewedTransactions = await _reviewUncertainTransactions(
          context, 
          uncertainTransactions,
        );
        processedTransactions.addAll(reviewedTransactions);
      }
      
      // Convert to expenses and save
      final expenses = SMSTransactionAnalyzer.convertToExpenses(processedTransactions);
      await _saveExpenses(expenses);
      
      // Show success notification
      await _showSuccessNotification(context, expenses.length);
      
      // Generate AI suggestions
      final suggestions = await _generateAISuggestions(expenses);
      
      return TransactionAnalysisResult(
        totalTransactions: processedTransactions.length,
        newExpenses: expenses,
        suggestions: suggestions,
        analysisTime: DateTime.now(),
      );
      
    } catch (e) {
      // Close any open dialogs
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      // Show error
      TransactionAnalysisService._showErrorDialog(context, e.toString());
      rethrow;
    }
  }

  /// Show analysis loading dialog
  static Future<void> _showAnalysisDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AnalysisLoadingDialog(),
    );
  }

  /// Review uncertain transactions with user
  static Future<List<ParsedTransaction>> _reviewUncertainTransactions(
    BuildContext context,
    List<ParsedTransaction> uncertainTransactions,
  ) async {
    final reviewedTransactions = <ParsedTransaction>[];
    
    for (final transaction in uncertainTransactions) {
      final selectedCategory = await SMSTransactionAnalyzer.showCategorySelectionDialog(
        context,
        transaction,
      );
      
      if (selectedCategory != null) {
        // Create updated transaction with correct category
        final updatedTransaction = ParsedTransaction(
          id: transaction.id,
          amount: transaction.amount,
          merchant: transaction.merchant,
          date: transaction.date,
          type: transaction.type,
          category: selectedCategory,
          rawSMS: transaction.rawSMS,
          sender: transaction.sender,
          confidence: 1.0, // User confirmed
          needsManualReview: false,
        );
        reviewedTransactions.add(updatedTransaction);
      }
    }
    
    return reviewedTransactions;
  }

  /// Save expenses to local database
  static Future<void> _saveExpenses(List<Expense> expenses) async {
    final box = await Hive.openBox<Expense>(_expenseBoxName);
    
    for (final expense in expenses) {
      // Check for duplicates (same amount, date, and SMS source)
      final existing = box.values.where((e) => 
        e.amount == expense.amount &&
        e.date.day == expense.date.day &&
        e.date.month == expense.date.month &&
        e.smsSource == expense.smsSource
      ).toList();
      
      if (existing.isEmpty) {
        await box.add(expense);
      }
    }
    
    await box.close();
  }

  /// Show success notification
  static Future<void> _showSuccessNotification(BuildContext context, int count) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '🎉 Successfully added $count transactions!',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show error dialog
  static void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 12),
            Text('Analysis Error'),
          ],
        ),
        content: Text(
          'Unable to analyze transactions:\n$error\n\nPlease check SMS permissions and try again.',
          style: TextStyle(color: Colors.grey[600]),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Generate AI-powered suggestions based on analyzed transactions
  static Future<List<AISuggestion>> _generateAISuggestions(List<Expense> expenses) async {
    final suggestions = <AISuggestion>[];
    
    if (expenses.isEmpty) return suggestions;
    
    // Analyze spending by category
    final categorySpending = <String, double>{};
    for (final expense in expenses) {
      if (expense.isExpense) {
        categorySpending[expense.category] = 
            (categorySpending[expense.category] ?? 0) + expense.amount;
      }
    }
    
    // Generate category-specific suggestions
    categorySpending.forEach((category, amount) {
      if (amount > 5000) {
        suggestions.add(AISuggestion(
          title: 'High Spending Alert',
          message: 'You spent ₹${amount.toInt()} on ${category.replaceAll(RegExp(r'[🔥🍔🚗🛍️🏠💊🎬💰📚💼💸]'), '').trim()}. Consider reducing by ₹${(amount * 0.1).toInt()} next month.',
          category: category,
          type: AISuggestionType.warning,
          impact: amount > 10000 ? 'High' : 'Medium',
        ));
      } else if (amount < 1000) {
        suggestions.add(AISuggestion(
          title: 'Great Control!',
          message: 'Excellent spending control on ${category.replaceAll(RegExp(r'[🔥🍔🚗🛍️🏠💊🎬💰📚💼💸]'), '').trim()}. You\'re on track!',
          category: category,
          type: AISuggestionType.positive,
          impact: 'Low',
        ));
      }
    });
    
    // Add general motivational message
    final totalSpent = expenses
        .where((e) => e.isExpense)
        .fold(0.0, (sum, e) => sum + e.amount);
    
    if (totalSpent > 0) {
      suggestions.add(AISuggestion(
        title: 'Financial Tracking Success',
        message: 'You\'ve tracked ₹${totalSpent.toInt()} in expenses. Every tracked rupee brings you closer to financial freedom!',
        category: 'General',
        type: AISuggestionType.motivational,
        impact: 'Positive',
      ));
    }
    
    return suggestions;
  }

  /// Get current month's budget progress
  static Future<BudgetProgress> getBudgetProgress() async {
    try {
      final expenseBox = await Hive.openBox<Expense>(_expenseBoxName);
      final settingsBox = await Hive.openBox(_settingsBoxName);
      
      final monthlyBudget = settingsBox.get('monthlyBudget', defaultValue: 50000.0) as double;
      
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      
      final monthlyExpenses = expenseBox.values
          .where((e) => e.isExpense && 
                      e.date.isAfter(startOfMonth) && 
                      e.date.isBefore(endOfMonth))
          .fold(0.0, (sum, e) => sum + e.amount);
      
      final remaining = monthlyBudget - monthlyExpenses;
      final percentage = (monthlyExpenses / monthlyBudget * 100).clamp(0.0, 100.0);
      
      await expenseBox.close();
      await settingsBox.close();
      
      return BudgetProgress(
        budget: monthlyBudget,
        spent: monthlyExpenses,
        remaining: remaining,
        percentage: percentage.toDouble(),
        status: _getBudgetStatus(percentage.toDouble()),
      );
    } catch (e) {
      // Return demo data if boxes aren't initialized yet
      return _getDemoBudgetProgress();
    }
  }

  /// Get demo budget progress for testing
  static BudgetProgress _getDemoBudgetProgress() {
    const budget = 50000.0;
    const spent = 18750.0; // About 37.5% spent
    const remaining = budget - spent;
    const percentage = (spent / budget) * 100;
    
    return BudgetProgress(
      budget: budget,
      spent: spent,
      remaining: remaining,
      percentage: percentage,
      status: _getBudgetStatus(percentage),
    );
  }

  static BudgetStatus _getBudgetStatus(double percentage) {
    if (percentage < 50) return BudgetStatus.onTrack;
    if (percentage < 75) return BudgetStatus.warning;
    if (percentage < 90) return BudgetStatus.danger;
    return BudgetStatus.exceeded;
  }

  /// 🤖 Launch AI Analysis and Savings Advice
  /// Activated after "Analyze Transactions" with IST timestamping
  static Future<void> showAIAnalysis(BuildContext context) async {
    try {
      // Get all expenses from storage
      final expenseBox = await Hive.openBox<Expense>(_expenseBoxName);
      final expenses = expenseBox.values.toList();
      
      // Navigate to AI Analysis screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AIAnalysisWidget(expenses: expenses),
        ),
      );
      
      // Save analysis timestamp
      final settingsBox = await Hive.openBox(_settingsBoxName);
      final istTime = _getCurrentISTTime();
      await settingsBox.put('last_ai_analysis', istTime);
      
    } catch (e) {
      TransactionAnalysisService._showErrorDialog(context, 'Failed to launch AI analysis: $e');
    }
  }

  /// Get current Indian Standard Time formatted string
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
}

/// Result of transaction analysis
class TransactionAnalysisResult {
  final int totalTransactions;
  final List<Expense> newExpenses;
  final List<AISuggestion> suggestions;
  final DateTime analysisTime;

  TransactionAnalysisResult({
    required this.totalTransactions,
    required this.newExpenses,
    required this.suggestions,
    required this.analysisTime,
  });
}

/// AI-generated suggestion
class AISuggestion {
  final String title;
  final String message;
  final String category;
  final AISuggestionType type;
  final String impact;

  AISuggestion({
    required this.title,
    required this.message,
    required this.category,
    required this.type,
    required this.impact,
  });
}

enum AISuggestionType {
  positive,
  warning,
  motivational,
  tip,
}

/// Budget progress information
class BudgetProgress {
  final double budget;
  final double spent;
  final double remaining;
  final double percentage;
  final BudgetStatus status;

  BudgetProgress({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentage,
    required this.status,
  });
}

enum BudgetStatus {
  onTrack,
  warning,
  danger,
  exceeded,
}

/// Loading dialog during analysis
class AnalysisLoadingDialog extends StatefulWidget {
  const AnalysisLoadingDialog({super.key});

  @override
  _AnalysisLoadingDialogState createState() => _AnalysisLoadingDialogState();
}

class _AnalysisLoadingDialogState extends State<AnalysisLoadingDialog> 
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  final _messages = [
    'Reading SMS messages...',
    'Analyzing transaction patterns...',
    'Extracting amounts and merchants...',
    'Smart categorizing expenses...',
    'Generating AI insights...',
    'Almost done!',
  ];
  
  int _currentMessageIndex = 0;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.repeat();
    
    // Update messages periodically
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent dismissal
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated wallet icon
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animation.value * 2 * 3.14159,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Colors.purple.shade300,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Analyzing Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _messages[_currentMessageIndex],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
