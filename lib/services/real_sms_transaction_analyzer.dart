import /// Real SMS Transaction Analyzer with comprehensive bank support
class RealSMSTransactionAnalyzer {
  static final Telephony _telephony = Telephony.instance;
  static final _dateFormat = DateFormat('dd-MMM-yyyy');
  
  bool _isInitialized = false;
  
  /// Initialize the SMS analyzer with permissions
  Future<bool> initialize() async {
    try {
      // Check if SMS permissions are granted
      final permissionStatus = await Permission.sms.status;
      
      if (permissionStatus != PermissionStatus.granted) {
        // Request permission
        final result = await Permission.sms.request();
        if (result != PermissionStatus.granted) {
          print('❌ SMS permission denied');
          return false;
        }
      }
      
      // Check if telephony is available
      final hasPermission = await _telephony.requestSmsPermissions;
      if (hasPermission != true) {
        print('❌ Telephony permissions not available');
        return false;
      }
      
      _isInitialized = true;
      print('✅ Real SMS Transaction Analyzer initialized successfully');
      return true;
      
    } catch (e) {
      print('❌ Error initializing SMS analyzer: $e');
      return false;
    }
  }t:async';
import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

/// Real SMS Transaction Analyzer with comprehensive bank support
class RealSMSTransactionAnalyzer {
  static final Telephony _telephony = Telephony.instance;
  static final _dateFormat = DateFormat('dd-MMM-yyyy HH:mm');
  
  // Enhanced bank/UPI patterns for transaction detection
  static final List<String> _transactionKeywords = [
    'debited', 'credited', 'paid', 'transaction', 'payment',
    'purchase', 'withdrawal', 'deposit', 'transfer', 'UPI',
    'NEFT', 'RTGS', 'IMPS', 'EMI', 'bill payment', 'spent',
    'charged', 'deducted', 'received', 'refund', 'cashback'
  ];
  
  static final List<String> _bankIdentifiers = [
    // Major Banks
    'SBI', 'HDFC', 'ICICI', 'AXIS', 'PNB', 'BOB', 'CANARA',
    'UNION', 'YES', 'KOTAK', 'IDFC', 'RBL', 'FEDERAL', 'INDUSIND',
    // UPI Services
    'PAYTM', 'PHONEPE', 'GPAY', 'GOOGLEPAY', 'AMAZON', 'FLIPKART', 
    'BHARATPE', 'MOBIKWIK', 'FREECHARGE', 'JIOPAY', 'AIRTEL',
    // Credit Cards
    'AMEX', 'VISA', 'MASTERCARD', 'RUPAY',
    // Others
    'WALLET', 'BANKING', 'BANK'
  ];

  /// Request SMS permissions with user-friendly messaging
  static Future<bool> requestSMSPermission() async {
    try {
      final status = await Permission.sms.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      print('Error requesting SMS permission: $e');
      return false;
    }
  }

  /// Check if SMS permissions are granted
  static Future<bool> hasSMSPermission() async {
    try {
      final status = await Permission.sms.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      print('Error checking SMS permission: $e');
      return false;
    }
  }

  /// Read and analyze SMS messages for transactions
  static Future<List<Expense>> analyzeTransactions({
    int daysBack = 30,
  }) async {
    try {
      // Check permissions first
      if (!await hasSMSPermission()) {
        print('SMS permission not granted, requesting...');
        if (!await requestSMSPermission()) {
          throw Exception('SMS permission denied - cannot read messages');
        }
      }

      // Calculate date range
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: daysBack));

      print('🔍 Analyzing SMS messages from ${startDate.day}/${startDate.month} to ${endDate.day}/${endDate.month}');

      // Query SMS messages using telephony package
      List<SmsMessage> messages = await _telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        filter: SmsFilter.where(SmsColumn.DATE)
            .greaterThan(startDate.millisecondsSinceEpoch.toString())
            .and(SmsColumn.DATE)
            .lessThan(endDate.millisecondsSinceEpoch.toString()),
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );

      print('📱 Found ${messages.length} SMS messages in date range');

      // Filter and parse transaction messages
      List<Expense> expenses = [];
      int transactionCount = 0;
      
      for (var message in messages) {
        if (_isTransactionMessage(message.body ?? '')) {
          transactionCount++;
          final expense = _parseTransactionMessage(message);
          if (expense != null) {
            expenses.add(expense);
          }
        }
      }

      print('💳 Found $transactionCount potential transaction messages');
      print('✅ Successfully parsed ${expenses.length} expense transactions');

      // Remove duplicates and sort by date
      expenses = _removeDuplicates(expenses);
      expenses.sort((a, b) => b.date.compareTo(a.date));

      print('🎯 Final result: ${expenses.length} unique expenses after duplicate removal');

      return expenses;
    } catch (e) {
      print('❌ Error analyzing SMS transactions: $e');
      return [];
    }
  }

  /// Enhanced transaction message detection
  static bool _isTransactionMessage(String body) {
    if (body.isEmpty) return false;
    
    final bodyLower = body.toLowerCase();
    
    // Check for transaction keywords
    bool hasTransactionKeyword = _transactionKeywords.any(
      (keyword) => bodyLower.contains(keyword.toLowerCase())
    );
    
    // Check for bank identifiers
    bool hasBankIdentifier = _bankIdentifiers.any(
      (bank) => bodyLower.contains(bank.toLowerCase())
    );
    
    // Check for amount patterns (₹, Rs., INR, numbers)
    bool hasAmount = RegExp(r'[₹Rs\.INR]\s*[\d,]+\.?\d*|amount.*[\d,]+\.?\d*', caseSensitive: false).hasMatch(body);
    
    // Additional checks for common transaction phrases
    bool hasTransactionPhrase = RegExp(r'(your.*account|card.*used|transaction.*successful|payment.*made)', caseSensitive: false).hasMatch(bodyLower);
    
    return (hasTransactionKeyword || hasTransactionPhrase) && (hasBankIdentifier || hasAmount);
  }

  /// Parse transaction details from SMS message with enhanced accuracy
  static Expense? _parseTransactionMessage(SmsMessage message) {
    try {
      final body = message.body ?? '';
      final sender = message.address ?? 'Unknown';
      
      print('📝 Parsing SMS from $sender: ${body.substring(0, body.length > 50 ? 50 : body.length)}...');
      
      // Extract amount with better patterns
      final amount = _extractAmount(body);
      if (amount == null || amount <= 0) {
        print('❌ Could not extract valid amount from message');
        return null;
      }
      
      // Extract merchant/description
      final description = _extractDescription(body, sender);
      
      // Determine transaction type (debit/credit)
      final isDebit = _isDebitTransaction(body);
      if (!isDebit) {
        print('ℹ️ Skipping credit transaction (not an expense)');
        return null; // Only track expenses (debits)
      }
      
      // Auto-categorize with enhanced logic
      final category = _categorizeTransaction(description, body);
      
      // Use SMS timestamp or current time
      final date = message.date != null 
          ? DateTime.fromMillisecondsSinceEpoch(message.date!)
          : DateTime.now();

      print('✅ Parsed expense: ₹$amount for $description in $category category');

      return Expense(
        id: '${message.date}_${amount.toInt()}_${description.hashCode}',
        title: description,
        amount: amount,
        category: category,
        date: date,
        type: ExpenseType.expense,
        note: 'Auto-imported from SMS: $sender${_extractLocation(body).isNotEmpty ? ' at ${_extractLocation(body)}' : ''}',
        smsSource: sender,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print('❌ Error parsing SMS: $e');
      return null;
    }
  }

  /// Extract amount with comprehensive patterns
  static double? _extractAmount(String text) {
    // Enhanced patterns for different amount formats
    final patterns = [
      // ₹1,234.56 or ₹1234.56
      RegExp(r'₹\s*([\d,]+\.?\d*)'),
      // Rs.1234 or Rs 1234
      RegExp(r'Rs\.?\s*([\d,]+\.?\d*)'),
      // INR 1234
      RegExp(r'INR\s+([\d,]+\.?\d*)'),
      // amount: ₹1234 or Amount Rs.1234
      RegExp(r'amount\s*[:\-]?\s*[₹Rs\.INR]*\s*([\d,]+\.?\d*)', caseSensitive: false),
      // debited by ₹1234
      RegExp(r'(?:debited|paid|charged|spent)\s+(?:by|with|for)?\s*[₹Rs\.INR]*\s*([\d,]+\.?\d*)', caseSensitive: false),
      // transaction of ₹1234
      RegExp(r'(?:transaction|payment|purchase)\s+of\s+[₹Rs\.INR]*\s*([\d,]+\.?\d*)', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '') ?? '';
        final amount = double.tryParse(amountStr);
        if (amount != null && amount > 0) {
          return amount;
        }
      }
    }
    return null;
  }

  /// Extract merchant/description with better accuracy
  static String _extractDescription(String body, String sender) {
    // Try to extract merchant name from common patterns
    final patterns = [
      // at MERCHANT_NAME
      RegExp(r'\bat\s+([A-Z][A-Z0-9\s&\-\.]{2,})', caseSensitive: false),
      // to MERCHANT_NAME
      RegExp(r'\bto\s+([A-Z][A-Z0-9\s&\-\.]{2,})', caseSensitive: false),
      // from MERCHANT_NAME  
      RegExp(r'\bfrom\s+([A-Z][A-Z0-9\s&\-\.]{2,})', caseSensitive: false),
      // on MERCHANT_NAME
      RegExp(r'\bon\s+([A-Z][A-Z0-9\s&\-\.]{2,})', caseSensitive: false),
      // UPI transaction patterns
      RegExp(r'UPI/[^/]+/([A-Z0-9\s&\-\.]+)', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        String merchant = match.group(1)?.trim() ?? '';
        // Clean up common suffixes
        merchant = merchant.replaceAll(RegExp(r'\s+(PVT|LTD|LIMITED|INC)$', caseSensitive: false), '');
        if (merchant.length > 3 && merchant.length < 50) {
          return merchant;
        }
      }
    }

    // Fallback: use sender if it looks like a proper name, otherwise use first few words
    if (sender.isNotEmpty && !sender.contains('-') && sender.length < 20) {
      return sender;
    }
    
    // Last resort: extract meaningful words from message
    final words = body.split(' ').where((word) => 
        word.length > 3 && 
        !RegExp(r'^\d+$').hasMatch(word) && 
        !_transactionKeywords.contains(word.toLowerCase())
    ).take(3);
    
    return words.isEmpty ? sender : words.join(' ');
  }

  /// Enhanced debit transaction detection
  static bool _isDebitTransaction(String body) {
    final debitKeywords = [
      'debited', 'paid', 'purchase', 'withdrawal', 'spent', 'charged',
      'deducted', 'transaction successful', 'payment made', 'bill paid'
    ];
    
    final creditKeywords = [
      'credited', 'received', 'deposit', 'refund', 'cashback', 'reward'
    ];
    
    final bodyLower = body.toLowerCase();
    
    bool hasDebit = debitKeywords.any((keyword) => bodyLower.contains(keyword));
    bool hasCredit = creditKeywords.any((keyword) => bodyLower.contains(keyword));
    
    // If both or neither, check for additional context
    if (hasDebit && hasCredit) {
      // Look for more specific indicators
      return bodyLower.contains('debited') || bodyLower.contains('paid') || bodyLower.contains('spent');
    }
    
    return hasDebit || !hasCredit; // Default to debit if unclear
  }

  /// Enhanced auto-categorization with more patterns
  static String _categorizeTransaction(String description, String body) {
    final text = (description + ' ' + body).toLowerCase();
    
    // Enhanced category mapping with more keywords
    final categories = {
      'Food & Dining': [
        'zomato', 'swiggy', 'dominos', 'pizza', 'mcdonald', 'kfc', 'subway',
        'restaurant', 'food', 'dining', 'cafe', 'hotel', 'canteen', 'mess',
        'biryani', 'chinese', 'indian', 'fast food', 'delivery'
      ],
      'Transportation': [
        'uber', 'ola', 'metro', 'bus', 'taxi', 'petrol', 'fuel', 'transport',
        'auto', 'rickshaw', 'train', 'flight', 'airline', 'cab', 'diesel',
        'parking', 'toll', 'fastag'
      ],
      'Shopping': [
        'amazon', 'flipkart', 'myntra', 'shopping', 'store', 'mall', 'market',
        'clothes', 'electronics', 'mobile', 'laptop', 'appliance', 'grocery',
        'supermarket', 'retail'
      ],
      'Bills & Utilities': [
        'electricity', 'mobile', 'broadband', 'gas', 'water', 'bill', 'recharge',
        'internet', 'wifi', 'telephone', 'utility', 'municipal', 'jio', 'airtel',
        'vodafone', 'bsnl'
      ],
      'EMI & Loans': [
        'emi', 'loan', 'mortgage', 'credit card', 'bajaj', 'hdfc loan', 'sbi loan',
        'personal loan', 'home loan', 'car loan', 'education loan'
      ],
      'Entertainment': [
        'movie', 'cinema', 'netflix', 'spotify', 'prime', 'hotstar', 'game',
        'entertainment', 'ticket', 'show', 'concert', 'theatre'
      ],
      'Healthcare': [
        'hospital', 'medical', 'pharmacy', 'health', 'doctor', 'clinic',
        'medicine', 'apollo', 'max', 'fortis', 'lab', 'test', 'checkup'
      ],
      'Education': [
        'school', 'college', 'course', 'books', 'education', 'fees', 'tuition',
        'university', 'training', 'learning', 'exam', 'admission'
      ],
    };

    for (var category in categories.keys) {
      if (categories[category]!.any((keyword) => text.contains(keyword))) {
        return category;
      }
    }

    return 'Others'; // Default category
  }

  /// Extract location information
  static String? _extractLocation(String body) {
    final locationPatterns = [
      RegExp(r'\bat\s+([A-Z][A-Za-z0-9\s,\-\.]{3,30})', caseSensitive: false),
      RegExp(r'\bin\s+([A-Z][A-Za-z0-9\s,\-\.]{3,30})', caseSensitive: false),
      RegExp(r'\bnear\s+([A-Z][A-Za-z0-9\s,\-\.]{3,30})', caseSensitive: false),
    ];
    
    for (var pattern in locationPatterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final location = match.group(1)?.trim();
        if (location != null && location.length > 3 && location.length < 30) {
          return location;
        }
      }
    }
    return null;
  }

  /// Extract merchant with fallback logic
  static String? _extractMerchant(String body, String description) {
    // Try UPI transaction ID patterns first
    final upiPatterns = [
      RegExp(r'UPI/\d+/([A-Z0-9\-@\.]+)', caseSensitive: false),
      RegExp(r'VPA:\s*([A-Za-z0-9\-@\.]+)', caseSensitive: false),
    ];
    
    for (var pattern in upiPatterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        return match.group(1);
      }
    }
    
    // Fallback to description if it looks like a merchant name
    if (description.length > 3 && description.length < 30 && 
        !description.toLowerCase().contains('unknown')) {
      return description;
    }
    
    return null;
  }

  /// Determine payment method from message content
  static String _extractPaymentMethod(String body) {
    final bodyLower = body.toLowerCase();
    
    if (bodyLower.contains('upi')) return 'UPI';
    if (bodyLower.contains('debit card') || bodyLower.contains('card ending')) return 'Debit Card';
    if (bodyLower.contains('credit card')) return 'Credit Card';
    if (bodyLower.contains('netbanking') || bodyLower.contains('net banking')) return 'Net Banking';
    if (bodyLower.contains('wallet')) return 'Wallet';
    if (bodyLower.contains('neft') || bodyLower.contains('rtgs') || bodyLower.contains('imps')) return 'Bank Transfer';
    if (bodyLower.contains('cash')) return 'Cash';
    
    return 'Bank Transfer'; // Default
  }

  /// Detect if transaction might be recurring
  static bool _detectRecurring(String body) {
    final recurringKeywords = [
      'emi', 'monthly', 'subscription', 'recurring', 'autopay', 'standing instruction'
    ];
    
    final bodyLower = body.toLowerCase();
    return recurringKeywords.any((keyword) => bodyLower.contains(keyword));
  }

  /// Extract relevant tags from message
  static List<String> _extractTags(String body, String sender) {
    List<String> tags = ['auto-imported'];
    final bodyLower = body.toLowerCase();
    
    if (bodyLower.contains('upi')) tags.add('upi');
    if (bodyLower.contains('card')) tags.add('card');
    if (bodyLower.contains('online')) tags.add('online');
    if (bodyLower.contains('contactless')) tags.add('contactless');
    if (bodyLower.contains('successful')) tags.add('successful');
    if (sender.length < 10 && !sender.contains('-')) tags.add('bank-sms');
    
    return tags;
  }

  /// Remove duplicate transactions with enhanced logic
  static List<Expense> _removeDuplicates(List<Expense> expenses) {
    Map<String, Expense> uniqueExpenses = {};
    
    for (var expense in expenses) {
      // Create key based on amount, date (rounded to minute), and description
      final dateKey = DateFormat('yyyy-MM-dd HH:mm').format(expense.date);
      final key = '${expense.amount.toStringAsFixed(2)}_${dateKey}_${expense.description.toLowerCase().trim()}';
      
      if (!uniqueExpenses.containsKey(key)) {
        uniqueExpenses[key] = expense;
      } else {
        // Keep the one with more detailed information
        final existing = uniqueExpenses[key]!;
        if (expense.description.length > existing.description.length ||
            expense.merchant != null && existing.merchant == null) {
          uniqueExpenses[key] = expense;
        }
      }
    }
    
    return uniqueExpenses.values.toList();
  }

  /// Get SMS analysis statistics
  static Future<Map<String, dynamic>> getAnalysisStats({int daysBack = 30}) async {
    try {
      if (!await hasSMSPermission()) {
        return {'error': 'SMS permission not granted'};
      }

      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: daysBack));

      final messages = await _telephony.getInboxSms(
        filter: SmsFilter.where(SmsColumn.DATE)
            .greaterThan(startDate.millisecondsSinceEpoch.toString()),
      );

      int totalMessages = messages.length;
      int transactionMessages = 0;
      Map<String, int> bankCounts = {};

      for (var message in messages) {
        if (_isTransactionMessage(message.body ?? '')) {
          transactionMessages++;
          
          // Count by sender
          final sender = message.address ?? 'Unknown';
          bankCounts[sender] = (bankCounts[sender] ?? 0) + 1;
        }
      }

      return {
        'totalMessages': totalMessages,
        'transactionMessages': transactionMessages,
        'successRate': transactionMessages / totalMessages * 100,
        'topSenders': bankCounts.entries
            .toList()
            ..sort((a, b) => b.value.compareTo(a.value))
            ..take(5),
        'daysAnalyzed': daysBack,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
