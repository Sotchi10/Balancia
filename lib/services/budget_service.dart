import '../models/budget.dart';
import '../models/category.dart';
import 'transaction_service.dart';

class BudgetService {
  final TransactionService? _transactionService;
  BudgetService([TransactionService? transactionService])
    : _transactionService = transactionService;

  Map<BudgetType, double> calculateAllocations(
    Budget budget, {
    int? month,
    int? year,
  }) {
    _validateBudget(
      budget.monthlyIncome,
      budget.needsPercent,
      budget.wantsPercent,
      budget.savingsPercent,
    );
    if ((month == null) && (year == null)) {
      throw Exception('Month and year must be provided together.');
    }
    if (month != null && (month < 1 || month > 12)) {
      throw Exception('Month must be between 1 and 12.');
    }

    var totalIncome = budget.monthlyIncome;
    if (month != null) {
      totalIncome +=
          _transactionService?.getUnexpectedIncome(month, year!) ?? 0;
    }

    return {
      BudgetType.needs: totalIncome * budget.needsPercent / 100,
      BudgetType.wants: totalIncome * budget.wantsPercent / 100,
      BudgetType.savings: totalIncome * budget.savingsPercent / 100,
    };
  }

  void updateBudget(
    Budget budget, {
    double? monthlyIncome,
    double? needsPercent,
    double? wantsPercent,
    double? savingsPercent,
  }) {
    final updatedIncome = monthlyIncome ?? budget.monthlyIncome;
    final updatedNeedsPercent = needsPercent ?? budget.needsPercent;
    final updatedWantsPercent = wantsPercent ?? budget.wantsPercent;
    final updatedSavingsPercent = savingsPercent ?? budget.savingsPercent;

    _validateBudget(
      updatedIncome,
      updatedNeedsPercent,
      updatedWantsPercent,
      updatedSavingsPercent,
    );

    budget.monthlyIncome = updatedIncome;
    budget.needsPercent = updatedNeedsPercent;
    budget.wantsPercent = updatedWantsPercent;
    budget.savingsPercent = updatedSavingsPercent;
  }

  void setSpendingLimit(
    Budget budget,
    Category category,
    double limit,
    List<Category> categories, {
    int? month,
    int? year,
  }) {
    if (!limit.isFinite || limit < 0) {
      throw Exception('Spending limit must be a positive number.');
    }
    bool categoryExists = false;
    double groupTotal = 0;
    for (final item in categories) {
      if (item.id == category.id) {
        categoryExists = true;
      }
      if (item.budgetType == category.budgetType) {
        groupTotal += item.id == category.id ? limit : item.spendingLimit;
      }
    }
    if (!categoryExists) {
      throw Exception('Category not found.');
    }

    final allocation = calculateAllocations(
      budget,
      month: month,
      year: year,
    )[category.budgetType]!;
    if (groupTotal > allocation) {
      throw Exception('Category limits exceed the budget allocation.');
    }

    category.spendingLimit = limit;
  }

  void _validateBudget(
    double income,
    double needsPercent,
    double wantsPercent,
    double savingsPercent,
  ) {
    if (!income.isFinite || income <= 0) {
      throw Exception('Income must be greater than zero.');
    }
    if (!needsPercent.isFinite ||
        !wantsPercent.isFinite ||
        !savingsPercent.isFinite ||
        needsPercent < 0 ||
        wantsPercent < 0 ||
        savingsPercent < 0) {
      throw Exception('Percentages cannot be negative.');
    }
    final totalPercent = needsPercent + wantsPercent + savingsPercent;
    if ((totalPercent - 100).abs() > 0.000001) {
      throw Exception('Percentages must total 100.');
    }
  }
}
