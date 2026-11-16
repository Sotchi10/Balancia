import 'package:balancia/models/transaction.dart';
import 'package:balancia/services/transaction_service.dart';
import 'package:flutter_test/flutter_test.dart';

Transaction createTransaction({
  int id = 1,
  String description = 'Groceries',
  double amount = 200,
}) {
  return Transaction(
    id: id,
    description: description,
    amount: amount,
    type: TransactionType.expense,
    categoryId: 10,
    date: DateTime(2026, 11, 5),
  );
}

void main() {
  group('TransactionService', () {
    group('addTransaction', () {
      test('Adds a valid transaction', () {
        final service = TransactionService();
        service.addTransaction(createTransaction());

        expect(service.getTransactions(), hasLength(1));
        expect(service.getTransactions().first.description, 'Groceries');
      });

      test('Rejects duplicate IDs', () {
        final service = TransactionService();
        service.addTransaction(createTransaction());

        expect(
          () => service.addTransaction(createTransaction()),
          throwsException,
        );
        expect(service.getTransactions(), hasLength(1));
      });

      test('Rejects zero or negative amounts', () {
        final service = TransactionService();

        expect(
          () => service.addTransaction(createTransaction(amount: 0)),
          throwsException,
        );
        expect(
          () => service.addTransaction(createTransaction(id: 2, amount: -10)),
          throwsException,
        );
        expect(service.getTransactions(), isEmpty);
      });

      test('Rejects an empty or whitespace-only description', () {
        final service = TransactionService();

        expect(
          () => service.addTransaction(createTransaction(description: '')),
          throwsException,
        );
        expect(
          () => service.addTransaction(createTransaction(description: '   ')),
          throwsException,
        );
        expect(service.getTransactions(), isEmpty);
      });
    });

    group('addUnexpectedIncome', () {
      test('Records and totals unexpected income for the selected month', () {
        final service = TransactionService();

        service.addUnexpectedIncome(
          id: 1,
          description: 'Freelance work',
          amount: 100,
          date: DateTime(2026, 11, 10),
        );

        final transaction = service.getTransactions().single;
        expect(transaction.type, TransactionType.income);
        expect(transaction.incomeSource, IncomeSource.unexpected);
        expect(service.getUnexpectedIncome(11, 2026), 100);
        expect(service.getUnexpectedIncome(12, 2026), 0);
      });
    });

    group('editTransaction', () {
      test('Replaces an existing transaction', () {
        final service = TransactionService();
        service.addTransaction(createTransaction());

        service.editTransaction(
          createTransaction(description: 'Groceries', amount: 250),
        );

        expect(service.getTransactions().first.description, 'Groceries');
        expect(service.getTransactions().first.amount, 250);
      });

      test('Rejects a missing transaction', () {
        final service = TransactionService();

        expect(
          () => service.editTransaction(createTransaction()),
          throwsException,
        );
        expect(service.getTransactions(), isEmpty);
      });
    });

    group('deleteTransaction', () {
      test('Removes an existing transaction', () {
        final service = TransactionService();
        service.addTransaction(createTransaction());

        service.deleteTransaction(1);

        expect(service.getTransactions(), isEmpty);
      });

      test('Rejects a missing transaction', () {
        expect(
          () => TransactionService().deleteTransaction(1),
          throwsException,
        );
      });
    });

    group('getTransactions', () {
      test('Returns all added transactions', () {
        final service = TransactionService();
        service.addTransaction(createTransaction());
        service.addTransaction(createTransaction(id: 2, description: 'Salary'));

        expect(service.getTransactions().map((item) => item.id), [1, 2]);
      });
    });
  });
}
