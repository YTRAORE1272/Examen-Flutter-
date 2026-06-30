class Facture {
  final String id;
  final String provider; // SENELEC, WOYAFAL, etc.
  final double amount;
  final bool isPaid;
  final String reference;

  Facture({
    required this.id,
    required this.provider,
    required this.amount,
    required this.isPaid,
    required this.reference,
  });

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      id: json['id'] ?? '',
      provider: json['provider'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isPaid: json['isPaid'] ?? false,
      reference: json['reference'] ?? '',
    );
  }
}
