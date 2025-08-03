import 'package:flutter/material.dart';
import '../services/transaction_analysis_service.dart';

/// Widget to display monthly budget progress with color indicators
class BudgetProgressWidget extends StatefulWidget {
  const BudgetProgressWidget({super.key});

  @override
  _BudgetProgressWidgetState createState() => _BudgetProgressWidgetState();
}

class _BudgetProgressWidgetState extends State<BudgetProgressWidget> {
  BudgetProgress? _budgetProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudgetProgress();
  }

  Future<void> _loadBudgetProgress() async {
    try {
      final progress = await TransactionAnalysisService.getBudgetProgress();
      setState(() {
        _budgetProgress = progress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_budgetProgress == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Budget',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Budget amounts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget: ₹${_budgetProgress!.budget.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Spent: ₹${_budgetProgress!.spent.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Remaining',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${_budgetProgress!.remaining.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: _budgetProgress!.remaining > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_budgetProgress!.percentage.toStringAsFixed(1)}% Used',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(),
                    ),
                  ),
                  Text(
                    '${(100 - _budgetProgress!.percentage).toStringAsFixed(1)}% Left',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_budgetProgress!.percentage / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                  minHeight: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress visualization with blocks
          _buildProgressBlocks(),
          const SizedBox(height: 12),

          // Motivational message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getMotivationalMessage(),
                    style: TextStyle(
                      fontSize: 14,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build progress visualization with blocks
  Widget _buildProgressBlocks() {
    const totalBlocks = 30;
    final usedBlocks = (_budgetProgress!.percentage / 100 * totalBlocks).round();
    
    return Row(
      children: List.generate(totalBlocks, (index) {
        final isUsed = index < usedBlocks;
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: isUsed ? _getStatusColor() : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Color _getStatusColor() {
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

  String _getStatusText() {
    switch (_budgetProgress!.status) {
      case BudgetStatus.onTrack:
        return 'On Track';
      case BudgetStatus.warning:
        return 'Watch Out';
      case BudgetStatus.danger:
        return 'Danger Zone';
      case BudgetStatus.exceeded:
        return 'Over Budget';
    }
  }

  IconData _getStatusIcon() {
    switch (_budgetProgress!.status) {
      case BudgetStatus.onTrack:
        return Icons.check_circle;
      case BudgetStatus.warning:
        return Icons.warning;
      case BudgetStatus.danger:
        return Icons.error;
      case BudgetStatus.exceeded:
        return Icons.cancel;
    }
  }

  String _getMotivationalMessage() {
    switch (_budgetProgress!.status) {
      case BudgetStatus.onTrack:
        return 'Great job! You\'re staying within budget. Keep it up! 🎯';
      case BudgetStatus.warning:
        return 'You\'re doing well, but keep an eye on spending. 👀';
      case BudgetStatus.danger:
        return 'Slow down on spending to stay within budget. 🛑';
      case BudgetStatus.exceeded:
        return 'You\'ve exceeded your budget. Let\'s plan better next month! 📅';
    }
  }
}
