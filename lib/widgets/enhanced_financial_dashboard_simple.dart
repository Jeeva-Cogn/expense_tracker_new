import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../theme/app_colors.dart';

class EnhancedFinancialDashboard extends StatefulWidget {
  final List<Expense> expenses;

  const EnhancedFinancialDashboard({
    super.key,
    required this.expenses,
  });

  @override
  State<EnhancedFinancialDashboard> createState() => _EnhancedFinancialDashboardState();
}

class _EnhancedFinancialDashboardState extends State<EnhancedFinancialDashboard>
    with TickerProviderStateMixin {
  late AnimationController _summaryController;
  late Animation<double> _summaryAnimation;

  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
    _startAnimations();
  }

  void _setupAnimations() {
    _summaryController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _summaryAnimation = CurvedAnimation(
      parent: _summaryController,
      curve: Curves.easeOutQuart,
    );
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  void _loadData() {
    _expenses = widget.expenses.isNotEmpty ? widget.expenses : _generateDemoExpenses();
  }

  void _startAnimations() {
    _summaryController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFinancialSummary(),
            const SizedBox(height: 24),
            _buildExpensesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _summaryAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.5),
          end: Offset.zero,
        ).animate(_summaryAnimation),
        child: Text(
          'Financial Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSummary() {
    final totalExpenses = _expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    return FadeTransition(
      opacity: _summaryAnimation,
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Expenses',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${totalExpenses.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${_expenses.length} transactions this month',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesList() {
    if (_expenses.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Text('No expenses to display'),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _summaryAnimation,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Expenses',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _expenses.take(5).length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final expense = _expenses[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        _getCategoryIcon(expense.category),
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(expense.title),
                    subtitle: Text(expense.category.toString().split('.').last),
                    trailing: Text(
                      '₹${expense.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt;
      case 'health':
        return Icons.medical_services;
      default:
        return Icons.category;
    }
  }

  List<Expense> _generateDemoExpenses() {
    return [
      Expense(
        id: '1',
        title: 'Grocery Shopping',
        amount: 1200.0,
        category: 'food',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Expense(
        id: '2',
        title: 'Uber Ride',
        amount: 350.0,
        category: 'transport',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Expense(
        id: '3',
        title: 'Movie Tickets',
        amount: 600.0,
        category: 'entertainment',
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
