import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/wallet_provider.dart';
import '../../core/constants/app_colors.dart';
import '../transfers/transfer_screen.dart';
import '../bills/bills_screen.dart';
import '../history/history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isBalanceVisible = true;
  final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();
    final isLoading = provider.state == WalletState.loading;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadDashboardData,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildHeader(provider.phone ?? ''),
              const SizedBox(height: 24),
              _buildBalanceCard(provider.balance),
              const SizedBox(height: 24),
              _buildActionButtons(context),
              const SizedBox(height: 32),
              _buildRecentTransactions(provider.transactions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String phone) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bonjour,',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            Text(
              phone,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            context.read<WalletProvider>().logout();
            Navigator.pushReplacementNamed(context, '/login');
          },
        )
      ],
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Solde Actuel',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              IconButton(
                icon: Icon(
                  _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isBalanceVisible ? currencyFormatter.format(balance) : '••••••••',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.send,
          label: 'Transférer',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransferScreen()),
          ),
        ),
        _ActionButton(
          icon: Icons.receipt,
          label: 'Payer',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BillsScreen()),
          ),
        ),
        _ActionButton(
          icon: Icons.history,
          label: 'Historique',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(List transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('Aucune transaction récente.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    
    final recent = transactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Activité Récente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
              child: const Text('Voir tout'),
            )
          ],
        ),
        const SizedBox(height: 10),
        ...recent.map((t) => _buildTransactionItem(t)).toList(),
      ],
    );
  }

  Widget _buildTransactionItem(transaction) {
    final isNegative = transaction.type == 'TRANSFER' || transaction.type == 'PAYMENT';
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
      title: Text(transaction.description, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(DateFormat('dd MMM yyyy à HH:mm').format(transaction.date)),
      trailing: Text(
        '$prefix${currencyFormatter.format(transaction.amount)}',
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
