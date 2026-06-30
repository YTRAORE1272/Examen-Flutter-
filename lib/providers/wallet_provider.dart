import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/transaction_model.dart';
import '../models/facture_model.dart';
import '../models/balance_response.dart';

enum WalletState { initial, loading, loaded, error }

class WalletProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  WalletState _state = WalletState.initial;
  String? _errorMessage;
  String? _phone;
  double _balance = 0.0;
  List<Transaction> _transactions = [];
  List<Facture> _unpaidBills = [];

  WalletState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get phone => _phone;
  double get balance => _balance;
  List<Transaction> get transactions => _transactions;
  List<Facture> get unpaidBills => _unpaidBills;

  void _setLoading() {
    _state = WalletState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = WalletState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _setLoaded() {
    _state = WalletState.loaded;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    _phone = await _storage.read(key: 'phone');
    if (_phone != null) {
      await loadDashboardData();
    }
  }

  Future<void> login(String phoneNumber) async {
    _setLoading();
    try {
      _phone = phoneNumber;
      await _storage.write(key: 'phone', value: _phone);
      await loadDashboardData();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadDashboardData() async {
    if (_phone == null) return;
    _setLoading();
    try {
      await Future.wait([
        fetchBalance(notify: false),
        fetchTransactions(notify: false),
      ]);
      _setLoaded();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> fetchBalance({bool notify = true}) async {
    if (_phone == null) return;
    if (notify) _setLoading();
    try {
      final endpoint = ApiConstants.balance.replaceAll('{phone}', _phone!);
      final response = await _apiClient.get(endpoint);
      if (response != null) {
        final balResp = BalanceResponse.fromJson(response);
        _balance = balResp.balance;
      }
      if (notify) _setLoaded();
    } catch (e) {
      if (notify) _setError(e.toString());
      rethrow;
    }
  }

  Future<void> fetchTransactions({bool notify = true}) async {
    if (_phone == null) return;
    if (notify) _setLoading();
    try {
      final endpoint = ApiConstants.transactions.replaceAll('{phone}', _phone!);
      final response = await _apiClient.get(endpoint);
      if (response != null && response is List) {
        _transactions = response.map((json) => Transaction.fromJson(json)).toList();
        _transactions.sort((a, b) => b.date.compareTo(a.date));
      }
      if (notify) _setLoaded();
    } catch (e) {
      if (notify) _setError(e.toString());
      rethrow;
    }
  }

  Future<void> transfer(String recipientPhone, double amount) async {
    if (_phone == null) return;
    _setLoading();
    try {
      await _apiClient.post(ApiConstants.transfer, body: {
        'senderPhone': _phone,
        'recipientPhone': recipientPhone,
        'amount': amount,
      });
      await loadDashboardData();
    } catch (e) {
      _setError(e.toString());
      throw e;
    }
  }

  Future<void> fetchUnpaidBills() async {
    _setLoading();
    try {
      final response = await _apiClient.get(ApiConstants.unpaidBills);
      if (response != null && response is List) {
        _unpaidBills = response.map((json) => Facture.fromJson(json)).toList();
      }
      _setLoaded();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> payBills(List<String> factureIds) async {
    if (_phone == null || factureIds.isEmpty) return;
    _setLoading();
    try {
      await _apiClient.post(ApiConstants.payBills, body: {
        'phone': _phone,
        'factureIds': factureIds,
      });
      await fetchUnpaidBills();
      await fetchBalance(notify: false);
      _setLoaded();
    } catch (e) {
      _setError(e.toString());
      throw e;
    }
  }
  
  Future<void> logout() async {
    await _storage.delete(key: 'phone');
    _phone = null;
    _balance = 0.0;
    _transactions = [];
    _unpaidBills = [];
    _state = WalletState.initial;
    notifyListeners();
  }
}
