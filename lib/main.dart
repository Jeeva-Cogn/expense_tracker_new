import 'package:flutter/material.dart';

// Removed telephony SMS logic; working with user inputs only

// Model for transactions entered by user
class Transaction {
  final String description;
  final DateTime date;
  final double amount;
  final bool isCredit;
  Transaction({required this.description, required this.date, required this.amount, required this.isCredit});
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Transaction> _transactions = [];
  // Show input dialog for new transaction
  void _showAddDialog() {
    final _formKey = GlobalKey<FormState>();
    String desc = '';
    double? amt;
    bool credit = true;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Transaction'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (v) => desc = v ?? '',
                validator: (v) => v == null || v.isEmpty ? 'Enter description' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onSaved: (v) => amt = double.tryParse(v ?? ''),
                validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid amount' : null,
              ),
              DropdownButtonFormField<bool>(
                value: credit,
                items: const [
                  DropdownMenuItem(value: true, child: Text('Credit')),
                  DropdownMenuItem(value: false, child: Text('Debit')),
                ],
                onChanged: (v) => credit = v ?? true,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState!.save();
                setState(() {
                  _transactions.add(Transaction(
                    description: desc,
                    date: DateTime.now(),
                    amount: amt!,
                    isCredit: credit,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [Tab(text: 'Credits'), Tab(text: 'Debits')],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(true),
            _buildList(false),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddDialog,
          tooltip: 'Add',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildList(bool creditTab) {
    final items = _transactions.where((t) => t.isCredit == creditTab).toList();
    if (items.isEmpty) {
      return Center(child: Text(creditTab ? 'No credits' : 'No debits'));
    }
    final totalAmount = items.fold<double>(
      0,
      (sum, item) => sum + (creditTab ? item.amount : -item.amount),
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Total: ${totalAmount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final tx = items[index];
              return ListTile(
                title: Text(tx.description),
                subtitle: Text(tx.date.toLocal().toString()),
                trailing: Text(
                  tx.amount.toStringAsFixed(2),
                  style: TextStyle(color: creditTab ? Colors.green : Colors.red),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
