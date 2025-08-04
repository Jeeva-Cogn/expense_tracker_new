import 'dart:async';
import 'dart:math';
import '../models/expense.dart';
import '../models/parsed_transaction.dart';
import '../services/sms_transaction_analyzer.dart';
import 'package:uuid/uuid.dart';

/// Demo service to simulate SMS transactions for testing the analysis feature
class DemoTransactionGenerator {
  static final _random = Random();
  static const _uuid = Uuid();

  /// Sample SMS messages that simulate real bank/UPI notifications
  static final _sampleSMSMessages = [
    {
      'sender': 'SBI',
      'body': 'Your account has been debited by Rs.450.00 on 03-Aug-25 for UPI transaction to SWIGGY ORDER 3456. Available balance: Rs.12,850.00',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'sender': 'HDFC',
      'body': 'Rs.1200.00 debited from your account ending 4567 for payment to AMAZON PAY INDIA on 02-Aug-25. Outstanding balance: Rs.45,230.50',
      'date': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'sender': 'PAYTM',
      'body': 'Payment of Rs.85.00 made using Paytm to UBER TRIP 789 was successful. Your Paytm wallet balance is Rs.2,145.00',
      'date': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'sender': 'GPAY',
      'body': 'You paid Rs.320.00 to PIZZA HUT DELIVERY via UPI. Transaction ID: 234567890123. Remaining balance: Rs.8,750.00',
      'date': DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      'sender': 'ICICI',
      'body': 'Your account XXXX9876 is credited with Rs.5000.00 on 03-Aug-25 as salary credit from TECH COMPANY PVT LTD. Available balance: Rs.52,750.00',
      'date': DateTime.now().subtract(const Duration(hours: 8)),
    },
    {
      'sender': 'PHONEPE',
      'body': 'You have successfully paid Rs.2500.00 to BIG BAZAAR using PhonePe UPI. Your transaction is complete.',
      'date': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'sender': 'AXIS',
      'body': 'EMI of Rs.12000.00 for your Home Loan has been debited from your account on 01-Aug-25. Next EMI due: 01-Sep-25',
      'date': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'sender': 'SBI',
      'body': 'Rs.850.00 spent at RELIANCE FRESH using your SBI Debit Card ending 8765 on 02-Aug-25. Available balance: Rs.23,450.00',
      'date': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    },
    {
      'sender': 'BSNL',
      'body': 'Your postpaid bill of Rs.599.00 has been paid successfully through auto-debit on 01-Aug-25. Thank you for using our services.',
      'date': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'sender': 'KOTAK',
      'body': 'Cashback of Rs.150.00 credited to your account for shopping at MYNTRA. Transaction date: 02-Aug-25',
      'date': DateTime.now().subtract(const Duration(days: 1, hours: 6)),
    },
  ];

  /// Generate demo transactions to simulate the SMS analysis process
  static Future<List<ParsedTransaction>> generateDemoTransactions() async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    final transactions = <ParsedTransaction>[];

    // Parse each sample SMS message
    for (final smsData in _sampleSMSMessages) {
      final transaction = _parseDemoSMS(
        smsData['body'] as String,
        smsData['sender'] as String,
        smsData['date'] as DateTime,
      );
      
      if (transaction != null) {
        transactions.add(transaction);
      }
    }

    // Add some randomness to make it more realistic
    if (_random.nextBool()) {
      transactions.addAll(_generateRandomTransactions());
    }

    // Sort by date (newest first)
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }

  /// Parse demo SMS message into ParsedTransaction
  static ParsedTransaction? _parseDemoSMS(String body, String sender, DateTime date) {
    // Extract amount
    final amount = _extractAmountFromText(body);
    if (amount == null || amount <= 0) return null;

    // Extract merchant
    final merchant = _extractMerchantFromText(body, sender);
    
    // Determine transaction type
    final transactionType = _determineTransactionType(body);
    
    // Categorize
    final category = _categorizeTransaction(merchant, body);
    
    return ParsedTransaction(
      id: _uuid.v4(),
      description: merchant,
      amount: amount,
      date: date,
      type: transactionType.toString().split('.').last,
      category: category,
      rawText: body,
      sender: sender,
    );
  }

  /// Extract amount from SMS text (simplified version)
  static double? _extractAmountFromText(String text) {
    final amountPattern = RegExp(r'rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false);
    final match = amountPattern.firstMatch(text);
    
    if (match != null) {
      final amountStr = match.group(1)?.replaceAll(',', '') ?? '';
      return double.tryParse(amountStr);
    }
    
    return null;
  }

  /// Extract merchant from SMS text
  static String _extractMerchantFromText(String body, String sender) {
    // Look for common merchant patterns
    final merchantPatterns = [
      RegExp(r'to\s+([a-zA-Z0-9\s\-_]+?)\s+(?:via|using|on|was)', caseSensitive: false),
      RegExp(r'at\s+([a-zA-Z0-9\s\-_]+?)\s+(?:using|on|via)', caseSensitive: false),
      RegExp(r'payment to\s+([a-zA-Z0-9\s\-_]+?)\s+on', caseSensitive: false),
      RegExp(r'from\s+([a-zA-Z0-9\s\-_]+?)\s+(?:on|was)', caseSensitive: false),
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

    // Fallback to sender
    return _cleanMerchantName(sender);
  }

  /// Clean merchant name
  static String _cleanMerchantName(String rawName) {
    return rawName
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ')
        .trim()
        .split(' ')
        .where((word) => word.length > 1)
        .take(3)
        .join(' ')
        .toUpperCase();
  }

  /// Determine transaction type
  static ExpenseType _determineTransactionType(String body) {
    final lowerBody = body.toLowerCase();
    
    if (lowerBody.contains('credited') || 
        lowerBody.contains('salary') || 
        lowerBody.contains('cashback')) {
      return ExpenseType.income;
    }
    
    return ExpenseType.expense;
  }

  /// Categorize transaction
  static String _categorizeTransaction(String merchant, String body) {
    final searchText = '${merchant.toLowerCase()} ${body.toLowerCase()}';
    
    final categoryMap = {
      '🍔 Food & Dining': ['swiggy', 'zomato', 'pizza', 'food', 'restaurant', 'dining'],
      '🚗 Transportation': ['uber', 'ola', 'trip', 'taxi', 'fuel', 'transport'],
      '🛍️ Shopping': ['amazon', 'myntra', 'bazaar', 'shopping', 'store', 'reliance'],
      '🏠 Home & Utilities': ['electricity', 'bsnl', 'bill', 'emi', 'loan'],
      '💊 Healthcare': ['hospital', 'medical', 'pharmacy'],
      '🎬 Entertainment': ['netflix', 'movie', 'entertainment'],
      '💰 Financial': ['emi', 'loan', 'insurance', 'bank'],
      '📚 Education': ['fees', 'education', 'course'],
      '💼 Business': ['salary', 'company', 'office'],
    };
    
    for (final category in categoryMap.keys) {
      final keywords = categoryMap[category]!;
      if (keywords.any((keyword) => searchText.contains(keyword))) {
        return category;
      }
    }
    
    return '💸 Others';
  }

  /// Generate some additional random transactions
  static List<ParsedTransaction> _generateRandomTransactions() {
    final randomTransactions = <ParsedTransaction>[];
    final merchantOptions = ['CAFE COFFEE DAY', 'METRO CARD', 'BOOK STORE', 'MEDICAL STORE'];
    final categories = ['🍔 Food & Dining', '🚗 Transportation', '📚 Education', '💊 Healthcare'];
    
    for (int i = 0; i < _random.nextInt(3) + 1; i++) {
      final merchant = merchantOptions[_random.nextInt(merchantOptions.length)];
      final amount = (_random.nextInt(500) + 50).toDouble();
      
      randomTransactions.add(ParsedTransaction(
        id: _uuid.v4(),
        description: merchant,
        amount: amount,
        date: DateTime.now().subtract(Duration(hours: _random.nextInt(48))),
        type: 'debit',
        category: categories[_random.nextInt(categories.length)],
        rawText: 'You paid Rs.$amount to $merchant via UPI. Transaction successful.',
        sender: 'DEMO',
      ));
    }
    
    return randomTransactions;
  }

  /// Generate analysis summary for demo
  static String generateDemoSummary(List<ParsedTransaction> transactions) {
    final totalTransactions = transactions.length;
    final totalAmount = transactions
        .where((t) => t.type == ExpenseType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final now = DateTime.now();
    final timestamp = '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} IST';
    
    final motivationalMessages = [
      "Excellent financial tracking! 🎯",
      "You're mastering your money! 💪",
      "Smart expense detection at work! ✨",
      "Building great financial habits! 🌟",
      "Your money management is on point! 🎊"
    ];
    
    final randomMessage = motivationalMessages[
        _random.nextInt(motivationalMessages.length)];
    
    return '''
🤖 SMS Analysis Complete!

📊 Summary:
• Found $totalTransactions transactions
• Total expenses: ₹${totalAmount.toStringAsFixed(2)}
• Last analysis: $timestamp

$randomMessage

💡 Tip: Keep tracking to build better spending habits!
    ''';
  }
}
