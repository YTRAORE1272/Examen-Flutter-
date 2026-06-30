import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/wallet_provider.dart';
import '../../core/constants/app_colors.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final Set<String> _selectedBillIds = {};
  final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchUnpaidBills();
    });
  }

  void _paySelectedBills() async {
    if (_selectedBillIds.isEmpty) return;

    final provider = context.read<WalletProvider>();
    try {
      await provider.payBills(_selectedBillIds.toList());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paiement réussi !')));
      setState(() {
        _selectedBillIds.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();
    final isLoading = provider.state == WalletState.loading;
    final bills = provider.unpaidBills;

    double totalAmount = 0.0;
    for (var bill in bills) {
      if (_selectedBillIds.contains(bill.id)) {
        totalAmount += bill.amount;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement de factures')),
      body: isLoading && bills.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : bills.isEmpty
              ? const Center(child: Text('Aucune facture impayée.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bills.length,
                  itemBuilder: (context, index) {
                    final bill = bills[index];
                    final isSelected = _selectedBillIds.contains(bill.id);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedBillIds.add(bill.id);
                            } else {
                              _selectedBillIds.remove(bill.id);
                            }
                          });
                        },
                        title: Text(bill.provider, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Réf: ${bill.reference}'),
                        secondary: Text(
                          currencyFormatter.format(bill.amount),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error),
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: _selectedBillIds.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _paySelectedBills,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Payer ${currencyFormatter.format(totalAmount)}'),
                ),
              ),
            )
          : null,
    );
  }
}
