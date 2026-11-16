import 'package:balancia/models/budget.dart';
import 'package:balancia/models/category.dart';
import 'package:balancia/services/budget_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BudgetService', () {
    group('calculateAllocations', () {
      test('Uses the default 50/30/20 rule', () {
        final allocations = BudgetService().calculateAllocations(
          Budget(monthlyIncome: 1000),
        );

        expect(allocations[BudgetType.needs], 500);
        expect(allocations[BudgetType.wants], 300);
        expect(allocations[BudgetType.savings], 200);
      });
    });

    group('updateBudget', () {
      test('Changes allocation percentages', () {
        final budget = Budget(monthlyIncome: 1000);
        final service = BudgetService();

        service.updateBudget(
          budget,
          needsPercent: 60,
          wantsPercent: 25,
          savingsPercent: 15,
        );

        expect(service.calculateAllocations(budget)[BudgetType.needs], 600);
        expect(service.calculateAllocations(budget)[BudgetType.wants], 250);
        expect(service.calculateAllocations(budget)[BudgetType.savings], 150);
      });

      test('Changes monthly income when supplied', () {
        final budget = Budget(monthlyIncome: 1000);

        BudgetService().updateBudget(
          budget,
          monthlyIncome: 2000,
          needsPercent: 50,
          wantsPercent: 30,
          savingsPercent: 20,
        );

        expect(budget.monthlyIncome, 2000);
      });

      test('Rejects percentages that do not total 100', () {
        final budget = Budget(monthlyIncome: 1000);

        expect(
          () => BudgetService().updateBudget(
            budget,
            needsPercent: 50,
            wantsPercent: 20,
            savingsPercent: 20,
          ),
          throwsException,
        );
        expect(budget.needsPercent, 50);
        expect(budget.wantsPercent, 30);
        expect(budget.savingsPercent, 20);
      });

      test('Rejects negative percentages', () {
        final budget = Budget(monthlyIncome: 1000);

        expect(
          () => BudgetService().updateBudget(
            budget,
            needsPercent: -10,
            wantsPercent: 50,
            savingsPercent: 60,
          ),
          throwsException,
        );
        expect(budget.needsPercent, 50);
      });

      test('Rejects income of zero or less', () {
        final budget = Budget(monthlyIncome: 1000);

        expect(
          () => BudgetService().updateBudget(
            budget,
          monthlyIncome: 0,
            needsPercent: 50,
            wantsPercent: 30,
            savingsPercent: 20,
          ),
          throwsException,
        );
        expect(budget.monthlyIncome, 1000);
      });
    });

    group('setSpendingLimit', () {
      test('Sets a limit to each categories', () {
        final category = Category(
          id: 1,
          name: 'Rent',
          budgetType: BudgetType.needs,
        );

        BudgetService().setSpendingLimit(Budget(monthlyIncome: 1000), category, 400, [
          category,
        ]);

        expect(category.spendingLimit, 400);
      });

      test('Updates an existing limit', () {
        final category = Category(
          id: 1,
          name: 'Rent',
          budgetType: BudgetType.needs,
          spendingLimit: 300,
        );

        BudgetService().setSpendingLimit(Budget(monthlyIncome: 1000), category, 400, [
          category,
        ]);

        expect(category.spendingLimit, 400);
      });

      test('Rejects limits on each categories', () {
        final category = Category(
          id: 1,
          name: 'Rent',
          budgetType: BudgetType.needs,
          spendingLimit: 400,
        );

        expect(
          () => BudgetService().setSpendingLimit(
            Budget(monthlyIncome: 1000),
            category,
            600,
            [category],
          ),
          throwsException,
        );
        expect(category.spendingLimit, 400);
      });

      test('Rejects negative limits', () {
        final category = Category(
          id: 1,
          name: 'Rent',
          budgetType: BudgetType.needs,
        );

        expect(
          () => BudgetService().setSpendingLimit(
            Budget(monthlyIncome: 1000),
            category,
            -1,
            [category],
          ),
          throwsException,
        );
        expect(category.spendingLimit, 0);
      });
    });
  });
}
