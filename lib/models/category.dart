enum BudgetType { needs, wants, savings }

class Category {
  final int id;
  final String name;
  final BudgetType budgetType;
  double spendingLimit;

  Category({
    required this.id,
    required this.name,
    required this.budgetType,
    this.spendingLimit = 0,
  });
}
