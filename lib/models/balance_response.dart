class BalanceResponse {
  final double balance;
  final String currency;

  BalanceResponse({
    required this.balance,
    required this.currency,
  });

  factory BalanceResponse.fromJson(Map<String, dynamic> json) {
    return BalanceResponse(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'XOF',
    );
  }
}
