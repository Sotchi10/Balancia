import 'package:balancia/models/transaction.dart';
import 'package:balancia/services/report_service.dart';
import 'package:balancia/services/transaction_service.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionService createTransactionService() {
  final service = TransactionService();
  service.addTransaction(
    Transaction(
      id: 1,
      description: 'Salary',
      amount: 3000,
      type: TransactionType.income,
      categoryId: 1,
      date: DateTime(2026, 11, 1),
    ),
  );
  service.addTransaction(
    Transaction(
      id: 2,
      description: 'Groceries',
      amount: 200,
      type: TransactionType.expense,
      categoryId: 10,
      date: DateTime(2026, 11, 5),
    ),
  );
  service.addTransaction(
    Transaction(
      id: 3,
      description: 'Transport',
      amount: 100,
      type: TransactionType.expense,
      categoryId: 11,
      date: DateTime(2026, 11, 6),
    ),
  );
  return service;
}

void main() {
  group('ReportService', () {
    group('getTotalIncome', () {
      test('Returns the selected month income', () {
        expect(
          ReportService(createTransactionService()).getTotalIncome(11, 2026),
          3000,
        );
      });
    });

    group('getTotalExpenses', () {
      test('Returns selected month expenses', () {
        expect(
          ReportService(createTransactionService()).getTotalExpenses(11, 2026),
          300,
        );
      });
    });

    group('getRemainingBalance', () {
      test('Subtracts expenses from income', () {
        expect(
          ReportService(createTransactionService())
              .getRemainingBalance(11, 2026),
          2700,
        );
      });
    });

    group('getExpensesByCategory', () {
      test('Sums multiple expenses in the same category', () {
        final transactions = createTransactionService();
        transactions.addTransaction(
          Transaction(
            id: 4,
            description: 'More groceries',
            amount: 50,
            type: TransactionType.expense,
            categoryId: 10,
            date: DateTime(2026, 11, 8),
          ),
        );

        expect(
          ReportService(transactions).getExpensesByCategory(11, 2026),
          {10: 250, 11: 100},
        );
      });
    });

    group('monthly reports', () {
      test('Return zero values for an empty month', () {
        final report = ReportService(createTransactionService());

        expect(report.getTotalIncome(10, 2026), 0);
        expect(report.getTotalExpenses(10, 2026), 0);
        expect(report.getRemainingBalance(10, 2026), 0);
        expect(report.getExpensesByCategory(10, 2026), isEmpty);
      });

      test('Reports transactions added', () {
        final transactions = createTransactionService();
        final report = ReportService(transactions);
        transactions.addTransaction(
          Transaction(
            id: 4,
            description: 'Freelance work',
            amount: 500,
            type: TransactionType.income,
            categoryId: 2,
            date: DateTime(2026, 11, 10),
          ),
        );

        expect(report.getTotalIncome(11, 2026), 3500);
      });
    });
  });
}
