import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../models/budget.dart';

class BudgetOverview extends StatelessWidget {
  const BudgetOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        if (budgetProvider.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final activeBudgets = budgetProvider.budgets
            .where((budget) => budget.isActive)
            .take(3)
            .toList();

        if (activeBudgets.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No budgets set',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Create budgets to track your spending',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/budgets');
                    },
                    child: const Text('Create Budget'),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: activeBudgets.map((budget) {
            final progress = BudgetProgress.fromBudget(budget);
            return _BudgetCard(budget: budget, progress: progress);
          }).toList(),
        );
      },
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final BudgetProgress progress;

  const _BudgetCard({
    required this.budget,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.category,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    _getStatusText(progress.status),
                    style: TextStyle(
                      color: _getStatusColor(context, progress.status),
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: _getStatusColor(context, progress.status).withOpacity(0.1),
                  side: BorderSide(
                    color: _getStatusColor(context, progress.status),
                    width: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Progress Bar
            LinearProgressIndicator(
              value: progress.percentage / 100,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(context, progress.status),
              ),
            ),
            const SizedBox(height: 8),
            
            // Amount Information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: \$${progress.spentAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Budget: \$${progress.budgetAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            
            // Percentage
            Text(
              '${progress.percentage.toStringAsFixed(1)}% used',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getStatusColor(context, progress.status),
                fontWeight: FontWeight.w500,
              ),
            ),
            
            // Remaining amount or overspent
            if (progress.status == BudgetStatus.exceeded)
              Text(
                'Overspent by \$${(progress.spentAmount - progress.budgetAmount).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              Text(
                'Remaining: \$${(progress.budgetAmount - progress.spentAmount).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.onTrack:
        return 'On Track';
      case BudgetStatus.warning:
        return 'Warning';
      case BudgetStatus.exceeded:
        return 'Exceeded';
      case BudgetStatus.good:
        return 'Good';
    }
  }

  Color _getStatusColor(BuildContext context, BudgetStatus status) {
    switch (status) {
      case BudgetStatus.onTrack:
        return Theme.of(context).colorScheme.primary;
      case BudgetStatus.warning:
        return Colors.orange;
      case BudgetStatus.exceeded:
        return Theme.of(context).colorScheme.error;
      case BudgetStatus.good:
        return Colors.green;
    }
  }
}
