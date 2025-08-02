import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../services/analytics_service.dart';

class FinancialDashboardWidget extends StatefulWidget {
  final List<Expense> expenses;
  final List<Budget> budgets;
  final List<FinancialGoal> goals;

  const FinancialDashboardWidget({
    Key? key,
    required this.expenses,
    required this.budgets,
    required this.goals,
  }) : super(key: key);

  @override
  State<FinancialDashboardWidget> createState() => _FinancialDashboardWidgetState();
}

class _FinancialDashboardWidgetState extends State<FinancialDashboardWidget> {
  int _selectedChartIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final healthReport = FinancialAnalytics.analyzeFinancialHealth(
      widget.expenses,
      widget.budgets,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Health Overview
          _buildHealthOverviewCard(healthReport, theme),
          const SizedBox(height: 16),
          
          // Chart Selection Tabs
          _buildChartTabs(theme),
          const SizedBox(height: 16),
          
          // Main Chart Area
          _buildMainChart(healthReport, theme),
          const SizedBox(height: 16),
          
          // Quick Stats Grid
          _buildQuickStatsGrid(healthReport, theme),
          const SizedBox(height: 16),
          
          // Budget Performance
          _buildBudgetPerformanceSection(theme),
          const SizedBox(height: 16),
          
          // Goals Progress
          _buildGoalsProgressSection(theme),
          const SizedBox(height: 16),
          
          // Insights and Recommendations
          _buildInsightsSection(healthReport, theme),
        ],
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
        gridData: FlGridData(show: true, drawVerticalLine: false),
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
        gridData: FlGridData(show: true, drawVerticalLine: false),
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
        gridData: FlGridData(show: true, drawVerticalLine: false),
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
