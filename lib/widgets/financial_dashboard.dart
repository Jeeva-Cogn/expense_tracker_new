import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../services/transaction_analysis_service.dart';
import 'dart:math' as math;

/// Financial Dashboard with animated charts and progress indicators
class FinancialDashboardWidget extends StatefulWidget {
  const FinancialDashboardWidget({super.key});

  @override
  _FinancialDashboardWidgetState createState() => _FinancialDashboardWidgetState();
}

class _FinancialDashboardWidgetState extends State<FinancialDashboardWidget>
    with TickerProviderStateMixin {
  late AnimationController _barChartController;
  late AnimationController _pieChartController;
  late AnimationController _progressController;
  
  late Animation<double> _barChartAnimation;
  late Animation<double> _pieChartAnimation;
  late Animation<double> _progressAnimation;

  List<Expense> _expenses = [];
  BudgetProgress? _budgetProgress;
  bool _isLoading = true;

  // Category colors for consistent theming
  final Map<String, Color> _categoryColors = {
    '🍔 Food & Dining': Colors.orange,
    '🚗 Transportation': Colors.blue,
    '🛍️ Shopping': Colors.purple,
    '🏠 Home & Utilities': Colors.teal,
    '💊 Healthcare': Colors.red,
    '🎬 Entertainment': Colors.pink,
    '💰 Financial': Colors.green,
    '📚 Education': Colors.indigo,
    '💼 Business': Colors.brown,
    '💸 Others': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _barChartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pieChartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _barChartAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _barChartController, curve: Curves.elasticOut),
    );
    
    _pieChartAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pieChartController, curve: Curves.easeInOut),
    );
    
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _loadData() async {
    try {
      // Load expenses from Hive
      final expenseBox = await Hive.openBox<Expense>('expenses');
      final expenses = expenseBox.values.toList();
      
      // Load budget progress
      final budgetProgress = await TransactionAnalysisService.getBudgetProgress();
      
      setState(() {
        _expenses = expenses;
        _budgetProgress = budgetProgress;
        _isLoading = false;
      });

      // Start animations with slight delays for staggered effect
      _barChartController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _pieChartController.forward();
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        _progressController.forward();
      });

      await expenseBox.close();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _expenses = _generateDemoExpenses();
        _budgetProgress = _getDemoBudgetProgress();
      });
      
      // Start animations even with demo data
      _barChartController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _pieChartController.forward();
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        _progressController.forward();
      });
    }
  }

  @override
  void dispose() {
    _barChartController.dispose();
    _pieChartController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading dashboard...', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly Budget Progress
          _buildMonthlyBudgetProgress(),
          SizedBox(height: 24),
          
          // Monthly Expenses Bar Chart
          _buildMonthlyExpensesBarChart(),
          SizedBox(height: 24),
          
          // Today's Expenses Pie Chart
          _buildTodayExpensesPieChart(),
          SizedBox(height: 24),
          
          // Summary Cards
          _buildSummaryCards(),
        ],
      ),
    );
  }

  /// Enhanced Monthly Budget Progress with animated progress bar
  Widget _buildMonthlyBudgetProgress() {
    if (_budgetProgress == null) return SizedBox.shrink();

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final animatedPercentage = _progressAnimation.value * _budgetProgress!.percentage;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getBudgetStatusColor().withOpacity(0.1),
                _getBudgetStatusColor().withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getBudgetStatusColor().withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status indicator
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
                      color: _getBudgetStatusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getBudgetStatusText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Budget amounts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget: ₹${_budgetProgress!.budget.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Remaining: ₹${_budgetProgress!.remaining.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _budgetProgress!.remaining > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              
              Text(
                'Spent: ₹${_budgetProgress!.spent.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),

              // Animated progress bar with blocks
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${animatedPercentage.toStringAsFixed(1)}% Used',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getBudgetStatusColor(),
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  // Block-style progress bar
                  _buildBlockProgressBar(animatedPercentage),
                  
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹0', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text('₹${_budgetProgress!.budget.toStringAsFixed(0)}', 
                           style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build block-style progress bar with animation
  Widget _buildBlockProgressBar(double percentage) {
    const totalBlocks = 30;
    final filledBlocks = (percentage / 100 * totalBlocks).round();
    
    return SizedBox(
      height: 12,
      child: Row(
        children: List.generate(totalBlocks, (index) {
          final isFilled = index < filledBlocks;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: isFilled ? _getBudgetStatusColor() : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHealthOverviewCard(FinancialHealthReport report, ThemeData theme) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              _getHealthColor(report.healthScore),
              _getHealthColor(report.healthScore).withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Financial Health',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    report.healthGrade,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHealthMetric(
                    '💰 Net Cash Flow',
                    '₹${report.netCashFlow.toStringAsFixed(0)}',
                    Colors.white,
                  ),
                ),
                Expanded(
                  child: _buildHealthMetric(
                    '📊 Savings Rate',
                    '${(report.savingsRate * 100).toInt()}%',
                    Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildHealthMetric(
                    '⚠️ Risk Level',
                    report.riskLevel,
                    Colors.white,
                  ),
                ),
                Expanded(
                  child: _buildHealthMetric(
                    '📈 Health Score',
                    '${report.healthScore.toInt()}/100',
                    Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChartTabs(ThemeData theme) {
    final tabs = [
      'Spending Trends',
      'Category Breakdown',
      'Monthly Comparison',
      'Budget vs Actual',
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedChartIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedChartIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainChart(FinancialHealthReport report, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: _getSelectedChart(report, theme),
        ),
      ),
    );
  }

  Widget _getSelectedChart(FinancialHealthReport report, ThemeData theme) {
    switch (_selectedChartIndex) {
      case 0:
        return _buildSpendingTrendsChart(report.spendingTrends, theme);
      case 1:
        return _buildCategoryPieChart(report.expenseCategories, theme);
      case 2:
        return _buildMonthlyComparisonChart(theme);
      case 3:
        return _buildBudgetVsActualChart(theme);
      default:
        return _buildSpendingTrendsChart(report.spendingTrends, theme);
    }
  }

  Widget _buildSpendingTrendsChart(List<TrendPoint> trends, ThemeData theme) {
    if (trends.isEmpty) {
      return const Center(child: Text('No spending data available'));
    }

    final spots = trends.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₹${(value / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < trends.length) {
                  final date = trends[value.toInt()].date;
                  return Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.3)],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.3),
                  theme.primaryColor.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(Map<String, CategoryAnalysis> categories, ThemeData theme) {
    if (categories.isEmpty) {
      return const Center(child: Text('No category data available'));
    }

    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.totalSpent.compareTo(a.value.totalSpent));

    final sections = sortedCategories.take(6).map((entry) {
      final category = entry.key;
      final analysis = entry.value;
      return PieChartSectionData(
        color: _getCategoryColor(category),
        value: analysis.totalSpent,
        title: '${(analysis.percentageOfTotal * 100).toInt()}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sortedCategories.take(6).map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  entry.key.split(' ').last,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMonthlyComparisonChart(ThemeData theme) {
    // Get last 6 months of data
    final now = DateTime.now();
    final months = List.generate(6, (index) {
      final month = DateTime(now.year, now.month - index, 1);
      return month;
    }).reversed.toList();

    final monthlyData = months.map((month) {
      final monthExpenses = widget.expenses.where((e) => 
        e.date.year == month.year && e.date.month == month.month && e.isExpense
      ).fold(0.0, (sum, e) => sum + e.amount);
      
      return BarChartGroupData(
        x: month.month,
        barRods: [
          BarChartRodData(
            toY: monthExpenses,
            color: theme.primaryColor,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: monthlyData,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₹${(value / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                return Text(
                  monthNames[value.toInt()],
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildBudgetVsActualChart(ThemeData theme) {
    final budgetData = widget.budgets.where((b) => b.isActive).take(5).map((budget) {
      return BarChartGroupData(
        x: widget.budgets.indexOf(budget),
        barRods: [
          BarChartRodData(
            toY: budget.limit,
            color: Colors.grey[300]!,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: budget.spent,
            color: budget.isOverBudget ? Colors.red : theme.primaryColor,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: budgetData,
        groupsSpace: 12,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₹${(value / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < widget.budgets.length) {
                  return Text(
                    widget.budgets[value.toInt()].category.split(' ').last,
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildQuickStatsGrid(FinancialHealthReport report, ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2,
      children: [
        _buildStatCard('💸 Total Expenses', '₹${report.totalExpenses.toStringAsFixed(0)}', theme),
        _buildStatCard('💰 Total Income', '₹${report.totalIncome.toStringAsFixed(0)}', theme),
        _buildStatCard('📊 Active Budgets', '${widget.budgets.where((b) => b.isActive).length}', theme),
        _buildStatCard('🎯 Active Goals', '${widget.goals.where((g) => g.isActive).length}', theme),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetPerformanceSection(ThemeData theme) {
    final activeBudgets = widget.budgets.where((b) => b.isActive).take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Performance',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...activeBudgets.map((budget) => _buildBudgetProgressCard(budget, theme)),
      ],
    );
  }

  Widget _buildBudgetProgressCard(Budget budget, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.name,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${budget.spent.toStringAsFixed(0)} / ₹${budget.limit.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: budget.percentageUsed,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                budget.isOverBudget ? Colors.red : theme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(budget.percentageUsed * 100).toInt()}% used • ${budget.daysRemaining} days left',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsProgressSection(ThemeData theme) {
    final activeGoals = widget.goals.where((g) => g.isActive).take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goals Progress',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...activeGoals.map((goal) => _buildGoalProgressCard(goal, theme)),
      ],
    );
  }

  Widget _buildGoalProgressCard(FinancialGoal goal, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  goal.iconEmoji ?? '🎯',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    goal.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '₹${goal.currentAmount.toStringAsFixed(0)} / ₹${goal.targetAmount.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse('0xFF${goal.color.substring(1)}'))),
            ),
            const SizedBox(height: 4),
            Text(
              '${(goal.progress * 100).toInt()}% complete • ${goal.daysRemaining} days left',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection(FinancialHealthReport report, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights & Recommendations',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...report.recommendations.map((recommendation) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recommendation,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Color _getHealthColor(double healthScore) {
    if (healthScore >= 80) return Colors.green;
    if (healthScore >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getCategoryColor(String category) {
    // Simple hash-based color generation
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[category.hashCode % colors.length];
  }
}
