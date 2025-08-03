import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/ai_analysis_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/calm_animations.dart';
import '../widgets/calm_messaging.dart';

class AIAnalysisScreen extends StatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen>
    with TickerProviderStateMixin {
  late AnimationController _chartController;
  late AnimationController _progressController;
  late Animation<double> _chartAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutBack,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _chartController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  /// Main Analysis Flow - exactly as user requested
  Future<void> _startAnalysis() async {
    final aiService = Provider.of<AIAnalysisService>(context, listen: false);
    
    // Start the analysis
    await aiService.analyzeTransactions();
    
    // Animate charts with updated data
    _chartController.forward();
    
    // Animate budget progress bar (live)
    _progressController.forward();
    
    // Show AI suggestions after analysis
    _showAISuggestions();
    
    // Show unclassified transaction notifications
    _showUnclassifiedNotifications();
  }

  void _showAISuggestions() {
    final aiService = Provider.of<AIAnalysisService>(context, listen: false);
    
    for (final insight in aiService.insights) {
      Future.delayed(Duration(milliseconds: 500 * (aiService.insights.indexOf(insight) + 1)), () {
        if (mounted) {
          CalmNotificationManager().showCustomMessage(
            insight.message,
            insight.type == AIInsightType.achievement 
                ? CalmNotificationType.success
                : insight.type == AIInsightType.suggestion
                    ? CalmNotificationType.encouragement
                    : CalmNotificationType.info,
          );
        }
      });
    }
  }

  void _showUnclassifiedNotifications() {
    final aiService = Provider.of<AIAnalysisService>(context, listen: false);
    
    for (final unclassified in aiService.unclassifiedTransactions) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          _showClassificationDialog(unclassified);
        }
      });
    }
  }

  void _showClassificationDialog(UnclassifiedTransaction unclassified) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unclassified Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What was this ₹${unclassified.transaction.amount.toStringAsFixed(0)} spent on?',
              style: AppTheme.encouragementStyle(),
            ),
            const SizedBox(height: 16),
            Text(
              'Transaction: ${unclassified.transaction.description}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'From: ${unclassified.transaction.merchantName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          ...unclassified.suggestedCategories.map((category) => 
            TextButton(
              onPressed: () {
                Provider.of<AIAnalysisService>(context, listen: false)
                    .classifyTransaction(unclassified.transaction.id, category);
                Navigator.of(context).pop();
                CalmNotificationManager().showCustomMessage(
                  'Great! Transaction classified as ${category.toUpperCase()} 👍',
                  CalmNotificationType.success,
                );
              },
              child: Text(category.toUpperCase()),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('SKIP'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Analysis'),
        backgroundColor: AppColors.cardBackground,
      ),
      body: Consumer<AIAnalysisService>(
        builder: (context, aiService, child) {
          if (aiService.isAnalyzing) {
            return _buildAnalyzingView();
          }
          
          if (aiService.transactions.isEmpty) {
            return _buildInitialView();
          }
          
          return _buildResultsView(aiService);
        },
      ),
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_graph_rounded,
                size: 80,
                color: AppColors.primaryAccent,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'AI Transaction Analysis',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Automatically scan SMS messages, detect transactions, and get personalized insights.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startAnalysis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Analyze Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnalysisLoader(
            message: 'Analyzing your expenses...',
          ),
          SizedBox(height: 32),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  '🔍 Scanning SMS messages...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  '🤖 Auto-detecting transactions...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  '💡 Generating insights...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(AIAnalysisService aiService) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBudgetProgressCard(aiService.budgetProgress),
          const SizedBox(height: 16),
          _buildTransactionsCard(aiService.transactions),
          const SizedBox(height: 16),
          _buildCategoryChart(aiService.transactions),
          const SizedBox(height: 16),
          _buildInsightsCard(aiService.insights),
          if (aiService.unclassifiedTransactions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildUnclassifiedCard(aiService.unclassifiedTransactions),
          ],
        ],
      ),
    );
  }

  Widget _buildBudgetProgressCard(BudgetProgress? budgetProgress) {
    if (budgetProgress == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.primaryAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  'Monthly Budget Progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Animated Progress Bar
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${(budgetProgress.totalSpent * _progressAnimation.value).toStringAsFixed(0)}',
                          style: AppTheme.expenseAmountStyle(
                            amount: -budgetProgress.totalSpent,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '₹${budgetProgress.totalBudget.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (budgetProgress.progressPercentage / 100) * _progressAnimation.value,
                        backgroundColor: AppColors.textSecondary.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          budgetProgress.isOverBudget ? AppColors.danger : AppColors.success,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(budgetProgress.progressPercentage * _progressAnimation.value).toStringAsFixed(1)}% of budget used',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsCard(List<TransactionData> transactions) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  'Auto-Detected Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...transactions.take(5).map((transaction) => 
              _buildTransactionItem(transaction)
            ),
            if (transactions.length > 5)
              TextButton(
                onPressed: () {},
                child: Text('View all ${transactions.length} transactions'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionData transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.getCategoryColor(transaction.category).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(transaction.category),
              color: AppColors.getCategoryColor(transaction.category),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.merchantName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  transaction.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${transaction.amount.toStringAsFixed(0)}',
                style: AppTheme.expenseAmountStyle(
                  amount: -transaction.amount,
                  fontSize: 16,
                ),
              ),
              if (transaction.isAutoDetected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'AUTO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(List<TransactionData> transactions) {
    final categoryTotals = <String, double>{};
    for (final transaction in transactions) {
      if (transaction.category != 'unclassified') {
        categoryTotals[transaction.category] = 
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }

    final colors = <String, Color>{};
    categoryTotals.keys.forEach((category) {
      colors[category] = AppColors.getCategoryColor(category);
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart_rounded,
                  color: AppColors.chartColors[2],
                ),
                const SizedBox(width: 8),
                Text(
                  'Spending by Category',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return AnimatedPieChart(
                    data: categoryTotals,
                    colors: colors,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(List<AIInsight> insights) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Insights & Suggestions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) => _buildInsightItem(insight)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(AIInsight insight) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getInsightColor(insight.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getInsightColor(insight.type).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getInsightIcon(insight.type),
            color: _getInsightColor(insight.type),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  insight.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnclassifiedCard(List<UnclassifiedTransaction> unclassified) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Text(
                  'Unclassified Expenses',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...unclassified.map((ut) => 
              _buildUnclassifiedItem(ut)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnclassifiedItem(UnclassifiedTransaction unclassified) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What was this ₹${unclassified.transaction.amount.toStringAsFixed(0)} spent on?',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            unclassified.transaction.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: unclassified.suggestedCategories.map((category) =>
              ActionChip(
                label: Text(category.toUpperCase()),
                onPressed: () {
                  Provider.of<AIAnalysisService>(context, listen: false)
                      .classifyTransaction(unclassified.transaction.id, category);
                  CalmNotificationManager().showCustomMessage(
                    'Great! Transaction classified as ${category.toUpperCase()} 👍',
                    CalmNotificationType.success,
                  );
                },
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills':
        return Icons.receipt_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getInsightColor(AIInsightType type) {
    switch (type) {
      case AIInsightType.achievement:
        return AppColors.success;
      case AIInsightType.suggestion:
        return AppColors.primaryAccent;
      case AIInsightType.optimization:
        return AppColors.warning;
      case AIInsightType.warning:
        return AppColors.danger;
    }
  }

  IconData _getInsightIcon(AIInsightType type) {
    switch (type) {
      case AIInsightType.achievement:
        return Icons.celebration_rounded;
      case AIInsightType.suggestion:
        return Icons.tips_and_updates_rounded;
      case AIInsightType.optimization:
        return Icons.tune_rounded;
      case AIInsightType.warning:
        return Icons.warning_rounded;
    }
  }
}
