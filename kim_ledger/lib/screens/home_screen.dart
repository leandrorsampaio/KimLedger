// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is first created
    Provider.of<DataProvider>(context, listen: false).fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KimLedger'),
        backgroundColor: Colors.teal,
      ),
      // Use a Consumer to listen for changes in DataProvider
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          if (dataProvider.expenses.isEmpty) {
            return const Center(child: Text('No expenses yet. Add one!'));
          }
          // Display expenses in a list
          return ListView.builder(
            itemCount: dataProvider.expenses.length,
            itemBuilder: (context, index) {
              final expense = dataProvider.expenses[index];
              return ListTile(
                title: Text(expense.description),
                subtitle: Text('${expense.categoryName} - ${expense.date}'),
                trailing: Text(
                  '€${expense.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: expense.value < 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to the 'Add Expense' screen
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
