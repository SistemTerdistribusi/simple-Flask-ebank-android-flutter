import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const BankingApp());
}

class BankingApp extends StatelessWidget {
  const BankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banking App',
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
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
    const TransferScreen(),
    const AccountInfoScreen(),
    const InputBalanceScreen(),
    const TransactionScreen(),
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
        unselectedItemColor: Colors.grey, // Change unselected item color
        onTap: _onItemTapped,
      ),
    );
  }
}

class InputBalanceScreen extends StatefulWidget {
  const InputBalanceScreen({super.key});

  @override
  _InputBalanceScreenState createState() => _InputBalanceScreenState();
}

class _InputBalanceScreenState extends State<InputBalanceScreen> {
  List<dynamic> accounts = [];
  List<String> accountTypes = ['Savings', 'Checking'];
  List<String> currencies = ['IDR', 'USD'];
  String? selectedAccount;
  String? selectedAccountType;
  String? selectedCurrency;
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    final url = Uri.parse('https://ebank.honjo.web.id/api/saldo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        accounts = data['accounts'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load accounts')));
    }
  }

  Future<void> submitBalance() async {
    // Validate inputs
    if (selectedAccount == null ||
        selectedAccountType == null ||
        selectedCurrency == null ||
        amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    final url = Uri.parse('http://103.47.225.247:5001/api/input_saldo');

    final requestBody = jsonEncode({
      'account_number': selectedAccount,
      'account_type': selectedAccountType,
      'currency_code': selectedCurrency,
      'available_balance': amountController.text,
    });

    print('--- Request Details ---');
    print('Request URL: $url');
    print('Request Headers: {Content-Type: application/json}');
    print('Request Body: $requestBody');
    print('----------------------');

    try {
      // Send the POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      // Log the response status code and body
      print('--- Response Details ---');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('------------------------');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Balance added successfully. New balance: ${responseData['data']['new_balance']}')));
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Failed to add balance';
        } catch (e) {
          errorMessage =
              'Failed to add balance. Status code: ${response.statusCode}';
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An error occurred while adding balance')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedAccount,
            items: accounts.map((account) {
              return DropdownMenuItem<String>(
                value: account['account_number'],
                child: Text(
                  account['account_name'] ?? 'Unnamed Account',
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedAccount = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Select Account',
              labelStyle: TextStyle(
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black), // Dynamic label color
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDarkMode
                        ? Colors.grey
                        : Colors.black), // Dynamic border color
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.blue), // Focused border color
              ),
            ),
            dropdownColor: isDarkMode
                ? Colors.black87
                : Colors.white, // Dynamic dropdown background
            style: TextStyle(
                color: isDarkMode
                    ? Colors.white
                    : Colors.black), // Dynamic text color
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedAccountType,
            items: accountTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type,
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedAccountType = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Select Account Type',
              labelStyle: TextStyle(
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black), // Dynamic label color
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDarkMode
                        ? Colors.grey
                        : Colors.black), // Dynamic border color
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.blue), // Focused border color
              ),
            ),
            dropdownColor: isDarkMode
                ? Colors.black87
                : Colors.white, // Dynamic dropdown background
            style: TextStyle(
                color: isDarkMode
                    ? Colors.white
                    : Colors.black), // Dynamic text color
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedCurrency,
            items: currencies.map((currency) {
              return DropdownMenuItem<String>(
                value: currency,
                child: Text(
                  currency,
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCurrency = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Select Currency',
              labelStyle: TextStyle(
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black), // Dynamic label color
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDarkMode
                        ? Colors.grey
                        : Colors.black), // Dynamic border color
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.blue), // Focused border color
              ),
            ),
            dropdownColor: isDarkMode
                ? Colors.black87
                : Colors.white, // Dynamic dropdown background
            style: TextStyle(
                color: isDarkMode
                    ? Colors.white
                    : Colors.black), // Dynamic text color
          ),
          const SizedBox(height: 10),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Enter Amount'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: submitBalance,
            child: const Text('Add Balance'),
          ),
        ],
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
    final url = Uri.parse('https://ebank.honjo.web.id/api/transfer');
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
    final url = Uri.parse('https://ebank.honjo.web.id/api/saldo');
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
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
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
                      subtitle:
                          Text('Balance: ${account['available_balance']}'),
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

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late Future<List<Map<String, dynamic>>> transactionsFuture;
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> filteredTransactions = [];
  String searchQuery = '';
  bool ascending = true;

  @override
  void initState() {
    super.initState();
    transactionsFuture = fetchTransactions();
  }

  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final url = Uri.parse('https://ebank.honjo.web.id/api/saldo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        transactions = List<Map<String, dynamic>>.from(data['transactions']);
        filteredTransactions = transactions;
      });
      return transactions;
    } else {
      print(
          'Failed to load transactions: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load transactions');
    }
  }

  void filterTransactions(String query) {
    setState(() {
      searchQuery = query;
      filteredTransactions = transactions.where((transaction) {
        final description = transaction['description'].toString().toLowerCase();
        return description.contains(query.toLowerCase());
      }).toList();
    });
  }

  void sortTransactions() {
    setState(() {
      ascending = !ascending;
      filteredTransactions.sort((a, b) {
        final aDate = DateTime.parse(a['transaction_date']);
        final bDate = DateTime.parse(b['transaction_date']);
        return ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: sortTransactions,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterTransactions,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final limitedTransactions =
                      filteredTransactions.take(10).toList();
                  return ListView.builder(
                    itemCount: limitedTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = limitedTransactions[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: const Icon(Icons.attach_money),
                          title: Text(transaction['description']),
                          subtitle: Text(
                              'Amount: ${transaction['transaction_amount']} - Date: ${transaction['transaction_date']}'),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// AccountInfoScreen and TransactionScreen can remain the same as in your original code
