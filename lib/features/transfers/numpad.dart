import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NumPad extends StatelessWidget {
  final Function(String) onNumberSelected;
  final VoidCallback onDelete;
  final VoidCallback onSubmit;

  const NumPad({
    super.key,
    required this.onNumberSelected,
    required this.onDelete,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildRow(['1', '2', '3']),
          const SizedBox(height: 16),
          _buildRow(['4', '5', '6']),
          const SizedBox(height: 16),
          _buildRow(['7', '8', '9']),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('', icon: Icons.backspace, onPressed: onDelete),
              _buildButton('0'),
              _buildButton('', icon: Icons.check_circle, color: AppColors.primary, onPressed: onSubmit),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((n) => _buildButton(n)).toList(),
    );
  }

  Widget _buildButton(String text, {IconData? icon, Color? color, VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed ?? () => onNumberSelected(text),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color != null ? color.withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, size: 32, color: color ?? AppColors.textPrimary)
              : Text(
                  text,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
