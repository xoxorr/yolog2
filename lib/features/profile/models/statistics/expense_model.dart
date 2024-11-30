import 'package:cloud_firestore/cloud_firestore.dart';

class TravelExpense {
  final String id;
  final String userId;
  final Map<String, double> categoryExpenses; // 예: {'숙박': 500000, '식비': 300000}
  final Map<String, double>
      monthlyExpenses; // 예: {'2024-01': 800000, '2024-02': 600000}
  final Map<String, double> countryExpenses; // 예: {'일본': 1500000, '태국': 800000}
  final double totalExpense;
  final String defaultCurrency;
  final DateTime lastUpdated;

  TravelExpense({
    required this.id,
    required this.userId,
    required this.categoryExpenses,
    required this.monthlyExpenses,
    required this.countryExpenses,
    required this.totalExpense,
    required this.defaultCurrency,
    required this.lastUpdated,
  });

  factory TravelExpense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TravelExpense(
      id: doc.id,
      userId: data['userId'],
      categoryExpenses: Map<String, double>.from(data['categoryExpenses']),
      monthlyExpenses: Map<String, double>.from(data['monthlyExpenses']),
      countryExpenses: Map<String, double>.from(data['countryExpenses']),
      totalExpense: data['totalExpense'].toDouble(),
      defaultCurrency: data['defaultCurrency'],
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'categoryExpenses': categoryExpenses,
      'monthlyExpenses': monthlyExpenses,
      'countryExpenses': countryExpenses,
      'totalExpense': totalExpense,
      'defaultCurrency': defaultCurrency,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  String get highestExpenseCategory {
    return categoryExpenses.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String get mostExpensiveCountry {
    return countryExpenses.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  double get averageMonthlyExpense {
    if (monthlyExpenses.isEmpty) return 0;
    final total = monthlyExpenses.values.reduce((a, b) => a + b);
    return total / monthlyExpenses.length;
  }

  Map<String, double> get categoryPercentages {
    final Map<String, double> percentages = {};
    categoryExpenses.forEach((category, amount) {
      percentages[category] = (amount / totalExpense) * 100;
    });
    return percentages;
  }
}
