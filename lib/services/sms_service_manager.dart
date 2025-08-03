import '../models/expense.dart';
import 'real_sms_transaction_analyzer.dart';
import 'sms_transaction_analyzer.dart';

/// Service manager to handle both real and mock SMS implementations
class SMSServiceManager {
  static SMSServiceManager? _instance;
  static SMSServiceManager get instance => _instance ??= SMSServiceManager._();
  SMSServiceManager._();

  RealSMSTransactionAnalyzer? _realAnalyzer;
  SMSTransactionAnalyzer? _mockAnalyzer;
  bool _isRealSMSEnabled = false;

  Future<void> initialize() async {
    print('� Initializing SMS Service Manager...');
    
    try {
      // Try to initialize real SMS first
      if (await _tryInitializeRealSMS()) {
        print('✅ Real SMS initialized successfully');
        _isRealSMSEnabled = true;
      } else {
        print('⚠️ Falling back to mock SMS service');
        _mockAnalyzer = SMSTransactionAnalyzer();
        _isRealSMSEnabled = false;
      }
    } catch (e) {
      print('❌ Error initializing SMS service: $e');
      _mockAnalyzer = SMSTransactionAnalyzer();
      _isRealSMSEnabled = false;
    }
  }

  Future<bool> _tryInitializeRealSMS() async {
    try {
      _realAnalyzer = RealSMSTransactionAnalyzer();
      await _realAnalyzer!.initialize();
      return true;
    } catch (e) {
      print('Failed to initialize real SMS: $e');
      return false;
    }
  }

  Future<List<Expense>> analyzeTransactions({DateTime? fromDate, DateTime? toDate}) async {
    if (_isRealSMSEnabled && _realAnalyzer != null) {
      final results = await _realAnalyzer!.analyzeTransactions(fromDate: fromDate, toDate: toDate);
      return results.map((parsed) => Expense.fromParsedTransaction(parsed)).toList();
    } else if (_mockAnalyzer != null) {
      print('Using mock SMS analyzer');
      final results = await _mockAnalyzer!.analyzeTransactions(fromDate: fromDate, toDate: toDate);
      return results.map((parsed) => Expense.fromParsedTransaction(parsed)).toList();
    }
    
    return [];
  }

  Future<bool> hasPermissions() async {
    if (_isRealSMSEnabled && _realAnalyzer != null) {
      return await _realAnalyzer!.hasPermissions();
    }
    return true; // Mock always has "permissions"
  }

  Future<bool> requestPermissions() async {
    if (_isRealSMSEnabled && _realAnalyzer != null) {
      return await _realAnalyzer!.requestPermissions();
    }
    return true; // Mock always "grants" permissions
  }

  Future<void> refreshAnalysis() async {
    if (_isRealSMSEnabled && _realAnalyzer != null) {
      await _realAnalyzer!.refreshAnalysis();
    } else if (_mockAnalyzer != null) {
      print('Refreshing mock analysis');
    }
  }

  bool get isRealSMSEnabled => _isRealSMSEnabled;
  bool get isInitialized => _isRealSMSEnabled ? _realAnalyzer != null : _mockAnalyzer != null;

  // Statistics methods
  Future<Map<String, dynamic>> getAnalysisStats() async {
    Map<String, dynamic> stats = {
      'totalTransactions': 0,
      'successfulParsing': 0,
      'failedParsing': 0,
      'duplicatesRemoved': 0,
      'categories': <String, int>{},
      'dateRange': null,
    };

    try {
      if (_isRealSMSEnabled && _realAnalyzer != null) {
        // Real analyzer stats would be more comprehensive
        final results = await _realAnalyzer!.analyzeTransactions();
        stats['totalTransactions'] = results.length;
        stats['successfulParsing'] = results.length;
        
        // Count categories
        Map<String, int> categoryCount = {};
        for (var transaction in results) {
          categoryCount[transaction.category] = (categoryCount[transaction.category] ?? 0) + 1;
        }
        stats['categories'] = categoryCount;
        
        if (results.isNotEmpty) {
          final dates = results.map((t) => t.date).toList()..sort();
          stats['dateRange'] = {
            'from': dates.first.toIso8601String(),
            'to': dates.last.toIso8601String(),
          };
        }
      } else if (_mockAnalyzer != null) {
        // Mock analyzer stats
        final results = await _mockAnalyzer!.analyzeTransactions();
        stats['totalTransactions'] = results.length;
        stats['successfulParsing'] = results.length;
        
        Map<String, int> categoryCount = {};
        for (var transaction in results) {
          categoryCount[transaction.category] = (categoryCount[transaction.category] ?? 0) + 1;
        }
        stats['categories'] = categoryCount;
      }
    } catch (e) {
      print('Error getting analysis stats: $e');
    }

    return stats;
  }
}
