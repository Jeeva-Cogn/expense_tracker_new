import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../models/expense.dart';
import '../models/budget.dart';
import '../models/goal.dart';

/// Enhanced Financial Dashboard with animated charts and comprehensive visualizations
/// Features:
/// - 🟦 Monthly Expenses Bar Graph with category color coding
/// - 🟢 Today's Expenses Pie Chart with animated segments  
/// - 📉 Monthly Budget Progress Bar with 30-block visualization
/// - Smooth animations using AnimationController
class EnhancedFinancialDashboard extends StatefulWidget {
  final List<Expense> expenses;
  final List<Budget> budgets;
  final List<FinancialGoal> goals;

  const EnhancedFinancialDashboard({
    super.key,
    required this.expenses,
    required this.budgets,
    required this.goals,
  });

  @override
  State<EnhancedFinancialDashboard> createState() => _EnhancedFinancialDashboardState();
}

class _EnhancedFinancialDashboardState extends State<EnhancedFinancialDashboard>
    with TickerProviderStateMixin {
  
  // Animation Controllers
  late AnimationController _budgetProgressController;
  late AnimationController _barChartController;
  late AnimationController _pieChartController;
  late AnimationController _summaryController;
  
  // Animations
  late Animation<double> _budgetProgressAnimation;
  late Animation<double> _barChartAnimation;
  late Animation<double> _pieChartAnimation;
  late Animation<double> _summaryAnimation;

  List<Expense> _expenses = [];
  BudgetProgress? _budgetProgress;

  // Category colors mapping
  final Map<String, Color> _categoryColors = {
    '🍔 Food & Dining': Colors.orange,
    '🚗 Transportation': Colors.blue,
    '🛍️ Shopping': Colors.purple,
    '🏠 Housing & Utilities': Colors.teal,
    '💊 Healthcare': Colors.red,
    '🎬 Entertainment': Colors.pink,
    '💰 Savings & Investment': Colors.green,
    '📚 Education': Colors.indigo,
    '💼 Business': Colors.brown,
    '💸 Others': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Budget Progress Animation - 1.5 seconds with ease-in-out
    _budgetProgressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _budgetProgressAnimation = CurvedAnimation(
      parent: _budgetProgressController,
      curve: Curves.easeInOut,
    );

    // Bar Chart Animation - 2 seconds with elastic curve
    _barChartController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _barChartAnimation = CurvedAnimation(
      parent: _barChartController,
      curve: Curves.elasticOut,
    );

    // Pie Chart Animation - 1.8 seconds with ease-in-out
    _pieChartController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _pieChartAnimation = CurvedAnimation(
      parent: _pieChartController,
      curve: Curves.easeInOut,
    );

    // Summary Cards Animation - 1.2 seconds with ease-out
    _summaryController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _summaryAnimation = CurvedAnimation(
      parent: _summaryController,
      curve: Curves.easeOut,
    );
  }

  void _loadData() {
    _expenses = widget.expenses.isNotEmpty ? widget.expenses : _generateDemoExpenses();
    _budgetProgress = _getDemoBudgetProgress();
  }

  void _startAnimations() {
    // Staggered animation start
    _summaryController.forward();
    
    Future.delayed(const Duration(milliseconds: 200), () {
      _budgetProgressController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 400), () {
      _barChartController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      _pieChartController.forward();
    });
  }

  @override
  void dispose() {
    _budgetProgressController.dispose();
    _barChartController.dispose();
    _pieChartController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              '📊 Financial Dashboard',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your expenses with beautiful animated charts',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Summary Cards with Animation
            FadeTransition(
              opacity: _summaryAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(_summaryAnimation),
                child: _buildSummaryCards(),
              ),
            ),
            const SizedBox(height: 24),

            // Monthly Budget Progress with Animation
            FadeTransition(
              opacity: _budgetProgressAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-0.3, 0),
                  end: Offset.zero,
                ).animate(_budgetProgressAnimation),
                child: _buildMonthlyBudgetProgress(),
              ),
            ),
            const SizedBox(height: 24),

            // Monthly Expenses Bar Chart with Animation
            FadeTransition(
              opacity: _barChartAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(_barChartAnimation),
                child: _buildMonthlyExpensesBarChart(),
              ),
            ),
            const SizedBox(height: 24),

            // Today's Expenses Pie Chart with Animation
            FadeTransition(
              opacity: _pieChartAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(_pieChartAnimation),
                child: _buildTodayExpensesPieChart(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Monthly Budget Progress with 30-block visualization
  Widget _buildMonthlyBudgetProgress() {
    if (_budgetProgress == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📉 Monthly Budget Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getBudgetStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getBudgetStatusColor()),
                ),
                child: Text(
                  _getBudgetStatusText(),
                  style: TextStyle(
                    color: _getBudgetStatusColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Budget summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget: ₹${_budgetProgress!.budget.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                'Spent: ₹${_budgetProgress!.spent.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  color: _getBudgetStatusColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 30-block progress visualization
          AnimatedBuilder(
            animation: _budgetProgressAnimation,
            builder: (context, child) {
              return _buildBlockProgressBar();
            },
          ),
          
          const SizedBox(height: 12),
          
          // Progress percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(_budgetProgress!.percentage * _budgetProgressAnimation.value).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getBudgetStatusColor(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'of budget used',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 30-block progress bar visualization
  Widget _buildBlockProgressBar() {
    const totalBlocks = 30;
    final filledBlocks = (totalBlocks * (_budgetProgress!.percentage / 100) * _budgetProgressAnimation.value).round();
    
    return Wrap(
      spacing: 3,
      runSpacing: 3,
      children: List.generate(totalBlocks, (index) {
        final isFilled = index < filledBlocks;
        Color blockColor;
        
        if (isFilled) {
          final percentage = _budgetProgress!.percentage;
          if (percentage <= 50) {
            blockColor = Colors.green;
          } else if (percentage <= 75) {
            blockColor = Colors.orange;
          } else if (percentage <= 90) {
            blockColor = Colors.red.shade400;
          } else {
            blockColor = Colors.red.shade700;
          }
        } else {
          blockColor = Colors.grey.shade300;
        }
        
        return AnimatedContainer(
          duration: Duration(milliseconds: 50 * index),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: blockColor,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  /// Monthly Expenses Bar Chart with animation
  Widget _buildMonthlyExpensesBarChart() {
    final monthlyData = _getMonthlyExpenseData();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🟦 Monthly Expenses Bar Graph',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 250,
            child: AnimatedBuilder(
              animation: _barChartAnimation,
              builder: (context, child) {
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: monthlyData.isEmpty ? 1000 : 
                         monthlyData.map((e) => e.amount).reduce(math.max) * 1.2,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final day = group.x + 1;
                          return BarTooltipItem(
                            'Day $day\n₹${rod.toY.toStringAsFixed(0)}',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '₹${(value / 1000).toStringAsFixed(0)}k',
                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final day = value.toInt() + 1;
                            if (day % 5 == 1 || day == 31) {
                              return Text(
                                '$day',
                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 1000,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: monthlyData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: data.amount * _barChartAnimation.value,
                            color: _getCategoryColor(data.category),
                            width: 8,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          // Legend
          _buildCategoryLegend(),
        ],
      ),
    );
  }

  /// Today's Expenses Pie Chart with animation
  Widget _buildTodayExpensesPieChart() {
    final todayData = _getTodayExpenseData();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🟢 Today\'s Expenses Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (todayData.isEmpty)
            SizedBox(
              height: 200,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sentiment_satisfied, size: 48, color: Colors.green),
                    SizedBox(height: 8),
                    Text(
                      'No expenses today! 🎉',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Great job managing your spending!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 250,
              child: AnimatedBuilder(
                animation: _pieChartAnimation,
                builder: (context, child) {
                  return PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: todayData.map((data) {
                        final percentage = (data.amount / todayData.fold(0.0, (sum, item) => sum + item.amount)) * 100;
                        
                        return PieChartSectionData(
                          color: _getCategoryColor(data.category),
                          value: data.amount * _pieChartAnimation.value,
                          title: '${percentage.toStringAsFixed(1)}%',
                          radius: 80 * _pieChartAnimation.value,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          // Handle touch interactions
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Today's expense breakdown
          if (todayData.isNotEmpty)
            Column(
              children: todayData.map((data) {
                final total = todayData.fold(0.0, (sum, item) => sum + item.amount);
                final percentage = (data.amount / total) * 100;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(data.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(data.category),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data.category,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        '₹${data.amount.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(data.category),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Summary cards with key metrics
  Widget _buildSummaryCards() {
    final totalExpenses = _expenses
        .where((e) => e.isExpense && _isThisMonth(e.date))
        .fold(0.0, (sum, e) => sum + e.amount);
    
    final totalIncome = _expenses
        .where((e) => e.isIncome && _isThisMonth(e.date))
        .fold(0.0, (sum, e) => sum + e.amount);
    
    final avgDaily = totalExpenses / DateTime.now().day;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Spent',
            '₹${totalExpenses.toStringAsFixed(0)}',
            Icons.trending_down,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total Income',
            '₹${totalIncome.toStringAsFixed(0)}',
            Icons.trending_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Avg/Day',
            '₹${avgDaily.toStringAsFixed(0)}',
            Icons.timeline,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build category legend for bar chart
  Widget _buildCategoryLegend() {
    final categories = _categoryColors.keys.take(5).toList();
    
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categories.map((category) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getCategoryColor(category),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              category.replaceAll(RegExp(r'[🍔🚗🛍️🏠💊🎬💰📚💼💸]'), '').trim(),
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        );
      }).toList(),
    );
  }

  // Helper methods
  List<DailyExpenseData> _getMonthlyExpenseData() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final monthlyData = <int, DailyExpenseData>{};

    // Initialize all days with zero
    for (int day = 1; day <= daysInMonth; day++) {
      monthlyData[day] = DailyExpenseData(day: day, amount: 0, category: '💸 Others');
    }

    // Fill with actual expense data
    for (final expense in _expenses) {
      if (expense.isExpense && _isThisMonth(expense.date)) {
        final day = expense.date.day;
        monthlyData[day] = DailyExpenseData(
          day: day,
          amount: (monthlyData[day]?.amount ?? 0) + expense.amount,
          category: _getDominantCategory(day),
        );
      }
    }

    return monthlyData.values.toList()..sort((a, b) => a.day.compareTo(b.day));
  }

  List<CategoryExpenseData> _getTodayExpenseData() {
    final today = DateTime.now();
    final categoryTotals = <String, double>{};

    for (final expense in _expenses) {
      if (expense.isExpense && _isToday(expense.date)) {
        categoryTotals[expense.category] = 
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }
    }

    return categoryTotals.entries
        .map((e) => CategoryExpenseData(category: e.key, amount: e.value))
        .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  String _getDominantCategory(int day) {
    final dayExpenses = _expenses.where((e) => 
        e.isExpense && _isThisMonth(e.date) && e.date.day == day).toList();
    
    if (dayExpenses.isEmpty) return '💸 Others';
    
    final categoryTotals = <String, double>{};
    for (final expense in dayExpenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    return categoryTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  Color _getCategoryColor(String category) {
    return _categoryColors[category] ?? Colors.grey;
  }

  Color _getBudgetStatusColor() {
    if (_budgetProgress == null) return Colors.green;
    
    switch (_budgetProgress!.status) {
      case BudgetStatus.onTrack:
        return Colors.green;
      case BudgetStatus.warning:
        return Colors.orange;
      case BudgetStatus.danger:
        return Colors.red;
      case BudgetStatus.exceeded:
        return Colors.red.shade700;
    }
  }

  String _getBudgetStatusText() {
    if (_budgetProgress == null) return 'On Track';
    
    final remaining = (100 - _budgetProgress!.percentage).toStringAsFixed(0);
    return '$remaining% Remaining';
  }

  bool _isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  // Demo data generators
  List<Expense> _generateDemoExpenses() {
    final now = DateTime.now();
    final expenses = <Expense>[];
    final random = math.Random();
    
    // Generate expenses for current month
    for (int day = 1; day <= now.day; day++) {
      final expenseCount = random.nextInt(3) + 1;
      
      for (int i = 0; i < expenseCount; i++) {
        final categories = _categoryColors.keys.toList();
        final category = categories[random.nextInt(categories.length)];
        
        expenses.add(Expense(
          id: 'demo_${day}_$i',
          title: 'Demo Transaction',
          amount: (random.nextInt(2000) + 100).toDouble(),
          category: category,
          date: DateTime(now.year, now.month, day),
          type: ExpenseType.expense,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
    }
    
    // Add some today's expenses for pie chart
    for (int i = 0; i < 4; i++) {
      final categories = ['🍔 Food & Dining', '🚗 Transportation', '🛍️ Shopping', '🎬 Entertainment'];
      final amounts = [450.0, 200.0, 800.0, 300.0];
      
      expenses.add(Expense(
        id: 'today_$i',
        title: 'Today\'s Expense',
        amount: amounts[i],
        category: categories[i],
        date: now,
        type: ExpenseType.expense,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    
    return expenses;
  }

  BudgetProgress _getDemoBudgetProgress() {
    return BudgetProgress(
      budget: 50000,
      spent: 30000,
      remaining: 20000,
      percentage: 60,
      status: BudgetStatus.warning,
    );
  }
}

// Data classes
class DailyExpenseData {
  final int day;
  final double amount;
  final String category;

  DailyExpenseData({
    required this.day,
    required this.amount,
    required this.category,
  });
}

class CategoryExpenseData {
  final String category;
  final double amount;

  CategoryExpenseData({
    required this.category,
    required this.amount,
  });
}

// Budget Progress classes
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

enum BudgetStatus { onTrack, warning, danger, exceeded }
