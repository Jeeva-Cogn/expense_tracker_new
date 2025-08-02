import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String category;

  @HiveField(4)
  String? subcategory;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String? note;

  @HiveField(7)
  String? receiptImagePath;

  @HiveField(8)
  ExpenseType type; // income, expense, transfer

  @HiveField(9)
  String? walletId;

  @HiveField(10)
  bool isRecurring;

  @HiveField(11)
  RecurringType? recurringType;

  @HiveField(12)
  String? smsSource; // For SMS-parsed expenses

  @HiveField(13)
  Map<String, double>? splits; // For shared expenses

  @HiveField(14)
  bool isSynced;

  @HiveField(15)
  DateTime createdAt;

  @HiveField(16)
  DateTime updatedAt;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.subcategory,
    required this.date,
    this.note,
    this.receiptImagePath,
    this.type = ExpenseType.expense,
    this.walletId,
    this.isRecurring = false,
    this.recurringType,
    this.smsSource,
    this.splits,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper methods
  bool get isIncome => type == ExpenseType.income;
  bool get isExpense => type == ExpenseType.expense;
  bool get isShared => splits != null && splits!.isNotEmpty;
  bool get isFromSMS => smsSource != null && smsSource!.isNotEmpty;
  bool get hasReceipt => receiptImagePath != null && receiptImagePath!.isNotEmpty;
  
  double get myShare {
    if (!isShared) return amount;
    return splits!.values.fold(0.0, (sum, share) => sum + share);
  }

  // AI-powered expense analysis
  double get dailyImpact => amount / DateTime.now().difference(date).inDays.clamp(1, 365);
  
  String get financialHealth {
    if (isIncome) return 'Positive';
    if (amount > 5000) return 'High Impact';
    if (amount > 1000) return 'Medium Impact';
    return 'Low Impact';
  }
  
  bool get isRecent => DateTime.now().difference(date).inDays <= 7;
  bool get isThisMonth => date.month == DateTime.now().month && date.year == DateTime.now().year;
  
  // Fraud detection patterns
  bool get isSuspicious {
    if (!isFromSMS) return false;
    final text = (note ?? '').toLowerCase();
    return text.contains(RegExp(r'verify|click|link|urgent|expire|suspended|otp')) ||
           amount > 50000 ||
           date.hour < 6 || date.hour > 23;
  }

  // Smart categorization with ML-like patterns
  static String suggestCategory(String title, String? note) {
    final text = '${title.toLowerCase()} ${note?.toLowerCase() ?? ''}';
    
    // Food & Dining
    if (text.contains(RegExp(r'restaurant|food|cafe|coffee|lunch|dinner|breakfast|pizza|burger|mcdonalds|kfc|dominos|swiggy|zomato|uber eats'))) {
      return '🍔 Food & Dining';
    }
    
    // Transportation
    if (text.contains(RegExp(r'fuel|petrol|diesel|uber|ola|taxi|bus|train|metro|auto|parking|toll'))) {
      return '🚗 Transportation';
    }
    
    // Shopping
    if (text.contains(RegExp(r'amazon|flipkart|shopping|mall|store|clothes|electronics|phone|laptop|gift'))) {
      return '🛍️ Shopping';
    }
    
    // Utilities
    if (text.contains(RegExp(r'electricity|water|internet|mobile|wifi|recharge|bill|rent'))) {
      return '🏠 Home & Utilities';
    }
    
    // Healthcare
    if (text.contains(RegExp(r'doctor|hospital|medicine|pharmacy|health|medical|gym|fitness'))) {
      return '💊 Healthcare';
    }
    
    // Entertainment
    if (text.contains(RegExp(r'movie|cinema|netflix|spotify|game|entertainment|vacation|travel|hotel'))) {
      return '🎬 Entertainment';
    }
    
    // Financial
    if (text.contains(RegExp(r'emi|insurance|investment|mutual fund|bank|loan|credit card'))) {
      return '💰 Financial';
    }
    
    return '💸 Others';
  }

  // Enhanced SMS parsing with location and merchant intelligence
  static double? extractAmountFromSMS(String smsText) {
    // Advanced patterns for global banking SMS formats
    final patterns = [
      // Indian banks
      RegExp(r'rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'inr\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'amount\s*rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'debited\s*rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'credited\s*rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      // International formats
      RegExp(r'\$(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'usd\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'€(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'eur\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(smsText);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '');
        return double.tryParse(amountStr ?? '');
      }
    }
    return null;
  }

  // Extract location from SMS
  static String? extractLocationFromSMS(String smsText) {
    final locationPatterns = [
      RegExp(r'at\s+([A-Z][A-Z\s,.-]+)\s+on\s+\d', caseSensitive: false),
      RegExp(r'location:\s*([A-Z][A-Z\s,.-]+)', caseSensitive: false),
      RegExp(r'merchant:\s*([A-Z][A-Z\s,.-]+)', caseSensitive: false),
    ];
    
    for (final pattern in locationPatterns) {
      final match = pattern.firstMatch(smsText);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    return null;
  }

  // Advanced merchant detection with confidence scoring
  static Map<String, dynamic> extractMerchantInfo(String smsText) {
    final merchantPatterns = [
      RegExp(r'at\s+([A-Z][A-Z\s&.-]+?)(?:\s+on|\s+dated|\s+\d)', caseSensitive: false),
      RegExp(r'to\s+([A-Z][A-Z\s&.-]+?)(?:\s+on|\s+dated|\s+\d)', caseSensitive: false),
      RegExp(r'from\s+([A-Z][A-Z\s&.-]+?)(?:\s+(?:ac|account))', caseSensitive: false),
      RegExp(r'merchant:\s*([A-Z][A-Z\s&.-]+)', caseSensitive: false),
    ];
    
    for (final pattern in merchantPatterns) {
      final match = pattern.firstMatch(smsText);
      if (match != null) {
        final merchant = match.group(1)?.trim() ?? '';
        return {
          'name': merchant,
          'confidence': _calculateMerchantConfidence(merchant, smsText),
          'type': _detectMerchantType(merchant),
        };
      }
    }
    
    return {
      'name': 'Unknown Merchant',
      'confidence': 0.0,
      'type': 'unknown',
    };
  }

  // Calculate confidence score for merchant detection
  static double _calculateMerchantConfidence(String merchant, String smsText) {
    double confidence = 0.5; // Base confidence
    
    // Boost confidence for known patterns
    if (merchant.length > 5) confidence += 0.2;
    if (merchant.contains(RegExp(r'[A-Z]{2,}'))) confidence += 0.1;
    if (smsText.toLowerCase().contains('merchant')) confidence += 0.2;
    
    return confidence.clamp(0.0, 1.0);
  }

  // Detect merchant type for better categorization
  static String _detectMerchantType(String merchant) {
    final merchantLower = merchant.toLowerCase();
    
    if (merchantLower.contains(RegExp(r'restaurant|cafe|food|pizza|burger'))) return 'restaurant';
    if (merchantLower.contains(RegExp(r'mart|store|shop|mall|market'))) return 'retail';
    if (merchantLower.contains(RegExp(r'fuel|petrol|gas|station'))) return 'fuel';
    if (merchantLower.contains(RegExp(r'hospital|clinic|pharmacy'))) return 'healthcare';
    if (merchantLower.contains(RegExp(r'hotel|resort|travel'))) return 'travel';
    if (merchantLower.contains(RegExp(r'atm|bank'))) return 'banking';
    
    return 'unknown';
  }

  // Determine expense type from SMS
  static ExpenseType getTypeFromSMS(String smsText) {
    final text = smsText.toLowerCase();
    if (text.contains(RegExp(r'credited|deposit|salary|refund|cashback'))) {
      return ExpenseType.income;
    } else if (text.contains(RegExp(r'transfer|sent to'))) {
      return ExpenseType.transfer;
    }
    return ExpenseType.expense;
  }

  // Create intelligent expense from SMS with enhanced parsing
  static Expense fromSMS(String smsText, String smsSource) {
    final now = DateTime.now();
    final amount = extractAmountFromSMS(smsText) ?? 0.0;
    final type = getTypeFromSMS(smsText);
    final merchantInfo = extractMerchantInfo(smsText);
    final location = extractLocationFromSMS(smsText);
    
    // Intelligent title generation
    String title = merchantInfo['name'] as String;
    if (title == 'Unknown Merchant') {
      title = type == ExpenseType.income ? 'Income Received' : 
              type == ExpenseType.transfer ? 'Money Transfer' : 'Payment Made';
    }

    // Enhanced categorization using merchant type
    String category = suggestCategory(title, smsText);
    if (merchantInfo['type'] != 'unknown') {
      category = _getCategoryFromMerchantType(merchantInfo['type'] as String);
    }

    // Enhanced note with extracted information
    String enhancedNote = smsText;
    if (location != null) {
      enhancedNote += '\n📍 Location: $location';
    }
    if (merchantInfo['confidence'] > 0.7) {
      enhancedNote += '\n🏪 Merchant: ${merchantInfo['name']} (${(merchantInfo['confidence'] * 100).toInt()}% confidence)';
    }
    
    return Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: category,
      date: now,
      type: type,
      smsSource: smsSource,
      note: enhancedNote,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Map merchant types to categories
  static String _getCategoryFromMerchantType(String merchantType) {
    switch (merchantType) {
      case 'restaurant': return '🍔 Food & Dining';
      case 'retail': return '🛍️ Shopping';
      case 'fuel': return '🚗 Transportation';
      case 'healthcare': return '💊 Healthcare';
      case 'travel': return '🎬 Entertainment';
      case 'banking': return '💰 Financial';
      default: return '💸 Others';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'subcategory': subcategory,
    'date': date.toIso8601String(),
    'note': note,
    'receiptImagePath': receiptImagePath,
    'type': type.name,
    'walletId': walletId,
    'isRecurring': isRecurring,
    'recurringType': recurringType?.name,
    'smsSource': smsSource,
    'splits': splits,
    'isSynced': isSynced,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    title: json['title'],
    amount: json['amount'].toDouble(),
    category: json['category'],
    subcategory: json['subcategory'],
    date: DateTime.parse(json['date']),
    note: json['note'],
    receiptImagePath: json['receiptImagePath'],
    type: ExpenseType.values.firstWhere((e) => e.name == json['type']),
    walletId: json['walletId'],
    isRecurring: json['isRecurring'] ?? false,
    recurringType: json['recurringType'] != null 
        ? RecurringType.values.firstWhere((e) => e.name == json['recurringType'])
        : null,
    smsSource: json['smsSource'],
    splits: json['splits']?.cast<String, double>(),
    isSynced: json['isSynced'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

@HiveType(typeId: 1)
enum ExpenseType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
  @HiveField(2)
  transfer,
}

@HiveType(typeId: 4)
enum RecurringType {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly,
}

class ExpenseCategory {
  static const Map<String, List<String>> categories = {
    '🍔 Food & Dining': [
      'Restaurant',
      'Fast Food',
      'Groceries',
      'Coffee & Tea',
      'Alcohol & Bars',
      'Home Food'
    ],
    '🚗 Transportation': [
      'Fuel',
      'Public Transport',
      'Taxi & Rideshare',
      'Auto Maintenance',
      'Parking',
      'Tolls'
    ],
    '🛍️ Shopping': [
      'Clothing',
      'Electronics',
      'Books & Education',
      'Gifts & Donations',
      'Personal Care',
      'Household Items'
    ],
    '🏠 Home & Utilities': [
      'Rent',
      'Electricity',
      'Water',
      'Internet',
      'Mobile',
      'Home Maintenance'
    ],
    '💊 Healthcare': [
      'Doctor Visits',
      'Medicines',
      'Health Insurance',
      'Fitness & Gym',
      'Mental Health'
    ],
    '🎬 Entertainment': [
      'Movies & Shows',
      'Games',
      'Sports',
      'Music & Concerts',
      'Travel & Vacation'
    ],
    '💰 Financial': [
      'EMI',
      'Insurance',
      'Investments',
      'Bank Charges',
      'Taxes'
    ],
    '📚 Education': [
      'Courses',
      'Books',
      'School Fees',
      'Online Learning'
    ],
    '💼 Business': [
      'Office Supplies',
      'Professional Services',
      'Business Travel',
      'Equipment'
    ],
    '💸 Others': [
      'Miscellaneous',
      'Emergency',
      'Charity',
      'Pets'
    ]
  };

  static List<String> get allCategories => categories.keys.toList();
  
  static List<String> getSubcategories(String category) {
    return categories[category] ?? [];
  }

  static String getCategoryEmoji(String category) {
    return category.split(' ').first;
  }
}
