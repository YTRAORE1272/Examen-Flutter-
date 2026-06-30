class Transaction {
  final String id;
  final String type; // TRANSFER, DEPOSIT, PAYMENT
  final double amount;
  final DateTime date;
  final String description;
  final String? relatedPhone;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    this.relatedPhone,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      type: json['type'] ?? 'UNKNOWN',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      description: json['description'] ?? '',
      relatedPhone: json['relatedPhone'],
    );
  }
}
