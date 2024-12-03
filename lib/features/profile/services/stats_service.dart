import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/statistics/travel_stats_model.dart';
import '../models/statistics/expense_model.dart';

class StatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 여행 통계 관련 메서드
  Future<TravelStats?> getTravelStats(String userId) async {
    final doc = await _firestore
        .collection('travelStats')
        .where('userId', isEqualTo: userId)
        .get();

    if (doc.docs.isEmpty) return null;
    return TravelStats.fromFirestore(doc.docs.first);
  }

  Future<void> updateTravelStats(TravelStats stats) async {
    await _firestore
        .collection('travelStats')
        .doc(stats.id)
        .set(stats.toFirestore());
  }

  // 지출 통계 관련 메서드
  Future<TravelExpense?> getTravelExpense(String userId) async {
    final doc = await _firestore
        .collection('travelExpenses')
        .where('userId', isEqualTo: userId)
        .get();

    if (doc.docs.isEmpty) return null;
    return TravelExpense.fromFirestore(doc.docs.first);
  }

  Future<void> updateTravelExpense(TravelExpense expense) async {
    await _firestore
        .collection('travelExpenses')
        .doc(expense.id)
        .set(expense.toFirestore());
  }

  // 통계 분석 메서드
  Future<Map<String, double>> getMonthlyTrends(String userId) async {
    final expense = await getTravelExpense(userId);
    if (expense == null) return {};

    return expense.monthlyExpenses;
  }

  Future<Map<String, double>> getExpenseBreakdown(String userId) async {
    final expense = await getTravelExpense(userId);
    if (expense == null) return {};

    return expense.categoryPercentages;
  }

  Future<Map<String, dynamic>> getYearlyComparison(String userId) async {
    final expense = await getTravelExpense(userId);
    if (expense == null) return {};

    final Map<String, double> yearlyTotals = {};
    expense.monthlyExpenses.forEach((month, amount) {
      final year = month.split('-')[0];
      yearlyTotals[year] = (yearlyTotals[year] ?? 0) + amount;
    });

    return {
      'totals': yearlyTotals,
      'yearOverYearGrowth': _calculateYearOverYearGrowth(yearlyTotals),
    };
  }

  Map<String, double> _calculateYearOverYearGrowth(
      Map<String, double> yearlyTotals) {
    final Map<String, double> growth = {};
    final years = yearlyTotals.keys.toList()..sort();

    for (var i = 1; i < years.length; i++) {
      final currentYear = years[i];
      final previousYear = years[i - 1];
      final currentAmount = yearlyTotals[currentYear]!;
      final previousAmount = yearlyTotals[previousYear]!;

      growth[currentYear] =
          ((currentAmount - previousAmount) / previousAmount) * 100;
    }

    return growth;
  }

  Future<Map<String, dynamic>> getDestinationInsights(String userId) async {
    final stats = await getTravelStats(userId);
    if (stats == null) return {};

    final expense = await getTravelExpense(userId);
    if (expense == null) return {};

    return {
      'popularDestinations': stats.destinationTypes,
      'expensiveDestinations': expense.countryExpenses,
      'averageCostPerDestination': _calculateAverageCostPerDestination(
        expense.countryExpenses,
        stats.destinationTypes,
      ),
    };
  }

  Map<String, double> _calculateAverageCostPerDestination(
      Map<String, double> expenses, Map<String, int> visitCounts) {
    final Map<String, double> averages = {};

    expenses.forEach((country, totalExpense) {
      final visitCount = visitCounts[country] ?? 1;
      averages[country] = totalExpense / visitCount;
    });

    return averages;
  }
}
