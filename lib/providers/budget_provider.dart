import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/budget_model.dart';

class BudgetProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Box<Budget>? _budgetBox;
  List<Budget> _budgets = [];
  BudgetDashboardData? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  List<Budget> get budgets => _budgets;
  BudgetDashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalBudget => _budgets.fold(0.0, (sum, budget) => sum + budget.amount);
  double get totalSpent => _budgets.fold(0.0, (sum, budget) => sum + budget.spent);
  double get remainingBudget => totalBudget - totalSpent;
  double get budgetUtilization => totalBudget > 0 ? totalSpent / totalBudget : 0.0;

  Future<void> initialize() async {
    try {
      _setLoading(true);
      _budgetBox = await Hive.openBox<Budget>('budgets');
      await _loadBudgets();
      await _loadDashboardData();
    } catch (e) {
      _setError('Failed to initialize budgets: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadBudgets() async {
    if (_budgetBox != null) {
      _budgets = _budgetBox!.values.toList();
      _budgets.sort((a, b) => a.category.compareTo(b.category));
      notifyListeners();
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      // TODO: Implement dashboard data loading when service is available
      debugPrint('Dashboard data loading feature coming soon...');
      notifyListeners();
    } catch (e) {
      _setError('Failed to load dashboard data: $e');
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      _setLoading(true);
      _clearError();

      // Add to local storage
      await _budgetBox?.add(budget);
      
      // Add to cloud storage if user is authenticated
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('budgets')
            .add(budget.toJson());
      }

      await _loadBudgets();
      await _loadDashboardData();
    } catch (e) {
      _setError('Failed to add budget: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBudget(String id, Budget updatedBudget) async {
    try {
      _setLoading(true);
      _clearError();

      // Find and update in local storage
      final index = _budgets.indexWhere((budget) => budget.id == id);
      if (index != -1) {
        await _budgetBox?.putAt(index, updatedBudget);
        
        // Update in cloud storage if user is authenticated
        final user = _auth.currentUser;
        if (user != null) {
          final snapshot = await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('budgets')
              .where('id', isEqualTo: id)
              .get();
              
          for (final doc in snapshot.docs) {
            await doc.reference.update(updatedBudget.toJson());
          }
        }
      }

      await _loadBudgets();
      await _loadDashboardData();
    } catch (e) {
      _setError('Failed to update budget: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      _setLoading(true);
      _clearError();

      // Remove from local storage
      final index = _budgets.indexWhere((budget) => budget.id == id);
      if (index != -1) {
        await _budgetBox?.deleteAt(index);
        
        // Remove from cloud storage if user is authenticated
        final user = _auth.currentUser;
        if (user != null) {
          final snapshot = await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('budgets')
              .where('id', isEqualTo: id)
              .get();
              
          for (final doc in snapshot.docs) {
            await doc.reference.delete();
          }
        }
      }

      await _loadBudgets();
      await _loadDashboardData();
    } catch (e) {
      _setError('Failed to delete budget: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBudgetSpending(String category, double amount) async {
    try {
      final budgetIndex = _budgets.indexWhere((budget) => budget.category == category);
      if (budgetIndex != -1) {
        final budget = _budgets[budgetIndex];
        final updatedBudget = budget.copyWith(spent: budget.spent + amount);
        await updateBudget(budget.id, updatedBudget);
      }
    } catch (e) {
      _setError('Failed to update budget spending: $e');
    }
  }

  Budget? getBudgetByCategory(String category) {
    try {
      return _budgets.firstWhere((budget) => budget.category == category);
    } catch (e) {
      return null;
    }
  }

  List<Budget> getOverBudgetCategories() {
    return _budgets.where((budget) => budget.spent > budget.amount).toList();
  }

  List<Budget> getNearBudgetLimitCategories({double threshold = 0.8}) {
    return _budgets
        .where((budget) => 
            budget.spent / budget.amount >= threshold && 
            budget.spent <= budget.amount)
        .toList();
  }

  Future<void> syncWithCloud() async {
    try {
      _setLoading(true);
      _clearError();

      final user = _auth.currentUser;
      if (user == null) return;

      // Get cloud budgets
      final cloudSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budgets')
          .get();

      // Merge with local budgets
      final cloudBudgets = cloudSnapshot.docs
          .map((doc) => Budget.fromJson(doc.data()))
          .toList();

      // Simple merge strategy: cloud takes precedence
      await _budgetBox?.clear();
      for (final budget in cloudBudgets) {
        await _budgetBox?.add(budget);
      }

      await _loadBudgets();
      await _loadDashboardData();
    } catch (e) {
      _setError('Failed to sync with cloud: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshDashboard() async {
    await _loadDashboardData();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() => _clearError();
}
