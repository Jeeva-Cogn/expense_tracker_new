import 'package:permission_handler/permission_handler.dart';
import '../models/expense.dart';
import 'real_sms_transaction_analyzer.dart';
import 'sms_transaction_analyzer.dart';
import 'notification_service.dart';

/// Service manager to handle both real and mock SMS implementations
class SMSServiceManager {
  static bool _useRealSMS = true; // Default to real SMS
  static bool _hasShownPermissionDialog = false;
  
  /// Toggle between real and mock SMS implementation
  static void setRealSMSEnabled(bool enabled) {
    _useRealSMS = enabled;
    print('📱 SMS Service switched to: ${enabled ? "Real SMS" : "Mock SMS"}');
  }
  
  /// Check current SMS service type
  static bool isRealSMSEnabled() => _useRealSMS;
  
  /// Analyze transactions using appropriate SMS service
  static Future<List<Expense>> analyzeTransactions({int daysBack = 30}) async {
    if (_useRealSMS) {
      try {
        print('🔍 Starting real SMS analysis...');
        final analyzer = RealSMSTransactionAnalyzer();
        await analyzer.initialize();
        final expenses = await analyzer.analyzeTransactions(limitDays: daysBack);
        
        if (expenses.isEmpty) {
          print('ℹ️ No transactions found in real SMS, this might be normal for new users');
        }
        
        return expenses;
      } catch (e) {
        print('❌ Real SMS analysis failed: $e');
        print('🔄 Falling back to mock SMS implementation');
        
        // Automatically switch to mock SMS on repeated failures
        if (e.toString().contains('permission denied')) {
          _useRealSMS = false;
        }
        
        // Fallback to mock if real SMS fails
        final mockAnalyzer = SMSTransactionAnalyzer();
        return await mockAnalyzer.analyzeTransactions();
      }
    } else {
      print('🎭 Using mock SMS implementation');
      // Use mock implementation
      final mockAnalyzer = SMSTransactionAnalyzer();
      return await mockAnalyzer.analyzeTransactions();
    }
  }
  
  /// Check if SMS permissions are available
  static Future<bool> checkSMSPermission() async {
    if (_useRealSMS) {
      try {
        final analyzer = RealSMSTransactionAnalyzer();
        return await analyzer.initialize();
      } catch (e) {
        print('Error checking SMS permission: $e');
        return false;
      }
    }
    return true; // Mock always has "permission"
  }
  
  /// Request SMS permissions with user guidance
  static Future<bool> requestSMSPermission() async {
    if (_useRealSMS) {
      try {
        final analyzer = RealSMSTransactionAnalyzer();
        return await analyzer.initialize();
      } catch (e) {
        print('Error requesting SMS permission: $e');
        return false;
      }
    }
    return true; // Mock always grants "permission"
  }
  
  /// Get SMS analysis statistics
  static Future<Map<String, dynamic>> getAnalysisStats({int daysBack = 30}) async {
    if (_useRealSMS) {
      try {
        final analyzer = RealSMSTransactionAnalyzer();
        await analyzer.initialize();
        return {
          'totalMessages': 100, // Placeholder
          'transactionMessages': 25, // Placeholder
          'successRate': 85.0,
          'topSenders': ['SBI', 'HDFC', 'ICICI'],
          'daysAnalyzed': daysBack,
          'mockMode': false,
        };
      } catch (e) {
        return {
          'error': e.toString(),
          'fallbackUsed': true,
        };
      }
    } else {
      // Mock stats
      return {
        'totalMessages': 0,
        'transactionMessages': 0,
        'successRate': 0.0,
        'topSenders': [],
        'daysAnalyzed': daysBack,
        'mockMode': true,
      };
    }
  }
  
  /// Get current service status
  static Map<String, dynamic> getServiceStatus() {
    return {
      'isRealSMS': _useRealSMS,
      'serviceName': _useRealSMS ? 'Real SMS Analyzer' : 'Mock SMS Analyzer',
      'description': _useRealSMS 
          ? 'Reading actual SMS messages for transaction detection'
          : 'Using demo data for transaction simulation',
      'permissionRequired': _useRealSMS,
    };
  }
  
  /// Handle permission denied scenario
  static Future<void> handlePermissionDenied() async {
    print('⚠️ SMS permission denied, switching to mock mode');
    _useRealSMS = false;
  }
  
  /// Reset to real SMS (for settings toggle)
  static Future<bool> enableRealSMSWithPermission() async {
    try {
      final analyzer = RealSMSTransactionAnalyzer();
      final hasPermission = await analyzer.initialize();
      if (hasPermission) {
        _useRealSMS = true;
        print('✅ Real SMS enabled successfully');
        return true;
      } else {
        print('❌ Cannot enable real SMS without permission');
        return false;
      }
    } catch (e) {
      print('❌ Error enabling real SMS: $e');
      return false;
    }
  }
  
  /// Get user-friendly status message
  static String getStatusMessage() {
    if (_useRealSMS) {
      return '📱 Real SMS Analysis Active - Detecting transactions from bank messages';
    } else {
      return '🎭 Demo Mode Active - Using sample transaction data';
    }
  }
  
  /// Check if SMS service is functional
  static Future<bool> isServiceFunctional() async {
    if (_useRealSMS) {
      return await checkSMSPermission();
    }
    return true; // Mock is always functional
  }
}
