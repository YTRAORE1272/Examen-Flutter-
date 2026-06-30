import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/wallet_provider.dart';
import '../../core/constants/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();
    final transactions = provider.transactions;
    final isLoading = provider.state == WalletState.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des transactions')),
      body: isLoading && transactions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(child: Text('Aucune transaction trouvée.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final t = transactions[index];
                    final isNegative = t.type == 'TRANSFER' || t.type == 'PAYMENT';
                    final color = isNegative ? AppColors.error : AppColors.success;
                    final prefix = isNegative ? '-' : '+';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.1),
                        child: Icon(
                          isNegative ? Icons.arrow_upward : Icons.arrow_downward,
                          color: color,
                        ),
                      ),
                      title: Text(t.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat('dd MMM yyyy à HH:mm').format(t.date)),
                      trailing: Text(
                        '$prefix${currencyFormatter.format(t.amount)}',
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    );
                  },
                ),
    );
  }
}
