import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Box<Expense>? _expenseBox;
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalExpenses => _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  
  double get thisMonthExpenses {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    return _expenses
        .where((expense) => expense.date.isAfter(thisMonth))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> get expensesByCategory {
    final Map<String, double> categoryTotals = {};
    for (final expense in _expenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  Future<void> initialize() async {
    try {
      _setLoading(true);
      _expenseBox = await Hive.openBox<Expense>('expenses');
      await _loadExpenses();
    } catch (e) {
      _setError('Failed to initialize expenses: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadExpenses() async {
    if (_expenseBox != null) {
      _expenses = _expenseBox!.values.toList();
      _expenses.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      _setLoading(true);
      _clearError();

      // Add to local storage
      await _expenseBox?.add(expense);
      
      // Add to cloud storage if user is authenticated
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('expenses')
            .add(expense.toJson());
      }

      await _loadExpenses();
    } catch (e) {
      _setError('Failed to add expense: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateExpense(String id, Expense updatedExpense) async {
    try {
      _setLoading(true);
      _clearError();

      // Find and update in local storage
      final index = _expenses.indexWhere((expense) => expense.id == id);
      if (index != -1) {
        await _expenseBox?.putAt(index, updatedExpense);
        
        // Update in cloud storage if user is authenticated
        final user = _auth.currentUser;
        if (user != null) {
          final snapshot = await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('expenses')
              .where('id', isEqualTo: id)
              .get();
              
          for (final doc in snapshot.docs) {
            await doc.reference.update(updatedExpense.toJson());
          }
        }
      }

      await _loadExpenses();
    } catch (e) {
      _setError('Failed to update expense: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      _setLoading(true);
      _clearError();

      // Remove from local storage
      final index = _expenses.indexWhere((expense) => expense.id == id);
      if (index != -1) {
        await _expenseBox?.deleteAt(index);
        
        // Remove from cloud storage if user is authenticated
        final user = _auth.currentUser;
        if (user != null) {
          final snapshot = await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('expenses')
              .where('id', isEqualTo: id)
              .get();
              
          for (final doc in snapshot.docs) {
            await doc.reference.delete();
          }
        }
      }

      await _loadExpenses();
    } catch (e) {
      _setError('Failed to delete expense: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> analyzeSMSTransactions() async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: Implement SMS analysis when service is available
      debugPrint('SMS Analysis feature coming soon...');
      
    } catch (e) {
      _setError('Failed to analyze SMS transactions: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> categorizeExpense(String expenseId, String description, double amount) async {
    try {
      // TODO: Implement smart categorization when AI service is available
      debugPrint('Smart categorization feature coming soon...');
      
    } catch (e) {
      _setError('Failed to categorize expense: $e');
    }
  }

  Future<void> syncWithCloud() async {
    try {
      _setLoading(true);
      _clearError();

      final user = _auth.currentUser;
      if (user == null) return;

      // Get cloud expenses
      final cloudSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .get();

      // Merge with local expenses
      final cloudExpenses = cloudSnapshot.docs
          .map((doc) => Expense.fromJson(doc.data()))
          .toList();

      // Simple merge strategy: cloud takes precedence
      await _expenseBox?.clear();
      for (final expense in cloudExpenses) {
        await _expenseBox?.add(expense);
      }

      await _loadExpenses();
    } catch (e) {
      _setError('Failed to sync with cloud: $e');
    } finally {
      _setLoading(false);
    }
  }

  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses
        .where((expense) => 
            expense.date.isAfter(start) && expense.date.isBefore(end))
        .toList();
  }

  List<Expense> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
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
