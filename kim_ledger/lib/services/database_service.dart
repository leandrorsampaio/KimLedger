// lib/services/database_service.dart

import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/expense.dart';

class DatabaseService {
  // Singleton pattern ensures we only have one instance of this service.
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  /// Public getter for the database instance.
  /// Initializes the database if it hasn't been already.
  Future<Database> get database async {
    if (_database != null) return _database!;
    // IMPORTANT: Replace with a secure way to get the password from the user.
    _database = await _initDB('finances.db', 'your-super-secret-password');
    return _database!;
  }

  /// Initializes the encrypted SQLite database.
  Future<Database> _initDB(String filePath, String password) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      password: password,
      onCreate: _createDB,
    );
  }

  /// Creates the necessary tables on database creation.
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        value REAL NOT NULL,
        user TEXT NOT NULL,
        date TEXT NOT NULL,
        category_id INTEGER,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
    // Add dummy data after creating tables
    await _addDummyData(db);
  }

  /// Adds some initial data for demonstration purposes.
  Future<void> _addDummyData(Database db) async {
    // Add some categories
    await db.insert('categories', {'name': 'Groceries'});
    await db.insert('categories', {'name': 'Utilities'});
    await db.insert('categories', {'name': 'Transport'});
    await db.insert('categories', {'name': 'Entertainment'});

    // Add some expenses
    await db.insert('expenses', {
      'description': 'Weekly groceries',
      'value': 150.75,
      'user': 'Leandro',
      'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'category_id': 1
    });
    await db.insert('expenses', {
      'description': 'Electricity bill',
      'value': 75.50,
      'user': 'Leandro',
      'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'category_id': 2
    });
    await db.insert('expenses', {
      'description': 'Train ticket',
      'value': 22.00,
      'user': 'Leandro',
      'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'category_id': 3
    });
    await db.insert('expenses', {
      'description': 'Movie night',
      'value': 45.00,
      'user': 'Leandro',
      'date': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      'category_id': 4
    });
  }

  // --- Category Operations ---

  Future<void> addCategory(Category category) async {
    final db = await instance.database;
    await db.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Category>> getCategories() async {
    final db = await instance.database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  // --- Expense Operations ---

  Future<void> addExpense(Expense expense) async {
    final db = await instance.database;
    await db.insert('expenses', expense.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Expense>> getExpenses() async {
    final db = await instance.database;
    // Use a rawQuery with a JOIN to fetch the category name along with the expense data.
    final result = await db.rawQuery('''
      SELECT e.*, c.name as categoryName 
      FROM expenses e
      JOIN categories c ON e.category_id = c.id
      ORDER BY e.date DESC
    ''');
    return result.isNotEmpty ? result.map((json) => Expense.fromMap(json)).toList() : [];
  }

  /// Closes the database connection.
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  /// Deletes the database file.
  Future<void> deleteDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finances.db');
    await deleteDatabase(path);
    _database = null; // Reset the database instance
  }
}
