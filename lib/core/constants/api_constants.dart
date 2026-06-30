import 'package:flutter/foundation.dart';

class ApiConstants {
  // Mettre à false quand vous aurez un backend fonctionnel
  static const bool useMockData = true;

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    } else {
      return 'http://10.0.2.2:8080/api';
    }
  }

  static const String balance = '/wallets/{phone}/balance';
  static const String transactions = '/wallets/{phone}/transactions';
  static const String transfer = '/wallets/transfer';
  static const String unpaidBills = '/external/factures/unpaid';
  static const String payBills = '/wallets/pay-factures';
}
