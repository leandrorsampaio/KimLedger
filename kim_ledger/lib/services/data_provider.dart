// lib/services/data_provider.dart

import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';
import '../models/expense.dart';
import 'database_service.dart';

class DataProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<Category> _categories = [];

  List<Expense> get expenses => _expenses;
  List<Category> get categories => _categories;

  final DatabaseService _databaseService = DatabaseService.instance;

  // Fetches all data from the database and notifies listeners
  Future<void> fetchData() async {
    try {
      print('DataProvider: Fetching data...'); // Debug log
      _expenses = await _databaseService.getExpenses();
      _categories = await _databaseService.getCategories();
      print('DataProvider: Fetched ${_expenses.length} expenses and ${_categories.length} categories'); // Debug log
      notifyListeners(); // This tells the UI to rebuild
    } catch (e) {
      print('DataProvider: Error fetching data: $e'); // Debug log
    }
  }

  // Adds a new expense to the database and updates the UI
  Future<void> addExpense(Expense expense) async {
    try {
      print('DataProvider: Adding expense...'); // Debug log
      await _databaseService.addExpense(expense);
      print('DataProvider: Expense added, refreshing data...'); // Debug log
      await fetchData(); // Refresh the data after adding
      print('DataProvider: Data refreshed'); // Debug log
    } catch (e) {
      print('DataProvider: Error adding expense: $e'); // Debug log
      rethrow;
    }
  }
}
