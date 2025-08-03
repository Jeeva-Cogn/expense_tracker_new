import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsAnalyticsTab extends StatefulWidget {
  const ReportsAnalyticsTab({super.key});

  @override
  State<ReportsAnalyticsTab> createState() => _ReportsAnalyticsTabState();
}

class _ReportsAnalyticsTabState extends State<ReportsAnalyticsTab> {
  int selectedTab = 0;
  final List<String> tabs = ['Daily', 'Monthly', 'Yearly', 'Lifetime'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'REPORTS & ANALYTICS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 30),
            _buildTabSelector(),
            const SizedBox(height: 30),
            Expanded(
              child: _buildSelectedTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          int index = entry.key;
          String tab = entry.value;
          bool isSelected = selectedTab == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF8B8B8B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (selectedTab) {
      case 0:
        return _buildDailyReport();
      case 1:
        return _buildMonthlyReport();
      case 2:
        return _buildYearlyReport();
      case 3:
        return _buildLifetimeReport();
      default:
        return _buildDailyReport();
    }
  }

  Widget _buildDailyReport() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAverageCard('Daily Average', '₹892', '+12.5% from last week'),
          const SizedBox(height: 20),
          _buildDailyChart(),
          const SizedBox(height: 20),
          _buildTopCategoriesCard('Today\'s Top Categories'),
          const SizedBox(height: 20),
          _buildWeeklyComparison(),
        ],
      ),
    );
  }

  Widget _buildMonthlyReport() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAverageCard('Monthly Average', '₹26,750', '+8.2% from last month'),
          const SizedBox(height: 20),
          _buildMonthlyChart(),
          const SizedBox(height: 20),
          _buildTopCategoriesCard('This Month\'s Top Categories'),
          const SizedBox(height: 20),
          _buildYearlyTrend(),
        ],
      ),
    );
  }

  Widget _buildYearlyReport() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAverageCard('Yearly Average', '₹3,21,000', '+15.3% from last year'),
          const SizedBox(height: 20),
          _buildYearlyChart(),
          const SizedBox(height: 20),
          _buildTopCategoriesCard('This Year\'s Top Categories'),
          const SizedBox(height: 20),
          _buildYearlyComparison(),
        ],
      ),
    );
  }

  Widget _buildLifetimeReport() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildLifetimeStats(),
          const SizedBox(height: 20),
          _buildLifetimeChart(),
          const SizedBox(height: 20),
          _buildAllTimeFavorites(),
          const SizedBox(height: 20),
          _buildSpendingMilestones(),
        ],
      ),
    );
  }

  Widget _buildAverageCard(String title, String amount, String change) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  change,
                  style: TextStyle(
                    color: change.contains('+') ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up,
              color: Color(0xFF3B82F6),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Spending (Last 7 Days)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        return Text(
                          days[value.toInt()],
                          style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 800, color: const Color(0xFF3B82F6))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 1200, color: const Color(0xFF3B82F6))]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 600, color: const Color(0xFF3B82F6))]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 1500, color: const Color(0xFF3B82F6))]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 900, color: const Color(0xFF3B82F6))]),
                  BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 1100, color: const Color(0xFF3B82F6))]),
                  BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 1075, color: const Color(0xFF10B981))]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Spending Trend',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 22000),
                      const FlSpot(1, 25000),
                      const FlSpot(2, 18000),
                      const FlSpot(3, 28000),
                      const FlSpot(4, 24000),
                      const FlSpot(5, 26750),
                    ],
                    isCurved: true,
                    color: const Color(0xFF10B981),
                    barWidth: 4,
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF10B981).withOpacity(0.2),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF10B981),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yearly Comparison',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final years = ['2022', '2023', '2024', '2025'];
                        return Text(
                          years[value.toInt()],
                          style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 280000, color: const Color(0xFF8B5CF6))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 295000, color: const Color(0xFF8B5CF6))]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 312000, color: const Color(0xFF8B5CF6))]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 321000, color: const Color(0xFF10B981))]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategoriesCard(String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _buildCategoryRank(1, 'Food & Dining', '₹450', Colors.green),
          const SizedBox(height: 12),
          _buildCategoryRank(2, 'Transportation', '₹320', Colors.blue),
          const SizedBox(height: 12),
          _buildCategoryRank(3, 'Shopping', '₹180', Colors.purple),
          const SizedBox(height: 12),
          _buildCategoryRank(4, 'Entertainment', '₹125', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildCategoryRank(int rank, String category, String amount, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            color: Color(0xFF8B8B8B),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyComparison() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Comparison',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildComparisonItem('This Week', '₹6,244', '+5.2%', Colors.green)),
              const SizedBox(width: 15),
              Expanded(child: _buildComparisonItem('Last Week', '₹5,932', '-2.1%', Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyTrend() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Year-over-Year Growth',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildComparisonItem('2024', '₹312,000', '+8.2%', Colors.green)),
              const SizedBox(width: 15),
              Expanded(child: _buildComparisonItem('2025 (Proj.)', '₹337,000', '+8.0%', Colors.blue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyComparison() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance vs Goals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildComparisonItem('Target', '₹300,000', 'Goal', Colors.orange)),
              const SizedBox(width: 15),
              Expanded(child: _buildComparisonItem('Actual', '₹321,000', '+7.0%', Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLifetimeStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Column(
        children: [
          const Text(
            'Lifetime Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: _buildLifetimeStatItem('Total Spent', '₹12,45,000', Icons.account_balance_wallet)),
              const SizedBox(width: 15),
              Expanded(child: _buildLifetimeStatItem('Transactions', '8,542', Icons.receipt_long)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildLifetimeStatItem('Avg/Month', '₹26,750', Icons.calendar_month)),
              const SizedBox(width: 15),
              Expanded(child: _buildLifetimeStatItem('Avg/Day', '₹892', Icons.today)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLifetimeChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending Evolution',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 15000),
                      const FlSpot(1, 18000),
                      const FlSpot(2, 22000),
                      const FlSpot(3, 25000),
                      const FlSpot(4, 26750),
                    ],
                    isCurved: true,
                    color: const Color(0xFF8B5CF6),
                    barWidth: 4,
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    ),
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllTimeFavorites() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All-Time Favorites',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _buildFavoriteItem('Most Expensive Purchase', 'iPhone 15 Pro', '₹1,29,900'),
          const SizedBox(height: 12),
          _buildFavoriteItem('Favorite Category', 'Food & Dining', '42% of expenses'),
          const SizedBox(height: 12),
          _buildFavoriteItem('Busiest Month', 'December 2024', '₹45,600'),
          const SizedBox(height: 12),
          _buildFavoriteItem('Best Saving Month', 'February 2024', '₹12,300'),
        ],
      ),
    );
  }

  Widget _buildSpendingMilestones() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending Milestones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _buildMilestone('First ₹1,00,000', 'March 2023', true),
          const SizedBox(height: 12),
          _buildMilestone('First ₹5,00,000', 'August 2023', true),
          const SizedBox(height: 12),
          _buildMilestone('First ₹10,00,000', 'January 2024', true),
          const SizedBox(height: 12),
          _buildMilestone('First ₹15,00,000', 'Target: Dec 2025', false),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(String title, String amount, String change, Color changeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8B8B8B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: TextStyle(
              color: changeColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifetimeStatItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF8B5CF6), size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8B8B8B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(String label, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            color: Color(0xFF3B82F6),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF8B8B8B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF3B82F6),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestone(String title, String date, bool achieved) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: achieved ? const Color(0xFF10B981) : const Color(0xFF3A3A3A),
            shape: BoxShape.circle,
          ),
          child: achieved
              ? const Icon(Icons.check, size: 8, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: achieved ? Colors.white : const Color(0xFF8B8B8B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          date,
          style: TextStyle(
            color: achieved ? const Color(0xFF10B981) : const Color(0xFF8B8B8B),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
