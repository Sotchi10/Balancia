import '../models/transaction.dart';

class TransactionService {
  final List<Transaction> _transactions = [];

  void addTransaction(Transaction transaction) {
    _validateTransaction(transaction);

    for (final item in _transactions) {
      if (item.id == transaction.id) {
        throw Exception('A transaction with this ID already existed.');
      }
    }
    _transactions.add(transaction);
  }

  Transaction addUnexpectedIncome({
    required int id,
    required String description,
    required double amount,
    required DateTime date,
    int categoryId = 0,
  }) {
    final transaction = Transaction(
      id: id,
      description: description,
      amount: amount,
      type: TransactionType.income,
      categoryId: categoryId,
      date: date,
      incomeSource: IncomeSource.unexpected,
    );
    addTransaction(transaction);
    return transaction;
  }

  double getUnexpectedIncome(int month, int year) {
    double total = 0;
    for (final transaction in _transactions) {
      if (transaction.type == TransactionType.income &&
          transaction.incomeSource == IncomeSource.unexpected &&
          transaction.date.month == month &&
          transaction.date.year == year) {
        total += transaction.amount;
      }
    }
    return total;
  }

  void editTransaction(Transaction transaction) {
    _validateTransaction(transaction);

    for (int index = 0; index < _transactions.length; index++) {
      if (_transactions[index].id == transaction.id) {
        _transactions[index] = transaction;
        return;
      }
    }
    throw Exception('Transaction not found.');
  }

  void deleteTransaction(int id) {
    for (int index = 0; index < _transactions.length; index++) {
      if (_transactions[index].id == id) {
        _transactions.removeAt(index);
        return;
      }
    }

    throw Exception('Transaction not found.');
  }

  List<Transaction> getTransactions() {
    return List<Transaction>.from(_transactions);
  }

  void _validateTransaction(Transaction transaction) {
    if (transaction.description.trim().isEmpty) {
      throw Exception('Description is required.');
    }
    if (!transaction.amount.isFinite || transaction.amount <= 0) {
      throw Exception('Amount must be greater than zero.');
    }
  }
}
