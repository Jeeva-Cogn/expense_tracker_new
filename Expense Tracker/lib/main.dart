import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

const List<String> categories = [
  'Misc', 'EMI', 'Groceries', 'Bills', 'Shopping', 'Travel', 'Food', 'Other'
];

class Expense {
  final double amount;
  final String category;
  final String date;

  Expense({required this.amount, required this.category, required this.date});

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'category': category,
    'date': date,
  };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      amount: json['amount'],
      category: json['category'],
      date: json['date'],
    );
  }
}

class ExpenseTrackerApp extends StatefulWidget {
  @override
  _ExpenseTrackerAppState createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  final TextEditingController messageController = TextEditingController();
  String detectedAmount = '';
  String selectedCategory = categories[0];
  List<Expense> expenses = [];
  String summaryText = '';
  String expensesList = '';
  // Removed categoryIcons, only using emojis now.
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
    refreshSummary();
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

  void detectAmount() {
    setState(() {
      detectedAmount = extractAmount(messageController.text);
    });
  }

  void saveExpense() {
    if (detectedAmount.isEmpty) return;
    final amt = double.tryParse(detectedAmount);
    if (amt == null || amt <= 0) return;
    final expense = Expense(
      amount: amt,
      category: selectedCategory,
      date: DateTime.now().toIso8601String().substring(0, 10),
    );
    setState(() {
      expenses.add(expense);
      detectedAmount = '';
      messageController.clear();
    });
    saveExpenses();
    refreshSummary();
  }

  void refreshSummary() {
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final monthlyExpenses = expenses.where((e) => e.date.startsWith(currentMonth)).toList();
    final total = monthlyExpenses.fold(0.0, (sum, e) => sum + e.amount);
    String summary = '💰 Total Expenses (This Month): ₹${total.toStringAsFixed(2)}\n';
    for (var cat in categories) {
      final catTotal = monthlyExpenses.where((e) => e.category == cat).fold(0.0, (sum, e) => sum + e.amount);
      summary += '${categoryEmojis[cat] ?? ''} $cat: ₹${catTotal.toStringAsFixed(2)}\n';
    }
    setState(() {
      summaryText = summary;
      expensesList = monthlyExpenses.map((e) =>
        '${e.date} - ${categoryEmojis[e.category] ?? ''} ${e.category}: ₹${e.amount}'
      ).join('\n');
    });
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
                              child: Text('Detect Amount'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                            ),
                            SizedBox(width: 16),
                            Text(
                              detectedAmount.isNotEmpty ? 'Detected: ₹$detectedAmount' : '',
                              style: TextStyle(fontSize: 16, color: Colors.green[700], fontWeight: FontWeight.bold),
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
                            Text('Category Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                            backgroundColor: Colors.indigo[100],
                            child: Text(categoryEmojis[e.category] ?? '', style: TextStyle(fontSize: 20)),
                          ),
                          title: Text('${e.category}'),
                          subtitle: Text('${e.date}'),
                          trailing: Text('₹${e.amount}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
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
