import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiClient {
  final http.Client _client = http.Client();

  // État local pour simuler la base de données
  static double _mockBalance = 150000.0;
  static final List<Map<String, dynamic>> _mockTransactions = [
    {
      "id": "t1",
      "type": "DEPOSIT",
      "amount": 50000,
      "date": DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      "description": "Dépôt initial"
    },
    {
      "id": "t2",
      "type": "TRANSFER",
      "amount": 15000,
      "date": DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      "description": "Transfert à 771234567"
    }
  ];

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    if (ApiConstants.useMockData) {
      await Future.delayed(const Duration(milliseconds: 800)); // Simule le réseau
      if (endpoint.contains('/balance')) {
        return {"balance": _mockBalance, "currency": "FCFA"};
      } else if (endpoint.contains('/transactions')) {
        return _mockTransactions;
      } else if (endpoint.contains('/unpaid')) {
        return [
          {"id": "f1", "provider": "SENELEC", "amount": 25000, "isPaid": false, "reference": "SEN-001293"},
          {"id": "f2", "provider": "WOYAFAL", "amount": 10000, "isPaid": false, "reference": "WOY-982132"}
        ];
      }
      return null;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    try {
      final response = await _client.get(url, headers: headers);
      return _processResponse(response);
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    if (ApiConstants.useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (endpoint.contains('/transfer')) {
        double amount = (body?['amount'] as num?)?.toDouble() ?? 0.0;
        if (_mockBalance < amount) {
          throw Exception("Solde insuffisant");
        }
        _mockBalance -= amount;
        _mockTransactions.insert(0, {
          "id": "t${DateTime.now().millisecondsSinceEpoch}",
          "type": "TRANSFER",
          "amount": amount,
          "date": DateTime.now().toIso8601String(),
          "description": "Transfert envoyé"
        });
        return {"status": "success"};
      } else if (endpoint.contains('/pay-factures')) {
        return {"status": "success"};
      }
      return null;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json', ...?headers},
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur serveur (${response.statusCode}) : ${response.body}');
    }
  }
}
