enum TransactionType { income, expense }

enum IncomeSource { regular, unexpected }

class Transaction {
  final int id;
  String description;
  double amount;
  TransactionType type;
  int categoryId;
  DateTime date;
  IncomeSource incomeSource;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.incomeSource = IncomeSource.regular,
  });
}
