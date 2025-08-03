import 'dart:async';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../models/parsed_transaction.dart';

/// Real SMS Transaction Analyzer
/// Analyzes actual SMS messages from banking services to extract transaction details
class RealSMSTransactionAnalyzer {
  static final Telephony _telephony = Telephony.instance;
  static final Uuid _uuid = Uuid();
  
  static List<ParsedTransaction> _cachedTransactions = [];
  static DateTime? _lastAnalysis;
  
  /// Initialize the analyzer and request permissions
  static Future<void> initialize() async {
    print('📱 Initializing Real SMS Transaction Analyzer...');
    
    // Check and request SMS permissions
    final smsPermission = await Permission.sms.status;
    if (!smsPermission.isGranted) {
      print('🔐 Requesting SMS permissions...');
      final result = await Permission.sms.request();
      if (!result.isGranted) {
        throw Exception('SMS permission denied');
      }
    }
    
    print('✅ SMS permissions granted');
  }
  
  /// Check if SMS permissions are granted
  static Future<bool> hasPermissions() async {
    return await Permission.sms.isGranted;
  }
  
  /// Request SMS permissions
  static Future<bool> requestPermissions() async {
    final result = await Permission.sms.request();
    return result.isGranted;
  }
  
  /// Analyze SMS messages and extract transactions
  static Future<List<ParsedTransaction>> analyzeTransactions({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      print('🔍 Analyzing SMS transactions...');
      
      // Set default date range if not provided
      fromDate ??= DateTime.now().subtract(Duration(days: 30));
      toDate ??= DateTime.now();
      
      // Get SMS messages
      final messages = await _telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        filter: SmsFilter.where(SmsColumn.DATE)
            .greaterThanOrEqualTo(fromDate.millisecondsSinceEpoch.toString())
            .and(SmsColumn.DATE)
            .lessThanOrEqualTo(toDate.millisecondsSinceEpoch.toString()),
      );
      
      List<ParsedTransaction> transactions = [];
      
      for (final message in messages) {
        if (_isBankingSMS(message.address ?? '', message.body ?? '')) {
          final transaction = _parseTransactionFromSMS(message);
          if (transaction != null) {
            transactions.add(transaction);
          }
        }
      }
      
      // Remove duplicates and sort by date
      transactions = _removeDuplicates(transactions);
      transactions.sort((a, b) => b.date.compareTo(a.date));
      
      _cachedTransactions = transactions;
      _lastAnalysis = DateTime.now();
      
      print('✅ Found ${transactions.length} transactions');
      return transactions;
      
    } catch (e) {
      print('❌ Error analyzing SMS transactions: $e');
      return [];
    }
  }
  
  /// Parse transaction details from SMS message
  static ParsedTransaction? _parseTransactionFromSMS(SmsMessage message) {
    try {
      final body = message.body ?? '';
      final sender = message.address ?? '';
      final date = DateTime.fromMillisecondsSinceEpoch(message.date ?? 0);
      
      // Extract amount
      final amount = _extractAmount(body);
      if (amount == null) return null;
      
      // Determine transaction type
      final type = _determineTransactionType(body);
      
      // Extract description
      final description = _extractDescription(body);
      
      // Auto-categorize
      final category = _categorizeTransaction(body, description);
      
      return ParsedTransaction(
        id: _uuid.v4(),
        description: description,
        amount: amount,
        category: category,
        date: date,
        rawText: body,
        type: type,
        sender: sender,
      );
      
    } catch (e) {
      print('Error parsing SMS: $e');
      return null;
    }
  }
  
  /// Check if SMS is from a banking service
  static bool _isBankingSMS(String sender, String body) {
    final lowerSender = sender.toLowerCase();
    final lowerBody = body.toLowerCase();
    
    // Bank sender patterns
    final bankSenders = [
      'hdfc', 'icici', 'sbi', 'axis', 'kotak', 'pnb', 'bob', 'canara',
      'union', 'indian', 'central', 'syndicate', 'oriental', 'vijaya',
      'dena', 'allahabad', 'corporation', 'andhra', 'yes', 'indusind',
      'idbi', 'karur', 'south', 'federal', 'rbl', 'dcb', 'karnataka',
      'maharashtra', 'punjab', 'rajasthan', 'tamil', 'telangana',
      'jharkhand', 'himachal', 'haryana', 'gujarat', 'assam', 'bihar',
      'chhattisgarh', 'goa', 'kerala', 'madhya', 'manipur', 'meghalaya',
      'mizoram', 'nagaland', 'odisha', 'sikkim', 'tripura', 'uttarakhand',
      'paytm', 'phonepe', 'googlepay', 'gpay', 'mobikwik', 'freecharge',
      'amazonpay', 'bhim', 'upi'
    ];
    
    // Check if sender matches bank patterns
    for (final bank in bankSenders) {
      if (lowerSender.contains(bank)) {
        return true;
      }
    }
    
    // Transaction keywords
    final transactionKeywords = [
      'debited', 'credited', 'transferred', 'paid', 'received',
      'withdrawn', 'deposited', 'balance', 'transaction', 'payment',
      'purchase', 'refund', 'cashback', 'emi', 'loan', 'interest',
      'charges', 'fee', 'penalty', 'bonus', 'salary', 'dividend'
    ];
    
    for (final keyword in transactionKeywords) {
      if (lowerBody.contains(keyword)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Extract amount from SMS text
  static double? _extractAmount(String text) {
    // Common amount patterns
    final patterns = [
      r'(?:rs\.?|inr\.?)\s*(\d+(?:,\d+)*(?:\.\d+)?)',
      r'(\d+(?:,\d+)*(?:\.\d+)?)\s*(?:rs\.?|inr\.?)',
      r'amount[:\s]*(?:rs\.?|inr\.?)?\s*(\d+(?:,\d+)*(?:\.\d+)?)',
      r'(?:debited|credited|paid|withdrawn|deposited)[:\s]*(?:rs\.?|inr\.?)?\s*(\d+(?:,\d+)*(?:\.\d+)?)',
    ];
    
    for (final pattern in patterns) {
      final regex = RegExp(pattern, caseSensitive: false);
      final match = regex.firstMatch(text);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '') ?? '';
        return double.tryParse(amountStr);
      }
    }
    
    return null;
  }
  
  /// Determine if transaction is debit or credit
  static String _determineTransactionType(String text) {
    final lowerBody = text.toLowerCase();
    
    final debitKeywords = [
      'debited', 'withdrawn', 'paid', 'purchase', 'spent',
      'transferred', 'emi', 'bill', 'fee', 'charges', 'penalty'
    ];
    
    final creditKeywords = [
      'credited', 'received', 'deposited', 'refund', 'cashback',
      'bonus', 'salary', 'interest', 'dividend', 'reward'
    ];
    
    for (final keyword in debitKeywords) {
      if (lowerBody.contains(keyword)) {
        return 'debit';
      }
    }
    
    for (final keyword in creditKeywords) {
      if (lowerBody.contains(keyword)) {
        return 'credit';
      }
    }
    
    return 'debit'; // Default to debit
  }
  
  /// Extract transaction description
  static String _extractDescription(String text) {
    // Remove common banking text patterns
    String description = text
        .replaceAll(RegExp(r'(?:rs\.?|inr\.?)\s*\d+(?:,\d+)*(?:\.\d+)?', caseSensitive: false), '')
        .replaceAll(RegExp(r'\b\d{4}\b'), '') // Remove 4-digit numbers (likely dates/times)
        .replaceAll(RegExp(r'\b\d{10,}\b'), '') // Remove long numbers (account numbers)
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove special characters
        .replaceAll(RegExp(r'\s+'), ' ') // Remove extra spaces
        .trim();
    
    // Extract meaningful parts
    final words = description.split(' ');
    final meaningfulWords = words.where((word) {
      return word.length > 2 && 
             !RegExp(r'^\d+$').hasMatch(word) &&
             !['the', 'and', 'for', 'from', 'your', 'has', 'been'].contains(word.toLowerCase());
    }).take(5).join(' ');
    
    return meaningfulWords.isNotEmpty ? meaningfulWords : 'Transaction';
  }
  
  /// Auto-categorize transaction based on content
  static String _categorizeTransaction(String text, String description) {
    final combined = '$text $description'.toLowerCase();
    
    // Category patterns
    final categoryPatterns = {
      '🍔 Food & Dining': ['restaurant', 'food', 'cafe', 'zomato', 'swiggy', 'dominos', 'pizza', 'mcdonalds', 'kfc'],
      '🚗 Transportation': ['fuel', 'petrol', 'diesel', 'uber', 'ola', 'taxi', 'bus', 'metro', 'parking'],
      '🛍️ Shopping': ['amazon', 'flipkart', 'myntra', 'shopping', 'store', 'mall', 'purchase'],
      '🏠 Home & Utilities': ['electricity', 'water', 'gas', 'internet', 'mobile', 'recharge', 'bill'],
      '💊 Healthcare': ['hospital', 'doctor', 'medical', 'pharmacy', 'medicine', 'health'],
      '🎬 Entertainment': ['movie', 'cinema', 'netflix', 'spotify', 'game', 'entertainment'],
      '💰 Financial': ['emi', 'loan', 'insurance', 'investment', 'mutual', 'sip', 'bank'],
      '✈️ Travel': ['hotel', 'flight', 'booking', 'travel', 'vacation', 'trip'],
      '🎓 Education': ['school', 'college', 'course', 'book', 'education', 'fee'],
      '💸 ATM': ['atm', 'cash', 'withdrawal', 'withdrawn'],
    };
    
    for (final entry in categoryPatterns.entries) {
      for (final keyword in entry.value) {
        if (combined.contains(keyword)) {
          return entry.key;
        }
      }
    }
    
    return '📊 Other';
  }
  
  /// Remove duplicate transactions
  static List<ParsedTransaction> _removeDuplicates(List<ParsedTransaction> transactions) {
    final seen = <String>{};
    return transactions.where((transaction) {
      final key = '${transaction.amount}_${transaction.date.day}_${transaction.sender}';
      return seen.add(key);
    }).toList();
  }
  
  /// Refresh analysis
  static Future<void> refreshAnalysis() async {
    _cachedTransactions.clear();
    _lastAnalysis = null;
    await analyzeTransactions();
  }
  
  /// Get cached transactions
  static List<ParsedTransaction> getCachedTransactions() {
    return List.from(_cachedTransactions);
  }
  
  /// Check if analysis is fresh (within last hour)
  static bool get isAnalysisFresh {
    if (_lastAnalysis == null) return false;
    return DateTime.now().difference(_lastAnalysis!).inHours < 1;
  }
}
