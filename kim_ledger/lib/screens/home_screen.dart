// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/data_provider.dart';
import '../models/expense.dart';
import '../models/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  Category? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is first created
    Provider.of<DataProvider>(context, listen: false).fetchData();
    // Set current date as default
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  double _parseValue(String input) {
    final trimmedInput = input.trim();
    
    // If starts with +, remove it and return positive value
    if (trimmedInput.startsWith('+')) {
      return double.parse(trimmedInput.substring(1));
    }
    
    // If starts with -, parse as negative
    if (trimmedInput.startsWith('-')) {
      return double.parse(trimmedInput);
    }
    
    // If no sign, treat as negative (expense)
    return -double.parse(trimmedInput);
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final expense = Expense(
          description: _descriptionController.text.trim(),
          value: _parseValue(_valueController.text.trim()),
          user: 'Leandro', // You can make this dynamic later
          date: DateTime.parse(_dateController.text).toIso8601String(),
          categoryId: _selectedCategory!.id!,
        );

        await Provider.of<DataProvider>(context, listen: false).addExpense(expense);

        // Clear form after successful save
        _descriptionController.clear();
        _valueController.clear();
        _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
        setState(() {
          _selectedCategory = null;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense added successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding expense: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KimLedger'),
        backgroundColor: Colors.teal,
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add Expense Form
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add New Expense',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Date Field
                          TextFormField(
                            controller: _dateController,
                            decoration: InputDecoration(
                              labelText: 'Date *',
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.date_range),
                                onPressed: () => _selectDate(context),
                              ),
                            ),
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a date';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Description Field
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description *',
                              prefixIcon: Icon(Icons.description),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Value Field
                          TextFormField(
                            controller: _valueController,
                            decoration: const InputDecoration(
                              labelText: 'Value *',
                              prefixIcon: Icon(Icons.euro),
                              border: OutlineInputBorder(),
                              helperText: 'Default: expense (negative). Use +33.35 for income',
                              helperMaxLines: 2,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a value';
                              }
                              
                              final trimmedValue = value.trim();
                              String numberPart = trimmedValue;
                              
                              // Remove + or - for validation
                              if (trimmedValue.startsWith('+') || trimmedValue.startsWith('-')) {
                                numberPart = trimmedValue.substring(1);
                              }
                              
                              if (double.tryParse(numberPart) == null) {
                                return 'Please enter a valid number';
                              }
                              
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Category Dropdown
                          DropdownButtonFormField<Category>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category *',
                              prefixIcon: Icon(Icons.category),
                              border: OutlineInputBorder(),
                            ),
                            items: dataProvider.categories.map((Category category) {
                              return DropdownMenuItem<Category>(
                                value: category,
                                child: Text(category.name),
                              );
                            }).toList(),
                            onChanged: (Category? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveExpense,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Save Expense',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Expenses List
                const Text(
                  'Recent Expenses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                
                if (dataProvider.expenses.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No expenses yet. Add one using the form above!',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dataProvider.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = dataProvider.expenses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: expense.value < 0 
                                ? Colors.red.withOpacity(0.1) 
                                : Colors.green.withOpacity(0.1),
                            child: Icon(
                              expense.value < 0 ? Icons.remove : Icons.add,
                              color: expense.value < 0 ? Colors.red : Colors.green,
                            ),
                          ),
                          title: Text(
                            expense.description,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '${expense.categoryName} • ${DateFormat('dd/MM/yyyy').format(DateTime.parse(expense.date))}',
                          ),
                          trailing: Text(
                            '€${expense.value.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: expense.value < 0 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
