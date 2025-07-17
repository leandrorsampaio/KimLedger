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
    _expenses = await _databaseService.getExpenses();
    _categories = await _databaseService.getCategories();
    notifyListeners(); // This tells the UI to rebuild
  }
}
