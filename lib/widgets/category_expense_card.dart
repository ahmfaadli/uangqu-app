import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryExpenseCard extends StatelessWidget {
  final String category;
  final int amount;
  final double percentage;

  const CategoryExpenseCard({
    super.key,
    required this.category,
    required this.amount,
    required this.percentage,
  });

  String formatRupiah(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Warna mengikuti Light / Dark Mode
    final cardColor = theme.cardColor;

    final primaryText = theme.colorScheme.onSurface;

    final secondaryText = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF667085);

    final borderColor = isDark
        ? const Color(0xFF2A2A31)
        : const Color(0xFFE4E7EC);

    // Background progress menyesuaikan tema
    final progressBackground = isDark
        ? const Color(0xFF2A2A31)
        : const Color(0xFFE9E7EF);

    // Ungu tetap ungu
    const purpleColor = Color(0xFF7C3AED);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
              ),

              Text(
                formatRupiah(amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress pengeluaran
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: progressBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(
                purpleColor,
              ),
            ),
          ),

          const SizedBox(height: 5),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(percentage * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: secondaryText,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}