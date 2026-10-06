import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
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
    final isIncome = transaction.type == 'income';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Warna mengikuti tema aplikasi
    final cardColor = theme.cardColor;
    final primaryText = theme.colorScheme.onSurface;

    final secondaryText = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF667085);

    final borderColor = isDark
        ? const Color(0xFF2A2A31)
        : const Color(0xFFE4E7EC);

    // Warna brand tetap ungu
    const purpleColor = Color(0xFF7C3AED);

    // Warna transaksi tetap
    const incomeColor = Color(0xFF12B76A);
    const expenseColor = Color(0xFFF04438);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon transaksi
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: isIncome
                      ? incomeColor.withOpacity(.10)
                      : expenseColor.withOpacity(.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isIncome
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: isIncome
                      ? incomeColor
                      : expenseColor,
                ),
              ),

              const SizedBox(width: 13),

              // Informasi transaksi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      transaction.description.isEmpty
                          ? 'Tidak ada keterangan'
                          : transaction.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Nominal
              Text(
                '${isIncome ? '+' : '-'} ${formatRupiah(transaction.amount)}',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isIncome
                      ? incomeColor
                      : expenseColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}