import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/parsed_transaction.dart';

/// Real SMS Transaction Analyzer
/// TEMPORARILY DISABLED: SMS functionality removed for build stability
/// Will be re-enabled once telephony package namespace issues are resolved
class RealSMSTransactionAnalyzer {
  static final Uuid _uuid = Uuid();
  
  static List<ParsedTransaction> _cachedTransactions = [];
  
  /// Initialize the SMS analyzer
  static Future<void> initialize() async {
    print('⚠️ SMS analyzer temporarily disabled for build stability');
  }
  
  /// Check if SMS permissions are granted
  static Future<bool> hasPermissions() async {
    return false; // Temporarily return false
  }
  
  /// Request SMS permissions
  static Future<bool> requestPermissions() async {
    print('⚠️ SMS permissions temporarily disabled');
    return false;
  }
  
  /// Analyze SMS messages and extract transactions
  static Future<List<ParsedTransaction>> analyzeTransactions({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    print('⚠️ SMS analysis temporarily disabled for build stability');
    return [];
  }
  
  /// Get cached transactions
  static List<ParsedTransaction> getCachedTransactions() {
    return [];
  }
  
  /// Clear cached transactions
  static void clearCache() {
    _cachedTransactions.clear();
  }
  
  /// Check if cache needs refresh
  static bool shouldRefreshCache() {
    return true; // Always refresh (but will return empty anyway)
  }
  
  /// Get demo transactions for testing
  static List<ParsedTransaction> getDemoTransactions() {
    final now = DateTime.now();
    return [
      ParsedTransaction(
        id: _uuid.v4(),
        amount: 250.0,
        description: 'Demo grocery purchase',
        date: now.subtract(Duration(hours: 2)),
        rawText: 'DEMO: Your account debited for Rs.250.00 at Demo Supermarket',
        type: 'debit',
        category: 'Groceries',
        sender: 'DEMO-BANK',
      ),
      ParsedTransaction(
        id: _uuid.v4(),
        amount: 1500.0,
        description: 'Demo salary credit',
        date: now.subtract(Duration(days: 1)),
        rawText: 'DEMO: Your account credited with Rs.1500.00 - Salary',
        type: 'credit',
        category: 'Salary',
        sender: 'DEMO-BANK',
      ),
    ];
  }
}
