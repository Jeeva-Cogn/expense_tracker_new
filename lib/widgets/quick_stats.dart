import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class QuickStats extends StatelessWidget {
  const QuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        if (expenseProvider.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final stats = _calculateStats(expenseProvider.expenses);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Stats',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // This Month Stats
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        title: 'This Month',
                        subtitle: 'Expenses',
                        value: '\$${stats['monthlyExpenses']?.toStringAsFixed(2) ?? '0.00'}',
                        icon: Icons.trending_down,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatItem(
                        title: 'This Month',
                        subtitle: 'Income',
                        value: '\$${stats['monthlyIncome']?.toStringAsFixed(2) ?? '0.00'}',
                        icon: Icons.trending_up,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Weekly and Total Stats
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        title: 'This Week',
                        subtitle: 'Spending',
                        value: '\$${stats['weeklyExpenses']?.toStringAsFixed(2) ?? '0.00'}',
                        icon: Icons.calendar_today,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatItem(
                        title: 'Total',
                        subtitle: 'Transactions',
                        value: '${stats['totalTransactions']?.toInt() ?? 0}',
                        icon: Icons.receipt_long,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                
                // Net Balance
                if (stats['netBalance'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: stats['netBalance']! >= 0 
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          stats['netBalance']! >= 0 
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: stats['netBalance']! >= 0 
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Net Balance: \$${stats['netBalance']?.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: stats['netBalance']! >= 0 
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, double> _calculateStats(List<dynamic> expenses) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    double monthlyExpenses = 0;
    double monthlyIncome = 0;
    double weeklyExpenses = 0;
    int totalTransactions = 0;

    for (final expense in expenses) {
      if (expense is! Map<String, dynamic>) continue;
      
      try {
        final amount = (expense['amount'] as num?)?.toDouble() ?? 0.0;
        final isExpense = expense['isExpense'] as bool? ?? true;
        final dateStr = expense['date'] as String?;
        
        if (dateStr == null) continue;
        
        final date = DateTime.tryParse(dateStr);
        if (date == null) continue;

        totalTransactions++;

        // Monthly calculations
        if (date.isAfter(startOfMonth)) {
          if (isExpense) {
            monthlyExpenses += amount;
          } else {
            monthlyIncome += amount;
          }
        }

        // Weekly calculations
        if (date.isAfter(startOfWeek) && isExpense) {
          weeklyExpenses += amount;
        }
      } catch (e) {
        // Skip invalid entries
        continue;
      }
    }

    final netBalance = monthlyIncome - monthlyExpenses;

    return {
      'monthlyExpenses': monthlyExpenses,
      'monthlyIncome': monthlyIncome,
      'weeklyExpenses': weeklyExpenses,
      'totalTransactions': totalTransactions.toDouble(),
      'netBalance': netBalance,
    };
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
