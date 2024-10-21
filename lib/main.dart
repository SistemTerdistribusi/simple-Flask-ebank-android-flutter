import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(BankingApp());
}

class BankingApp extends StatelessWidget {
  const BankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    TransferScreen(),
    AccountInfoScreen(),
    InputBalanceScreen(),
    TransactionScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banking App'),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.transfer_within_a_station),
            label: 'Transfer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Account Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.input),
            label: 'Input Balance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController accountController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  Future<void> transferFunds() async {
    final url = Uri.parse('http://ebank.honjo.web.id/api/transfer');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'account_number': accountController.text,
        'amount': amountController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Transfer successful')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Transfer failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: accountController,
            decoration: const InputDecoration(labelText: 'Account Number'),
          ),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: transferFunds,
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }
}

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  Future<Map<String, dynamic>> fetchAccountInfo() async {
    final url = Uri.parse('http://ebank.honjo.web.id/api/saldo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(
          'Failed to load account info: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load account info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchAccountInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final accountData = snapshot.data!['accounts'];
          final customerName = snapshot.data!['customer_name'];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Welcome, $customerName',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: accountData.length,
                  itemBuilder: (context, index) {
                    final account = accountData[index];
                    return ListTile(
                      title: Text(account['account_name'] ??
                          'Unnamed Account'), // Handle null value
                      subtitle: Text('Balance: ${account['available_balance']}'),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class InputBalanceScreen extends StatelessWidget {
  const InputBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Input Balance Screen'),
    );
  }
}

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  Future<Map<String, dynamic>> fetchTransactions() async {
    final url = Uri.parse('http://ebank.honjo.web.id/api/saldo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(
          'Failed to load transactions: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load transactions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final transactions = snapshot.data!['transactions'];
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return ListTile(
                title: Text(transaction['description']),
                subtitle: Text(
                    'Amount: ${transaction['transaction_amount']} - Date: ${transaction['transaction_date']}'),
              );
            },
          );
        }
      },
    );
  }
}
