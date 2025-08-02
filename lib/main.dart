import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';

const List<String> categories = [
  'Misc', 'EMI', 'Groceries', 'Bills', 'Shopping', 'Travel', 'Food', 'Other'
];

const List<String> transactionKeywords = [
  'debited', 'credited', 'paid', 'transferred', 'withdrawn', 'deposited',
  'purchase', 'refund', 'cashback', 'reward', 'fee', 'charge', 'emi'
];

class Expense {
  final double amount;
  final String category;
  final String date;
  final String time;
  final String? originalMessage;
  final String type; // 'debit', 'credit', 'unknown'

  Expense({
    required this.amount, 
    required this.category, 
    required this.date,
    required this.time,
    this.originalMessage,
    this.type = 'debit'
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'category': category,
    'date': date,
    'time': time,
    'originalMessage': originalMessage,
    'type': type,
  };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      amount: json['amount'],
      category: json['category'],
      date: json['date'],
      time: json['time'] ?? '00:00',
      originalMessage: json['originalMessage'],
      type: json['type'] ?? 'debit',
    );
  }
}

class Budget {
  double monthlyLimit;
  double dailyLimit;
  String month; // Format: YYYY-MM

  Budget({
    required this.monthlyLimit,
    required this.dailyLimit,
    required this.month,
  });

  Map<String, dynamic> toJson() => {
    'monthlyLimit': monthlyLimit,
    'dailyLimit': dailyLimit,
    'month': month,
  };

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      monthlyLimit: json['monthlyLimit'],
      dailyLimit: json['dailyLimit'],
      month: json['month'],
    );
  }
}

class ExpenseTrackerApp extends StatefulWidget {
  @override
  _ExpenseTrackerAppState createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController monthlyBudgetController = TextEditingController();
  final TextEditingController dailyBudgetController = TextEditingController();
  String detectedAmount = '';
  String detectedType = 'debit';
  String selectedCategory = categories[0];
  List<Expense> expenses = [];
  Budget? currentBudget;
  String summaryText = '';
  String dailySummaryText = '';
  String expensesList = '';
  bool isAutoDetectionEnabled = true;
  
  final Map<String, String> categoryEmojis = {
    'Misc': '🗂️',
    'EMI': '💳',
    'Groceries': '🛒',
    'Bills': '🧾',
    'Shopping': '🛍️',
    'Travel': '✈️',
    'Food': '🍔',
    'Other': '🔖',
  };

  @override
  void initState() {
    super.initState();
    loadExpenses();
    loadBudget();
    refreshSummary();
    // Auto-run at 10 PM IST would require background task scheduling
    _scheduleAutoCheck();
  }

  void _scheduleAutoCheck() {
    // For demo purposes, we'll simulate the auto-check functionality
    // In a real app, you'd use background tasks or notifications
    Timer.periodic(Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (now.hour == 22 && now.minute == 0) { // 10 PM
        _autoDetectTransactions();
      }
    });
  }

  void _autoDetectTransactions() {
    // This would integrate with SMS reading permissions and financial message analysis
    // For demo, we'll show a notification to check for new transactions
    _showTransactionCheckDialog();
  }

  void _showTransactionCheckDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('🔔 Daily Transaction Check'),
          content: Text('Time to review your financial messages for any new transactions. Would you like to add any expenses from today?'),
          actions: [
            TextButton(
              child: Text('Later'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Check Now'),
              onPressed: () {
                Navigator.of(context).pop();
                // Focus on the message input
                FocusScope.of(context).requestFocus(FocusNode());
              },
            ),
          ],
        );
      },
    );
  }

  void loadExpenses() async {
    // For demo, using local file. In real app, use proper storage.
    final file = File('${Directory.current.path}/expenses.json');
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      setState(() {
        expenses = jsonList.map((e) => Expense.fromJson(e)).toList();
      });
    }
  }

  void loadBudget() async {
    final file = File('${Directory.current.path}/budget.json');
    if (await file.exists()) {
      final contents = await file.readAsString();
      final json = jsonDecode(contents);
      setState(() {
        currentBudget = Budget.fromJson(json);
      });
    } else {
      // Create default budget for current month
      final now = DateTime.now();
      final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      setState(() {
        currentBudget = Budget(
          monthlyLimit: 50000.0, // Default monthly budget
          dailyLimit: 2000.0,    // Default daily budget
          month: currentMonth,
        );
      });
      saveBudget();
    }
  }

  void saveBudget() async {
    if (currentBudget == null) return;
    final file = File('${Directory.current.path}/budget.json');
    await file.writeAsString(jsonEncode(currentBudget!.toJson()));
  }

  void saveExpenses() async {
    final file = File('${Directory.current.path}/expenses.json');
    final jsonList = expenses.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  String extractAmount(String msg) {
    final regex = RegExp(r'(?:Rs\.?|INR|₹|debited for|Amount:)\s?(\d{1,6}(?:\.\d{1,2})?)', caseSensitive: false);
    final match = regex.firstMatch(msg);
    return match != null ? match.group(1)! : '';
  }

  String detectTransactionType(String msg) {
    final msgLower = msg.toLowerCase();
    if (msgLower.contains('credited') || msgLower.contains('received') || 
        msgLower.contains('refund') || msgLower.contains('cashback')) {
      return 'credit';
    } else if (msgLower.contains('debited') || msgLower.contains('paid') || 
               msgLower.contains('withdrawn') || msgLower.contains('purchase')) {
      return 'debit';
    }
    return 'unknown';
  }

  String smartCategoryDetection(String msg) {
    final msgLower = msg.toLowerCase();
    
    // EMI detection
    if (msgLower.contains('emi') || msgLower.contains('loan') || msgLower.contains('installment')) {
      return 'EMI';
    }
    // Grocery detection
    if (msgLower.contains('grocery') || msgLower.contains('supermarket') || 
        msgLower.contains('bigbasket') || msgLower.contains('grofers') ||
        msgLower.contains('swiggy instamart') || msgLower.contains('blinkit')) {
      return 'Groceries';
    }
    // Bills detection
    if (msgLower.contains('electricity') || msgLower.contains('water') || 
        msgLower.contains('gas') || msgLower.contains('internet') ||
        msgLower.contains('mobile') || msgLower.contains('recharge')) {
      return 'Bills';
    }
    // Travel detection
    if (msgLower.contains('uber') || msgLower.contains('ola') || 
        msgLower.contains('train') || msgLower.contains('flight') ||
        msgLower.contains('petrol') || msgLower.contains('diesel')) {
      return 'Travel';
    }
    // Food detection
    if (msgLower.contains('zomato') || msgLower.contains('swiggy') || 
        msgLower.contains('restaurant') || msgLower.contains('cafe') ||
        msgLower.contains('food') || msgLower.contains('pizza')) {
      return 'Food';
    }
    // Shopping detection
    if (msgLower.contains('amazon') || msgLower.contains('flipkart') || 
        msgLower.contains('myntra') || msgLower.contains('shopping') ||
        msgLower.contains('mall') || msgLower.contains('store')) {
      return 'Shopping';
    }
    
    return 'Misc'; // Default category
  }

  void detectAmount() {
    final amount = extractAmount(messageController.text);
    final type = detectTransactionType(messageController.text);
    final smartCategory = smartCategoryDetection(messageController.text);
    
    setState(() {
      detectedAmount = amount;
      detectedType = type;
      selectedCategory = smartCategory;
    });
  }

  void saveExpense() {
    if (detectedAmount.isEmpty) return;
    final amt = double.tryParse(detectedAmount);
    if (amt == null || amt <= 0) return;
    
    final now = DateTime.now();
    final expense = Expense(
      amount: amt,
      category: selectedCategory,
      date: now.toIso8601String().substring(0, 10),
      time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      originalMessage: messageController.text,
      type: detectedType,
    );
    
    setState(() {
      expenses.add(expense);
      detectedAmount = '';
      messageController.clear();
    });
    saveExpenses();
    refreshSummary();
    _checkBudgetLimits(amt, now);
  }

  void _checkBudgetLimits(double amount, DateTime date) {
    if (currentBudget == null) return;
    
    // Check daily limit
    final today = date.toIso8601String().substring(0, 10);
    final dailyTotal = expenses
        .where((e) => e.date == today && e.type == 'debit')
        .fold(0.0, (sum, e) => sum + e.amount);
    
    // Check monthly limit
    final currentMonth = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    final monthlyTotal = expenses
        .where((e) => e.date.startsWith(currentMonth) && e.type == 'debit')
        .fold(0.0, (sum, e) => sum + e.amount);
    
    // Show warnings
    if (dailyTotal > currentBudget!.dailyLimit) {
      _showBudgetAlert('Daily Budget Exceeded!', 
          'You have spent ₹${dailyTotal.toStringAsFixed(2)} today, which exceeds your daily limit of ₹${currentBudget!.dailyLimit.toStringAsFixed(2)}. Your expenses are out of hands! 🚨');
    }
    
    if (monthlyTotal > currentBudget!.monthlyLimit) {
      _showBudgetAlert('Monthly Budget Exceeded!', 
          'You have spent ₹${monthlyTotal.toStringAsFixed(2)} this month, which exceeds your monthly limit of ₹${currentBudget!.monthlyLimit.toStringAsFixed(2)}. Your expenses are out of hands! 🚨');
    }
  }

  void _showBudgetAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void refreshSummary() {
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final today = now.toIso8601String().substring(0, 10);
    
    // Monthly expenses (only debits)
    final monthlyExpenses = expenses.where((e) => 
        e.date.startsWith(currentMonth) && e.type == 'debit').toList();
    final monthlyTotal = monthlyExpenses.fold(0.0, (sum, e) => sum + e.amount);
    
    // Daily expenses (only debits)
    final dailyExpenses = expenses.where((e) => 
        e.date == today && e.type == 'debit').toList();
    final dailyTotal = dailyExpenses.fold(0.0, (sum, e) => sum + e.amount);
    
    // Monthly credits
    final monthlyCredits = expenses.where((e) => 
        e.date.startsWith(currentMonth) && e.type == 'credit').toList();
    final monthlyCreditTotal = monthlyCredits.fold(0.0, (sum, e) => sum + e.amount);
    
    // Build monthly summary
    String summary = '💰 Monthly Expenses: ₹${monthlyTotal.toStringAsFixed(2)}\n';
    summary += '💳 Monthly Credits: ₹${monthlyCreditTotal.toStringAsFixed(2)}\n';
    
    if (currentBudget != null) {
      final remainingBudget = currentBudget!.monthlyLimit - monthlyTotal;
      summary += '🎯 Monthly Budget: ₹${currentBudget!.monthlyLimit.toStringAsFixed(2)}\n';
      if (remainingBudget >= 0) {
        summary += '✅ Remaining: ₹${remainingBudget.toStringAsFixed(2)}\n';
      } else {
        summary += '🚨 Over Budget: ₹${(-remainingBudget).toStringAsFixed(2)}\n';
      }
    }
    
    summary += '\n📊 Category Breakdown (Monthly):\n';
    for (var cat in categories) {
      final catTotal = monthlyExpenses.where((e) => e.category == cat).fold(0.0, (sum, e) => sum + e.amount);
      if (catTotal > 0) {
        summary += '${categoryEmojis[cat] ?? ''} $cat: ₹${catTotal.toStringAsFixed(2)}\n';
      }
    }
    
    // Build daily summary
    String dailySummary = '📅 Today\'s Expenses: ₹${dailyTotal.toStringAsFixed(2)}\n';
    if (currentBudget != null) {
      final remainingDaily = currentBudget!.dailyLimit - dailyTotal;
      dailySummary += '🎯 Daily Budget: ₹${currentBudget!.dailyLimit.toStringAsFixed(2)}\n';
      if (remainingDaily >= 0) {
        dailySummary += '✅ Remaining Today: ₹${remainingDaily.toStringAsFixed(2)}\n';
      } else {
        dailySummary += '🚨 Over Daily Budget: ₹${(-remainingDaily).toStringAsFixed(2)}\n';
      }
    }
    
    dailySummary += '\n📊 Today\'s Categories:\n';
    for (var cat in categories) {
      final catTotal = dailyExpenses.where((e) => e.category == cat).fold(0.0, (sum, e) => sum + e.amount);
      if (catTotal > 0) {
        dailySummary += '${categoryEmojis[cat] ?? ''} $cat: ₹${catTotal.toStringAsFixed(2)}\n';
      }
    }
    
    setState(() {
      summaryText = summary;
      dailySummaryText = dailySummary;
      expensesList = monthlyExpenses.map((e) =>
        '${e.date} ${e.time} - ${categoryEmojis[e.category] ?? ''} ${e.category}: ₹${e.amount} (${e.type == 'debit' ? '💸' : '💰'})'
      ).join('\n');
    });
  }

  void _updateBudget() {
    final monthlyBudget = double.tryParse(monthlyBudgetController.text);
    final dailyBudget = double.tryParse(dailyBudgetController.text);
    
    if (monthlyBudget == null || dailyBudget == null || monthlyBudget <= 0 || dailyBudget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid budget amounts')),
      );
      return;
    }
    
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    
    setState(() {
      currentBudget = Budget(
        monthlyLimit: monthlyBudget,
        dailyLimit: dailyBudget,
        month: currentMonth,
      );
    });
    
    saveBudget();
    refreshSummary();
    
    monthlyBudgetController.clear();
    dailyBudgetController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Budget updated successfully! 💰')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.amberAccent),
              SizedBox(width: 8),
              Text('Expense Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: Colors.indigo,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add Expense 📝', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: 'Paste expense message...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: detectAmount,
                              child: Text('🔍 Smart Detect'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (detectedAmount.isNotEmpty)
                                    Text(
                                      'Amount: ₹$detectedAmount',
                                      style: TextStyle(fontSize: 16, color: Colors.green[700], fontWeight: FontWeight.bold),
                                    ),
                                  if (detectedType != 'debit')
                                    Text(
                                      'Type: ${detectedType == 'credit' ? '💰 Credit' : '❓ Unknown'}',
                                      style: TextStyle(fontSize: 14, color: Colors.blue[600]),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text('Category:', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 10),
                            DropdownButton<String>(
                              value: selectedCategory,
                              items: categories.map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text('${categoryEmojis[cat] ?? ''} $cat'),
                              )).toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedCategory = val!;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: saveExpense,
                          child: Text('Save Expense'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Budget Management Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.savings, color: Colors.amber),
                            SizedBox(width: 8),
                            Text('Budget Settings 💰', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10),
                        if (currentBudget != null) ...[
                          Text('Monthly Budget: ₹${currentBudget!.monthlyLimit.toStringAsFixed(0)}'),
                          Text('Daily Budget: ₹${currentBudget!.dailyLimit.toStringAsFixed(0)}'),
                          SizedBox(height: 10),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: monthlyBudgetController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Monthly Budget',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  prefixText: '₹',
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: dailyBudgetController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Daily Budget',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  prefixText: '₹',
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _updateBudget,
                          child: Text('Update Budget'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Daily Summary Card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.today, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Today\'s Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(dailySummaryText, style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.pie_chart, color: Colors.indigo),
                            SizedBox(width: 8),
                            Text('Monthly Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(summaryText, style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.list_alt, color: Colors.indigo),
                            SizedBox(width: 8),
                            Text('Expenses (This Month):', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10),
                        ...expenses.where((e) => e.date.startsWith('${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}')).map((e) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: e.type == 'debit' ? Colors.red[100] : Colors.green[100],
                            child: Text(
                              e.type == 'debit' ? '💸' : (e.type == 'credit' ? '💰' : '❓'),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          title: Text('${categoryEmojis[e.category] ?? ''} ${e.category}'),
                          subtitle: Text('${e.date} at ${e.time}'),
                          trailing: Text(
                            '₹${e.amount}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: e.type == 'debit' ? Colors.red : Colors.green,
                            ),
                          ),
                        )).toList(),
                        if (expenses.where((e) => e.date.startsWith('${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}')).isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No expenses added yet!', style: TextStyle(color: Colors.grey)),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(ExpenseTrackerApp());
}
