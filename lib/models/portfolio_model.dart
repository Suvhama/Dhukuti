class PortfolioModel {
  final String userId;
  final double totalSilverTola;
  final double totalInvestedAmount;

  PortfolioModel({
    required this.userId,
    required this.totalSilverTola,
    required this.totalInvestedAmount,
  });

  factory PortfolioModel.fromMap(Map<String, dynamic> map, String userId) {
    return PortfolioModel(
      userId: userId,
      totalSilverTola: (map['totalSilverTola'] ?? 0).toDouble(),
      totalInvestedAmount: (map['totalInvestedAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalSilverTola': totalSilverTola,
      'totalInvestedAmount': totalInvestedAmount,
    };
  }
  
  // Helper to calculate P/L
  double calculateProfitLoss(double currentPricePerTola) {
    final currentValue = totalSilverTola * currentPricePerTola;
    return currentValue - totalInvestedAmount;
  }
}
