class Budget {
  double monthlyIncome;
  double needsPercent;
  double wantsPercent;
  double savingsPercent;

  Budget({
    required this.monthlyIncome,
    this.needsPercent = 50,
    this.wantsPercent = 30,
    this.savingsPercent = 20,
  });
}
