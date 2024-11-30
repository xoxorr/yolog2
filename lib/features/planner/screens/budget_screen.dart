import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';

class BudgetScreen extends StatefulWidget {
  final String tripId;

  const BudgetScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final BudgetService _budgetService = BudgetService();
  Budget? _budget;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    setState(() => _isLoading = true);
    try {
      final budget = await _budgetService.getBudgetForTrip(widget.tripId);
      setState(() {
        _budget = budget;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_budget == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('예산 관리')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('예산이 설정되지 않았습니다.'),
              ElevatedButton(
                onPressed: () => _showAddBudgetDialog(context),
                child: const Text('예산 설정하기'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('예산 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddExpenseDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBudget,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBudgetSummary(),
                const SizedBox(height: 24),
                _buildCategoryBreakdown(),
                const SizedBox(height: 24),
                _buildExpensesList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSummary() {
    final currencyFormat = NumberFormat.currency(
      symbol: _budget!.currency,
      decimalDigits: 0,
    );
    final percentageSpent = _budget!.getPercentageSpent();
    final remainingBudget = _budget!.getRemainingBudget();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '예산 현황',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentageSpent / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentageSpent > 90 ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBudgetInfoItem(
                  '총 예산',
                  currencyFormat.format(_budget!.totalBudget),
                  Colors.blue,
                ),
                _buildBudgetInfoItem(
                  '사용 금액',
                  currencyFormat.format(_budget!.getTotalExpenses()),
                  Colors.orange,
                ),
                _buildBudgetInfoItem(
                  '남은 금액',
                  currencyFormat.format(remainingBudget),
                  remainingBudget < 0 ? Colors.red : Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetInfoItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown() {
    final categoryExpenses = _budget!.getCategoryExpenses();
    final categoryBudgets = _budget!.categoryBudgets;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '카테고리별 지출',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...categoryBudgets.entries.map((entry) {
              final category = entry.key;
              final budgetAmount = entry.value;
              final spentAmount = categoryExpenses[category] ?? 0;
              final percentage = (spentAmount / budgetAmount) * 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(category),
                        Text(
                          '${spentAmount.toStringAsFixed(0)} / ${budgetAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage > 90 ? Colors.red : Colors.blue,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList() {
    final dateFormat = DateFormat('MM/dd');
    final currencyFormat = NumberFormat.currency(
      symbol: _budget!.currency,
      decimalDigits: 0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '지출 내역',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _budget!.expenses.length,
              itemBuilder: (context, index) {
                final expense = _budget!.expenses[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(expense.category[0]),
                  ),
                  title: Text(expense.description),
                  subtitle: Text(expense.category),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(expense.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateFormat.format(expense.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _showExpenseDetails(context, expense),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    // Implement add budget dialog
  }

  void _showAddExpenseDialog(BuildContext context) {
    // Implement add expense dialog
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
    // Implement expense details dialog
  }
}
