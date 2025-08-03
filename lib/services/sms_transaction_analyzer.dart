import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/expense.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class SMSTransactionAnalyzer {
  static const String _uuid = 'uuid';
  static final _dateFormat = DateFormat('dd-MMM-yyyy HH:mm');
  static final _istTimezone = tz.getLocation('Asia/Kolkata');
  
  // Bank/UPI keywords for transaction detection
  static final _transactionKeywords = [
    'debited', 'credited', 'withdrawn', 'deposited', 'paid', 'received',
    'transaction', 'upi', 'imps', 'neft', 'rtgs', 'emi', 'bill',
    'purchase', 'payment', 'refund', 'cashback', 'reward',
    'atm', 'pos', 'online', 'transfer', 'debit', 'credit'
  ];

  // Common bank/payment service senders
  static final _bankSenders = [
    'SBI', 'HDFC', 'ICICI', 'AXIS', 'KOTAK', 'PNB', 'BOI', 'CANARA',
    'PAYTM', 'PHONEPE', 'GPAY', 'AMAZONPAY', 'BHIM', 'FREECHARGE',
    'MOBIKWIK', 'AIRTEL', 'JIO', 'VODAFONE', 'BSNL'
  ];

  // Smart category mapping
  static final _categoryPatterns = {
    '🍔 Food & Dining': [
      'swiggy', 'zomato', 'dominos', 'pizza', 'mcdonald', 'kfc', 'subway',
      'restaurant', 'cafe', 'food', 'dining', 'meal', 'breakfast', 'lunch', 'dinner'
    ],
    '🚗 Transportation': [
      'uber', 'ola', 'rapido', 'metro', 'bus', 'taxi', 'fuel', 'petrol',
      'diesel', 'parking', 'transport', 'railway', 'flight', 'airline'
    ],
    '🛍️ Shopping': [
      'amazon', 'flipkart', 'myntra', 'ajio', 'nykaa', 'big bazaar',
      'reliance', 'dmart', 'shopping', 'mall', 'store', 'purchase'
    ],
    '🏠 Home & Utilities': [
      'electricity', 'water', 'gas', 'internet', 'broadband', 'wifi',
      'maintenance', 'rent', 'utility', 'bill', 'bescom', 'bwssb'
    ],
    '💊 Healthcare': [
      'hospital', 'pharmacy', 'medicine', 'doctor', 'clinic', 'health',
      'medical', 'apollo', 'fortis', 'max', 'medplus', 'pharmeasy'
    ],
    '🎬 Entertainment': [
      'netflix', 'amazon prime', 'hotstar', 'spotify', 'youtube',
      'movie', 'cinema', 'pvr', 'inox', 'entertainment', 'subscription'
    ],
    '💰 Financial': [
      'emi', 'loan', 'insurance', 'premium', 'mutual fund', 'sip',
      'investment', 'fd', 'rd', 'policy', 'tax', 'lic'
    ],
    '📚 Education': [
      'school', 'college', 'university', 'course', 'fees', 'tuition',
      'books', 'education', 'learning', 'byju', 'unacademy'
    ],
    '💼 Business': [
      'office', 'business', 'professional', 'service', 'consultation',
      'meeting', 'conference', 'work'
    ]
  };

  /// Analyzes SMS messages and extracts transaction data
  static Future<List<ParsedTransaction>> analyzeTransactions() async {
    try {
      // Request SMS permission
      if (!await _requestSMSPermission()) {
        throw Exception('SMS permission denied');
      }

      // Read SMS messages from last 30 days
      final messages = await _readRecentSMS(days: 30);
      
      // Filter and parse transaction messages
      final transactionMessages = messages
          .where(_isTransactionMessage)
          .toList();

      print('📱 Found ${transactionMessages.length} transaction messages');

      final parsedTransactions = <ParsedTransaction>[];
      
      for (final message in transactionMessages) {
        try {
          final transaction = _parseTransactionFromSMS(message);
          if (transaction != null) {
            parsedTransactions.add(transaction);
          }
        } catch (e) {
          print('⚠️ Error parsing SMS: ${e.toString()}');
        }
      }

      // Sort by date (newest first)
      parsedTransactions.sort((a, b) => b.date.compareTo(a.date));
      
      print('✅ Successfully parsed ${parsedTransactions.length} transactions');
      return parsedTransactions;

    } catch (e) {
      print('❌ SMS Analysis Error: ${e.toString()}');
      rethrow;
    }
  }

  /// Request SMS permission from user
  static Future<bool> _requestSMSPermission() async {
    final status = await Permission.sms.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.sms.request();
      return result.isGranted;
    }
    
    return false;
  }

  /// Read recent SMS messages
  static Future<List<SmsMessage>> _readRecentSMS({int days = 30}) async {
    final smsQuery = SmsQuery();
    final messages = await smsQuery.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 1000, // Limit to prevent memory issues
    );

    final cutoffDate = DateTime.now()
        .subtract(Duration(days: days));

    return messages
        .where((msg) => msg.date?.isAfter(cutoffDate) ?? false)
        .toList();
  }

  /// Check if SMS message contains transaction information
  static bool _isTransactionMessage(SmsMessage message) {
    final body = message.body?.toLowerCase() ?? '';
    final sender = message.sender?.toUpperCase() ?? '';
    
    // Check if sender is from known banks/payment services
    final isFromBank = _bankSenders.any((bank) => sender.contains(bank));
    
    // Check if message contains transaction keywords
    final hasTransactionKeywords = _transactionKeywords
        .any((keyword) => body.contains(keyword));
    
    // Look for amount patterns (₹ or Rs. followed by numbers)
    final hasAmountPattern = RegExp(r'[₹rs\.]\s*[\d,]+\.?\d*', 
        caseSensitive: false).hasMatch(body);
    
    return (isFromBank || hasTransactionKeywords) && hasAmountPattern;
  }

  /// Parse transaction details from SMS message
  static ParsedTransaction? _parseTransactionFromSMS(SmsMessage message) {
    final body = message.body ?? '';
    final sender = message.sender ?? '';
    final date = message.date ?? DateTime.now();

    // Extract amount
    final amount = _extractAmount(body);
    if (amount == null || amount <= 0) return null;

    // Extract merchant/description
    final merchant = _extractMerchant(body, sender);
    
    // Determine transaction type
    final transactionType = _determineTransactionType(body);
    
    // Auto-categorize transaction
    final category = _categorizeSmart(merchant, body);
    
    // Calculate confidence score
    final confidence = _calculateConfidence(body, merchant);

    return ParsedTransaction(
      id: const Uuid().v4(),
      amount: amount,
      merchant: merchant,
      date: tz.TZDateTime.from(date, _istTimezone),
      type: transactionType,
      category: category,
      rawSMS: body,
      sender: sender,
      confidence: confidence,
      needsManualReview: confidence < 0.8,
    );
  }

  /// Extract amount from SMS text
  static double? _extractAmount(String text) {
    // Pattern to match amounts like ₹1,234.56 or Rs.1234.56 or 1,234.56
    final amountPattern = RegExp(
      r'[₹rs\.]*\s*([\d,]+\.?\d*)',
      caseSensitive: false
    );
    
    final matches = amountPattern.allMatches(text);
    
    for (final match in matches) {
      final amountStr = match.group(1)?.replaceAll(',', '') ?? '';
      final amount = double.tryParse(amountStr);
      
      if (amount != null && amount > 0) {
        return amount;
      }
    }
    
    return null;
  }

  /// Extract merchant/description from SMS
  static String _extractMerchant(String body, String sender) {
    final lowerBody = body.toLowerCase();
    
    // Look for merchant names after common patterns
    final merchantPatterns = [
      RegExp(r'at\s+([a-zA-Z0-9\s\-_]+)', caseSensitive: false),
      RegExp(r'to\s+([a-zA-Z0-9\s\-_]+)', caseSensitive: false),
      RegExp(r'from\s+([a-zA-Z0-9\s\-_]+)', caseSensitive: false),
      RegExp(r'merchant\s+([a-zA-Z0-9\s\-_]+)', caseSensitive: false),
    ];

    for (final pattern in merchantPatterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final merchant = match.group(1)?.trim() ?? '';
        if (merchant.isNotEmpty && merchant.length > 2) {
          return _cleanMerchantName(merchant);
        }
      }
    }

    // If no specific merchant found, extract from sender or use generic description
    if (sender.isNotEmpty) {
      return _cleanMerchantName(sender);
    }

    return 'Transaction';
  }

  /// Clean and format merchant name
  static String _cleanMerchantName(String rawName) {
    return rawName
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ')
        .trim()
        .split(' ')
        .where((word) => word.length > 1)
        .take(3) // Limit to 3 words
        .join(' ')
        .toUpperCase();
  }

  /// Determine if transaction is income, expense, or transfer
  static ExpenseType _determineTransactionType(String body) {
    final lowerBody = body.toLowerCase();
    
    final incomeKeywords = ['credited', 'received', 'deposited', 'refund', 'cashback', 'reward'];
    final expenseKeywords = ['debited', 'paid', 'withdrawn', 'purchase', 'emi', 'bill'];
    
    if (incomeKeywords.any((keyword) => lowerBody.contains(keyword))) {
      return ExpenseType.income;
    }
    
    if (expenseKeywords.any((keyword) => lowerBody.contains(keyword))) {
      return ExpenseType.expense;
    }
    
    return ExpenseType.expense; // Default to expense
  }

  /// Smart categorization based on merchant and SMS content
  static String _categorizeSmart(String merchant, String body) {
    final searchText = '${merchant.toLowerCase()} ${body.toLowerCase()}';
    
    // Find the best matching category
    String bestCategory = '💸 Others';
    int maxMatches = 0;
    
    for (final category in _categoryPatterns.keys) {
      final patterns = _categoryPatterns[category]!;
      final matches = patterns.where((pattern) => 
          searchText.contains(pattern.toLowerCase())).length;
      
      if (matches > maxMatches) {
        maxMatches = matches;
        bestCategory = category;
      }
    }
    
    return bestCategory;
  }

  /// Calculate confidence score for the parsed transaction
  static double _calculateConfidence(String body, String merchant) {
    double confidence = 0.5; // Base confidence
    
    // Increase confidence based on various factors
    if (body.contains(RegExp(r'[₹rs\.]\s*[\d,]+\.?\d*', caseSensitive: false))) {
      confidence += 0.2; // Has clear amount pattern
    }
    
    if (_bankSenders.any((bank) => body.toUpperCase().contains(bank))) {
      confidence += 0.2; // From known bank
    }
    
    if (merchant.length > 3) {
      confidence += 0.1; // Has meaningful merchant name
    }
    
    if (body.contains('transaction') || body.contains('payment')) {
      confidence += 0.1; // Clear transaction indicators
    }
    
    return confidence.clamp(0.0, 1.0);
  }

  /// Convert parsed transactions to Expense objects
  static List<Expense> convertToExpenses(List<ParsedTransaction> parsedTransactions) {
    return parsedTransactions.map((parsed) {
      return Expense(
        id: parsed.id,
        title: parsed.merchant,
        amount: parsed.amount,
        category: parsed.category,
        date: parsed.date,
        type: parsed.type,
        smsSource: parsed.sender,
        note: 'Auto-detected from SMS\nConfidence: ${(parsed.confidence * 100).toInt()}%',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();
  }

  /// Show category selection dialog for uncertain transactions
  static Future<String?> showCategorySelectionDialog(
    BuildContext context,
    ParsedTransaction transaction,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) => CategorySelectionDialog(transaction: transaction),
    );
  }

  /// Get analysis summary with motivational message
  static String getAnalysisSummary(List<ParsedTransaction> transactions) {
    final totalTransactions = transactions.length;
    final totalAmount = transactions
        .where((t) => t.type == ExpenseType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final now = tz.TZDateTime.now(_istTimezone);
    final timestamp = _dateFormat.format(now);
    
    final motivationalMessages = [
      "Great job tracking your expenses! 🎯",
      "You're taking control of your finances! 💪",
      "Every transaction tracked is a step towards financial freedom! ✨",
      "Smart financial tracking leads to smart decisions! 🧠",
      "You're building excellent money habits! 🌟"
    ];
    
    final randomMessage = motivationalMessages[
        Random().nextInt(motivationalMessages.length)];
    
    return '''
🤖 SMS Analysis Complete!

📊 Summary:
• Found $totalTransactions transactions
• Total expenses: ₹${totalAmount.toStringAsFixed(2)}
• Last analysis: $timestamp

$randomMessage

💡 Tip: Review uncertain transactions for better accuracy.
    ''';
  }
}

/// Represents a parsed transaction from SMS
class ParsedTransaction {
  final String id;
  final double amount;
  final String merchant;
  final DateTime date;
  final ExpenseType type;
  final String category;
  final String rawSMS;
  final String sender;
  final double confidence;
  final bool needsManualReview;

  ParsedTransaction({
    required this.id,
    required this.amount,
    required this.merchant,
    required this.date,
    required this.type,
    required this.category,
    required this.rawSMS,
    required this.sender,
    required this.confidence,
    required this.needsManualReview,
  });

  @override
  String toString() {
    return 'ParsedTransaction(merchant: $merchant, amount: ₹$amount, category: $category)';
  }
}

/// Dialog for manual category selection
class CategorySelectionDialog extends StatefulWidget {
  final ParsedTransaction transaction;

  const CategorySelectionDialog({
    super.key,
    required this.transaction,
  });

  @override
  _CategorySelectionDialogState createState() => _CategorySelectionDialogState();
}

class _CategorySelectionDialogState extends State<CategorySelectionDialog> {
  String? selectedCategory;

  final categories = [
    '🍔 Food & Dining',
    '🚗 Transportation',
    '🛍️ Shopping',
    '🏠 Home & Utilities',
    '💊 Healthcare',
    '🎬 Entertainment',
    '💰 Financial',
    '📚 Education',
    '💼 Business',
    '💸 Others'
  ];

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.transaction.category;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Column(
        children: [
          Icon(Icons.help_outline, size: 48, color: Colors.orange),
          SizedBox(height: 12),
          Text(
            'What is this expense for?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount: ₹${widget.transaction.amount}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Merchant: ${widget.transaction.merchant}'),
                  Text('Date: ${DateFormat('dd MMM yyyy').format(widget.transaction.date)}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Category:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Category selection
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return RadioListTile<String>(
                    title: Text(category),
                    value: category,
                    groupValue: selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(selectedCategory),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
