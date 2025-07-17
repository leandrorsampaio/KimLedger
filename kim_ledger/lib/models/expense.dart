// lib/models/expense.dart
class Expense {
  final int? id;
  final String description;
  final double value;
  final String user;
  final String date;
  final int categoryId;
  final String? categoryName; // This is used for JOIN results

  Expense({
    this.id,
    required this.description,
    required this.value,
    required this.user,
    required this.date,
    required this.categoryId,
    this.categoryName,
  });

  /// Converts an Expense object into a Map object for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'value': value,
      'user': user,
      'date': date,
      'category_id': categoryId,
    };
  }

  /// Creates an Expense object from a Map object from the database.
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description: map['description'],
      value: map['value'],
      user: map['user'],
      date: map['date'],
      categoryId: map['category_id'],
      categoryName: map['categoryName'],
    );
  }
}
