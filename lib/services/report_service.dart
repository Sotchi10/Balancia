import '../models/transaction.dart';
import 'transaction_service.dart';

class ReportService {
  final TransactionService _transactionService;

  ReportService(this._transactionService);

  double getTotalIncome(int month, int year) =>
      _getTotal(month, year, TransactionType.income);

  double getTotalExpenses(int month, int year) =>
      _getTotal(month, year, TransactionType.expense);

  double getRemainingBalance(int month, int year) =>
      getTotalIncome(month, year) - getTotalExpenses(month, year);

  Map<int, double> getExpensesByCategory(int month, int year) {
    final expensesByCategory = <int, double>{};
    for (final transaction in _transactionService.getTransactions()) {
      if (transaction.date.month == month &&
          transaction.date.year == year &&
          transaction.type == TransactionType.expense) {
        expensesByCategory[transaction.categoryId] =
            (expensesByCategory[transaction.categoryId] ?? 0) +
            transaction.amount;
      }
    }
    return expensesByCategory;
  }

  double _getTotal(int month, int year, TransactionType type) {
    double total = 0;
    for (final transaction in _transactionService.getTransactions()) {
      if (transaction.date.month == month &&
          transaction.date.year == year &&
          transaction.type == type) {
        total += transaction.amount;
      }
    }
    return total;
  }
}
