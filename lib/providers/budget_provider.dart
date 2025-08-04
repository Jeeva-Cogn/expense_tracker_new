import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/budget.dart';

class BudgetProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Box<Budget>? _budgetBox;
  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalBudget => _budgets.fold(0.0, (total, budget) => total + budget.amount);
  double get totalSpent => _budgets.fold(0.0, (total, budget) => total + budget.spent);
  double get remainingBudget => totalBudget - totalSpent;
  double get budgetUtilization => totalBudget > 0 ? totalSpent / totalBudget : 0.0;

  // Load budgets method
  Future<void> loadBudgets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _initializeBox();
      await _loadFromLocal();
      
      // Try to sync with cloud if user is authenticated
      if (_auth.currentUser != null) {
        await _syncWithCloud();
      }
    } catch (e) {
      _errorMessage = 'Failed to load budgets: $e';
      debugPrint('Error loading budgets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _initializeBox() async {
    if (_budgetBox == null || !_budgetBox!.isOpen) {
      _budgetBox = await Hive.openBox<Budget>('budgets');
    }
  }

  Future<void> _loadFromLocal() async {
    if (_budgetBox != null) {
      _budgets = _budgetBox!.values.toList();
      _budgets.sort((a, b) => b.startDate.compareTo(a.startDate));
    }
  }

  Future<void> _syncWithCloud() async {
    // Placeholder for cloud sync
  }

  Future<void> initialize() async {
    await loadBudgets();
  }

  // Add a new budget
  Future<void> addBudget(Budget budget) async {
    try {
      await _initializeBox();
      await _budgetBox!.put(budget.id, budget);
      _budgets.add(budget);
      _budgets.sort((a, b) => b.startDate.compareTo(a.startDate));
      
      if (_auth.currentUser != null) {
        await _firestore
            .collection('budgets')
            .doc(budget.id)
            .set(budget.toJson());
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding budget: $e');
      rethrow;
    }
  }

  // Update a budget
  Future<void> updateBudget(Budget budget) async {
    try {
      await _initializeBox();
      await _budgetBox!.put(budget.id, budget);
      
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
      }
      
      if (_auth.currentUser != null) {
        await _firestore
            .collection('budgets')
            .doc(budget.id)
            .update(budget.toJson());
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating budget: $e');
      rethrow;
    }
  }

  // Delete a budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      await _initializeBox();
      await _budgetBox!.delete(budgetId);
      _budgets.removeWhere((budget) => budget.id == budgetId);
      
      if (_auth.currentUser != null) {
        await _firestore.collection('budgets').doc(budgetId).delete();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting budget: $e');
      rethrow;
    }
  }

  // Get budget by id
  Budget? getBudgetById(String id) {
    try {
      return _budgets.firstWhere((budget) => budget.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get budgets by category
  List<Budget> getBudgetsByCategory(String category) {
    return _budgets.where((budget) => budget.category == category).toList();
  }

  // Get active budgets
  List<Budget> getActiveBudgets() {
    return _budgets.where((budget) => budget.isActive).toList();
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      await _budgetBox?.clear();
      _budgets.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing budget data: $e');
      rethrow;
    }
  }
}
