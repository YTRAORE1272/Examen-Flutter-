import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/wallet_provider.dart';
import 'numpad.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _phoneController = TextEditingController();
  String _amount = '';
  final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

  void _onNumberSelected(String number) {
    if (_amount.length < 7) { // Max 9 999 999 FCFA
      setState(() {
        _amount += number;
      });
    }
  }

  void _onDelete() {
    if (_amount.isNotEmpty) {
      setState(() {
        _amount = _amount.substring(0, _amount.length - 1);
      });
    }
  }

  void _onSubmit() async {
    if (_amount.isEmpty) return;
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez saisir le numéro du destinataire')));
      return;
    }

    final double amountValue = double.parse(_amount);
    if (amountValue <= 0) return;

    final provider = context.read<WalletProvider>();
    try {
      await provider.transfer(phone, amountValue);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transfert réussi !')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double amountValue = _amount.isEmpty ? 0 : double.parse(_amount);
    final isLoading = context.watch<WalletProvider>().state == WalletState.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Transférer de l\'argent')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Numéro du destinataire',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Montant à envoyer', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormatter.format(amountValue),
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading) const CircularProgressIndicator(),
            NumPad(
              onNumberSelected: _onNumberSelected,
              onDelete: _onDelete,
              onSubmit: _onSubmit,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
