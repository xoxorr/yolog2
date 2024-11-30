import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';

class BudgetService {
  final FirebaseFirestore _firestore;
  final String _collection = 'budgets';

  BudgetService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Create a new budget
  Future<Budget> createBudget(Budget budget) async {
    final docRef =
        await _firestore.collection(_collection).add(budget.toFirestore());
    return budget.copyWith(id: docRef.id);
  }

  // Get a budget by ID
  Future<Budget?> getBudget(String budgetId) async {
    final doc = await _firestore.collection(_collection).doc(budgetId).get();
    return doc.exists ? Budget.fromFirestore(doc) : null;
  }

  // Get budget for a trip
  Future<Budget?> getBudgetForTrip(String tripId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('tripId', isEqualTo: tripId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty
        ? Budget.fromFirestore(snapshot.docs.first)
        : null;
  }

  // Update a budget
  Future<void> updateBudget(String budgetId, Budget budget) async {
    await _firestore
        .collection(_collection)
        .doc(budgetId)
        .update(budget.toFirestore());
  }

  // Delete a budget
  Future<void> deleteBudget(String budgetId) async {
    await _firestore.collection(_collection).doc(budgetId).delete();
  }

  // Add an expense
  Future<void> addExpense(String budgetId, Expense expense) async {
    final budget = await getBudget(budgetId);
    if (budget != null) {
      final updatedExpenses = [...budget.expenses, expense];
      await updateBudget(
          budgetId, budget.copyWith(expenses: updatedExpenses));
    }
  }

  // Remove an expense
  Future<void> removeExpense(String budgetId, String expenseId) async {
    final budget = await getBudget(budgetId);
    if (budget != null) {
      final updatedExpenses =
          budget.expenses.where((e) => e.id != expenseId).toList();
      await updateBudget(
          budgetId, budget.copyWith(expenses: updatedExpenses));
    }
  }

  // Update an expense
  Future<void> updateExpense(
      String budgetId, String expenseId, Expense updatedExpense) async {
    final budget = await getBudget(budgetId);
    if (budget != null) {
      final updatedExpenses = budget.expenses.map((e) {
        return e.id == expenseId ? updatedExpense : e;
      }).toList();
      await updateBudget(
          budgetId, budget.copyWith(expenses: updatedExpenses));
    }
  }

  // Get expenses by category
  Future<Map<String, List<Expense>>> getExpensesByCategory(
      String budgetId) async {
    final budget = await getBudget(budgetId);
    if (budget == null) return {};

    final expensesByCategory = <String, List<Expense>>{};
    for (var expense in budget.expenses) {
      if (!expensesByCategory.containsKey(expense.category)) {
        expensesByCategory[expense.category] = [];
      }
      expensesByCategory[expense.category]!.add(expense);
    }
    return expensesByCategory;
  }

  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(
      String budgetId, DateTime startDate, DateTime endDate) async {
    final budget = await getBudget(budgetId);
    if (budget == null) return [];

    return budget.expenses.where((expense) {
      return expense.date.isAfter(startDate) &&
          expense.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Get budget summary
  Future<Map<String, dynamic>> getBudgetSummary(String budgetId) async {
    final budget = await getBudget(budgetId);
    if (budget == null) return {};

    final totalExpenses = budget.getTotalExpenses();
    final remainingBudget = budget.getRemainingBudget();
    final categoryExpenses = budget.getCategoryExpenses();
    final categoryRemaining = budget.getCategoryRemaining();
    final percentageSpent = budget.getPercentageSpent();

    return {
      'totalBudget': budget.totalBudget,
      'totalExpenses': totalExpenses,
      'remainingBudget': remainingBudget,
      'percentageSpent': percentageSpent,
      'categoryExpenses': categoryExpenses,
      'categoryRemaining': categoryRemaining,
      'currency': budget.currency,
    };
  }

  // Get budget statistics
  Future<Map<String, dynamic>> getBudgetStatistics(String userId) async {
    final budgets = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();

    final budgetList =
        budgets.docs.map((doc) => Budget.fromFirestore(doc)).toList();

    double totalBudget = 0;
    double totalExpenses = 0;
    Map<String, double> categoryTotals = {};

    for (var budget in budgetList) {
      totalBudget += budget.totalBudget;
      totalExpenses += budget.getTotalExpenses();

      budget.getCategoryExpenses().forEach((category, amount) {
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      });
    }

    return {
      'totalBudgets': budgetList.length,
      'totalBudgetAmount': totalBudget,
      'totalExpenses': totalExpenses,
      'averageExpensePerBudget': budgetList.isEmpty
          ? 0
          : totalExpenses / budgetList.length,
      'categoryTotals': categoryTotals,
      'mostExpensiveCategory': categoryTotals.isEmpty
          ? null
          : categoryTotals.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key,
    };
  }
}
