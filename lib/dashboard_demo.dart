import 'package:flutter/material.dart';
import 'widgets/enhanced_financial_dashboard.dart';
import 'models/expense.dart';
import 'models/budget.dart';
import 'models/goal.dart';

/// Demo app to showcase the Enhanced Financial Dashboard
/// Run this to see the animated charts in action
void main() {
  runApp(DashboardDemoApp());
}

class DashboardDemoApp extends StatelessWidget {
  const DashboardDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced Dashboard Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: DashboardDemoScreen(),
    );
  }
}

class DashboardDemoScreen extends StatelessWidget {
  const DashboardDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Enhanced Dashboard Demo'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 0,
      ),
      body: const EnhancedFinancialDashboard(
        expenses: [], // Will use demo data
        budgets: [],
        goals: [],
      ),
    );
  }
}
