import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final String tripId;
  final String userId;
  final double totalBudget;
  final String currency;
  final Map<String, double> categoryBudgets;
  final List<Expense> expenses;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Budget({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.totalBudget,
    required this.currency,
    required this.categoryBudgets,
    required this.expenses,
    required this.createdAt,
    this.updatedAt,
  });

  factory Budget.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Budget(
      id: doc.id,
      tripId: data['tripId'],
      userId: data['userId'],
      totalBudget: (data['totalBudget'] as num).toDouble(),
      currency: data['currency'],
      categoryBudgets: Map<String, double>.from(data['categoryBudgets']),
      expenses: (data['expenses'] as List)
          .map((e) => Expense.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tripId': tripId,
      'userId': userId,
      'totalBudget': totalBudget,
      'currency': currency,
      'categoryBudgets': categoryBudgets,
      'expenses': expenses.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  double getTotalExpenses() {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  double getRemainingBudget() {
    return totalBudget - getTotalExpenses();
  }

  Map<String, double> getCategoryExpenses() {
    final categoryExpenses = <String, double>{};
    for (var expense in expenses) {
      categoryExpenses[expense.category] =
          (categoryExpenses[expense.category] ?? 0) + expense.amount;
    }
    return categoryExpenses;
  }

  Map<String, double> getCategoryRemaining() {
    final categoryExpenses = getCategoryExpenses();
    final remaining = <String, double>{};
    categoryBudgets.forEach((category, budget) {
      remaining[category] = budget - (categoryExpenses[category] ?? 0);
    });
    return remaining;
  }

  double getPercentageSpent() {
    return (getTotalExpenses() / totalBudget) * 100;
  }

  Budget copyWith({
    String? id,
    String? tripId,
    String? userId,
    double? totalBudget,
    String? currency,
    Map<String, double>? categoryBudgets,
    List<Expense>? expenses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      userId: userId ?? this.userId,
      totalBudget: totalBudget ?? this.totalBudget,
      currency: currency ?? this.currency,
      categoryBudgets:
          categoryBudgets ?? Map<String, double>.from(this.categoryBudgets),
      expenses: expenses ?? List<Expense>.from(this.expenses),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Expense {
  final String id;
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final String? receipt;
  final Map<String, dynamic>? metadata;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    this.receipt,
    this.metadata,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      description: map['description'],
      date: (map['date'] as Timestamp).toDate(),
      receipt: map['receipt'],
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'receipt': receipt,
      'metadata': metadata,
    };
  }
}
