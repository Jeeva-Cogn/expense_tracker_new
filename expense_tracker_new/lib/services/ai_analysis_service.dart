import 'package:flutter/material.dart';
import 'dart:async';

class AIAnalysisService extends ChangeNotifier {
  bool _isAnalyzing = false;
  List<TransactionData> _transactions = [];
  List<AIInsight> _insights = [];
  BudgetProgress? _budgetProgress;
  List<UnclassifiedTransaction> _unclassifiedTransactions = [];

  bool get isAnalyzing => _isAnalyzing;
  List<TransactionData> get transactions => _transactions;
  List<AIInsight> get insights => _insights;
  BudgetProgress? get budgetProgress => _budgetProgress;
  List<UnclassifiedTransaction> get unclassifiedTransactions => _unclassifiedTransactions;

  /// Main AI Analysis Flow - exactly as user requested
  Future<void> analyzeTransactions() async {
    _isAnalyzing = true;
    notifyListeners();

    try {
      // Step 1: SMS scanning and auto-detection
      await _scanSMSTransactions();
      
      // Step 2: Process and categorize transactions
      await _processTransactions();
      
      // Step 3: Generate AI insights
      await _generateAIInsights();
      
      // Step 4: Update budget progress
      await _updateBudgetProgress();
      
      // Step 5: Identify unclassified expenses
      await _identifyUnclassifiedTransactions();
      
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<void> _scanSMSTransactions() async {
    // Simulate SMS scanning with realistic delays
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Mock SMS transaction data
    _transactions = [
      TransactionData(
        id: '1',
        amount: 850,
        description: 'SWIGGY ORDER',
        category: 'food',
        date: DateTime.now().subtract(const Duration(days: 1)),
        source: 'SMS',
        merchantName: 'Swiggy',
        isAutoDetected: true,
      ),
      TransactionData(
        id: '2',
        amount: 120,
        description: 'UBER TRIP',
        category: 'transport',
        date: DateTime.now().subtract(const Duration(days: 2)),
        source: 'SMS',
        merchantName: 'Uber',
        isAutoDetected: true,
      ),
      TransactionData(
        id: '3',
        amount: 2500,
        description: 'AMAZON PURCHASE',
        category: 'shopping',
        date: DateTime.now().subtract(const Duration(days: 3)),
        source: 'SMS',
        merchantName: 'Amazon',
        isAutoDetected: true,
      ),
      TransactionData(
        id: '4',
        amount: 500,
        description: 'ATM WITHDRAWAL',
        category: 'unclassified',
        date: DateTime.now().subtract(const Duration(days: 1)),
        source: 'SMS',
        merchantName: 'SBI ATM',
        isAutoDetected: false,
      ),
      TransactionData(
        id: '5',
        amount: 10000,
        description: 'MYNTRA SHOPPING',
        category: 'shopping',
        date: DateTime.now().subtract(const Duration(days: 5)),
        source: 'SMS',
        merchantName: 'Myntra',
        isAutoDetected: true,
      ),
    ];
  }

  Future<void> _processTransactions() async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Processing happens in _scanSMSTransactions for this demo
  }

  Future<void> _generateAIInsights() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Calculate category totals
    final categoryTotals = <String, double>{};
    for (final transaction in _transactions) {
      categoryTotals[transaction.category] = 
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    _insights = [];

    // Generate insights based on spending patterns
    categoryTotals.forEach((category, total) {
      if (category == 'shopping' && total > 5000) {
        _insights.add(AIInsight(
          id: 'shopping_high',
          title: 'High Shopping Expenses',
          message: 'You spent ₹${total.toStringAsFixed(0)} on Shopping. Try reducing by ₹${(total * 0.1).toStringAsFixed(0)} next month.',
          type: AIInsightType.suggestion,
          category: category,
          amount: total,
          suggestedReduction: total * 0.1,
          priority: AIPriority.medium,
        ));
      }
      
      if (category == 'food' && total > 2000) {
        _insights.add(AIInsight(
          id: 'food_optimization',
          title: 'Food Delivery Optimization',
          message: 'Consider meal planning to reduce food delivery costs. You could save ₹${(total * 0.15).toStringAsFixed(0)} monthly.',
          type: AIInsightType.optimization,
          category: category,
          amount: total,
          suggestedReduction: total * 0.15,
          priority: AIPriority.low,
        ));
      }
    });

    // Add positive insights
    if (_transactions.length >= 5) {
      _insights.add(AIInsight(
        id: 'tracking_achievement',
        title: 'Great Tracking!',
        message: 'You\'re doing excellent with expense tracking. ${_transactions.length} transactions auto-detected! 🎉',
        type: AIInsightType.achievement,
        category: 'general',
        amount: 0,
        priority: AIPriority.high,
      ));
    }
  }

  Future<void> _updateBudgetProgress() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final totalSpent = _transactions.fold<double>(0, (sum, t) => sum + t.amount);
    const monthlyBudget = 20000.0; // From settings
    
    _budgetProgress = BudgetProgress(
      totalBudget: monthlyBudget,
      totalSpent: totalSpent,
      remainingBudget: monthlyBudget - totalSpent,
      progressPercentage: (totalSpent / monthlyBudget) * 100,
      isOverBudget: totalSpent > monthlyBudget,
      daysInMonth: DateTime.now().day,
      averageDailySpend: totalSpent / DateTime.now().day,
    );
  }

  Future<void> _identifyUnclassifiedTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    _unclassifiedTransactions = _transactions
        .where((t) => t.category == 'unclassified')
        .map((t) => UnclassifiedTransaction(
              transaction: t,
              suggestedCategories: ['transport', 'food', 'shopping'],
              confidence: 0.7,
            ))
        .toList();
  }

  void classifyTransaction(String transactionId, String category) {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      _transactions[index] = _transactions[index].copyWith(category: category);
      _unclassifiedTransactions.removeWhere((ut) => ut.transaction.id == transactionId);
      notifyListeners();
    }
  }
}

// Data Models

class TransactionData {
  final String id;
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  final String source;
  final String merchantName;
  final bool isAutoDetected;

  const TransactionData({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.source,
    required this.merchantName,
    required this.isAutoDetected,
  });

  TransactionData copyWith({
    String? id,
    double? amount,
    String? description,
    String? category,
    DateTime? date,
    String? source,
    String? merchantName,
    bool? isAutoDetected,
  }) {
    return TransactionData(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      source: source ?? this.source,
      merchantName: merchantName ?? this.merchantName,
      isAutoDetected: isAutoDetected ?? this.isAutoDetected,
    );
  }
}

class AIInsight {
  final String id;
  final String title;
  final String message;
  final AIInsightType type;
  final String category;
  final double amount;
  final double? suggestedReduction;
  final AIPriority priority;

  const AIInsight({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.category,
    required this.amount,
    this.suggestedReduction,
    required this.priority,
  });
}

enum AIInsightType { suggestion, optimization, achievement, warning }
enum AIPriority { high, medium, low }

class BudgetProgress {
  final double totalBudget;
  final double totalSpent;
  final double remainingBudget;
  final double progressPercentage;
  final bool isOverBudget;
  final int daysInMonth;
  final double averageDailySpend;

  const BudgetProgress({
    required this.totalBudget,
    required this.totalSpent,
    required this.remainingBudget,
    required this.progressPercentage,
    required this.isOverBudget,
    required this.daysInMonth,
    required this.averageDailySpend,
  });
}

class UnclassifiedTransaction {
  final TransactionData transaction;
  final List<String> suggestedCategories;
  final double confidence;

  const UnclassifiedTransaction({
    required this.transaction,
    required this.suggestedCategories,
    required this.confidence,
  });
}
