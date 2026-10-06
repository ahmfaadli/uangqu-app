import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  // ============================================================
  // REPOSITORY
  // ============================================================

  final TransactionRepository _repository = TransactionRepository();

  // ============================================================
  // DATA
  // ============================================================

  int balance = 0;
  int income = 0;
  int expense = 0;
  int savings = 0;

  List<TransactionModel> transactions = [];

  bool loading = true;

  // ============================================================
  // WARNA
  // ============================================================

  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color mediumPurple = Color(0xFF8B5CF6);
  static const Color darkPurple = Color(0xFF5B21B6);
  static const Color lightPurple = Color(0xFFF3E8FF);

  static const Color successColor = Color(0xFF12B76A);
  static const Color dangerColor = Color(0xFFF04438);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    loadData();
  }

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      loadData();
    }
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> loadData() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      // ========================================================
      // TOTAL PEMASUKAN
      // ========================================================

      final totalIncome =
          await _repository.getTotalIncome();

      // ========================================================
      // TOTAL PENGELUARAN
      // ========================================================

      final totalExpense =
          await _repository.getTotalExpense();

      // ========================================================
      // TOTAL TABUNGAN
      // ========================================================

      final totalSavings =
          await _repository.getTotalSavings();

      // ========================================================
      // SALDO AKTUAL
      // ========================================================

      final currentBalance =
          await _repository.getBalance();

      // ========================================================
      // TRANSAKSI BIASA
      // ========================================================

      final recentTransactions =
          await _repository.getRecentTransactions(
        limit: 20,
      );

      // ========================================================
      // RIWAYAT TABUNGAN
      // ========================================================

      final recentSavings =
          await _repository.getSavingsHistory();

      // ========================================================
      // GABUNGKAN TRANSAKSI
      // ========================================================

      final List<TransactionModel> combinedTransactions = [];

      // --------------------------------------------------------
      // TRANSAKSI BIASA
      // --------------------------------------------------------

      combinedTransactions.addAll(
        recentTransactions,
      );

      // --------------------------------------------------------
      // TRANSAKSI TABUNGAN
      // --------------------------------------------------------

      for (final saving in recentSavings) {
        final String type =
            saving['type']?.toString() ?? '';

        final int amount =
            _toInt(saving['amount']);

        final String description =
            saving['description']
                    ?.toString()
                    .trim() ??
                '';

        final DateTime? date =
            _parseDate(saving['date']);

        final DateTime? createdAt =
            _parseDate(saving['created_at']);

        // Jika tanggal tidak valid, lewati data
        if (date == null) {
          continue;
        }

        // ------------------------------------------------------
        // SETORAN TABUNGAN
        // ------------------------------------------------------

        if (type == 'deposit') {
          combinedTransactions.add(
            TransactionModel(
              id: _toInt(saving['id']),
              type: 'expense',
              amount: amount,
              category: 'Tabungan',
              description: description.isNotEmpty
                  ? description
                  : 'Setoran Tabungan',
              date: date,
              createdAt: createdAt ?? date,
            ),
          );
        }

        // ------------------------------------------------------
        // PENARIKAN TABUNGAN
        // ------------------------------------------------------

        else if (type == 'withdraw') {
          combinedTransactions.add(
            TransactionModel(
              id: _toInt(saving['id']),
              type: 'income',
              amount: amount,
              category: 'Tabungan',
              description: description.isNotEmpty
                  ? description
                  : 'Penarikan Tabungan',
              date: date,
              createdAt: createdAt ?? date,
            ),
          );
        }
      }

      // ========================================================
      // URUTKAN TRANSAKSI TERBARU
      // ========================================================

      combinedTransactions.sort(
        (a, b) {
          final dateResult =
              b.date.compareTo(a.date);

          if (dateResult != 0) {
            return dateResult;
          }

          final aCreated = a.createdAt;
          final bCreated = b.createdAt;

          return bCreated.compareTo(
            aCreated,
          );
        },
      );

      // ========================================================
      // AMBIL 5 TRANSAKSI TERBARU
      // ========================================================

      final List<TransactionModel>
          latestTransactions =
          combinedTransactions
              .take(5)
              .toList();

      // ========================================================
      // UPDATE UI
      // ========================================================

      if (!mounted) return;

      setState(() {
        income = totalIncome;
        expense = totalExpense;
        savings = totalSavings;
        balance = currentBalance;
        transactions = latestTransactions;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memuat data: $e',
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  // ============================================================
  // HELPER INTEGER
  // ============================================================

  int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // ============================================================
  // HELPER DATE
  // ============================================================

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    try {
      return DateTime.parse(
        value.toString(),
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // FORMAT RUPIAH
  // ============================================================

  String formatRupiah(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  // ============================================================
  // TAMBAH TRANSAKSI
  // ============================================================

  Future<void> openAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AddTransactionScreen(),
      ),
    );

    if (result == true) {
      await loadData();
    }
  }

  // ============================================================
  // THEME COLORS
  // ============================================================

  Color get _backgroundColor =>
      Theme.of(context).scaffoldBackgroundColor;

  Color get _cardColor =>
      Theme.of(context).cardColor;

  Color get _textColor =>
      Theme.of(context).colorScheme.onSurface;

  Color get _secondaryTextColor {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF667085);
  }

  Color get _borderColor {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return isDark
        ? const Color(0xFF2A2A31)
        : const Color(0xFFEDE9FE);
  }

  Color get _lightPurpleColor {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return isDark
        ? const Color(0xFF2A2140)
        : lightPurple;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,

        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'UangQu',
              style: TextStyle(
                color: _textColor,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              'Kelola keuangan dengan mudah',
              style: TextStyle(
                color: _secondaryTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(
              right: 20,
            ),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _lightPurpleColor,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons
                  .account_balance_wallet_rounded,
              color: primaryPurple,
              size: 21,
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: RefreshIndicator(
        color: primaryPurple,
        backgroundColor: _cardColor,
        displacement: 30,
        onRefresh: loadData,

        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: primaryPurple,
                  strokeWidth: 3,
                ),
              )
            : ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  8,
                  18,
                  125,
                ),

                children: [
                  // ==================================================
                  // SALDO
                  // ==================================================

                  _buildBalanceCard(),

                  const SizedBox(height: 18),

                  // ==================================================
                  // SUMMARY KEUANGAN
                  // ==================================================

                  _buildSummary(),

                  const SizedBox(height: 28),

                  // ==================================================
                  // TRANSAKSI TERBARU
                  // ==================================================

                  _buildTransactionHeader(),

                  const SizedBox(height: 13),

                  if (transactions.isEmpty)
                    _buildEmptyTransaction()
                  else
                    ...transactions.map(
                      (transaction) => Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: TransactionCard(
                          transaction: transaction,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  // ============================================================
  // BALANCE CARD
  // ============================================================

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            mediumPurple,
            primaryPurple,
            darkPurple,
          ],
        ),

        borderRadius:
            BorderRadius.circular(25),

        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(
              alpha: 0.22,
            ),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ======================================================
          // HEADER
          // ======================================================

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              Flexible(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withValues(
                          alpha: 0.15,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          11,
                        ),
                      ),

                      child: const Icon(
                        Icons.wallet_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Flexible(
                      child: Text(
                        'Saldo Saat Ini',
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.13,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: const Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons
                          .account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 14,
                    ),

                    SizedBox(width: 4),

                    Text(
                      'Aktif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ======================================================
          // SALDO
          // ======================================================

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,

            child: Text(
              formatRupiah(balance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 29,
                fontWeight:
                    FontWeight.w800,
                letterSpacing: -0.7,
              ),
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Saldo yang dapat digunakan',
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.75,
              ),
              fontSize: 12,
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(height: 22),

          // ======================================================
          // DIVIDER
          // ======================================================

          Container(
            height: 1,
            color: Colors.white.withValues(
              alpha: 0.13,
            ),
          ),

          const SizedBox(height: 15),

          // ======================================================
          // INFO TABUNGAN
          // ======================================================

          Row(
            children: [
              const Icon(
                Icons.savings_outlined,
                color: Colors.white70,
                size: 15,
              ),

              const SizedBox(width: 7),

              Expanded(
                child: Text(
                  savings > 0
                      ? 'Dana tersimpan: ${formatRupiah(savings)}'
                      : 'Belum ada dana yang disimpan',

                  style: TextStyle(
                    color: Colors.white
                        .withValues(
                      alpha: 0.70,
                    ),
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    return Column(
      children: [
        // ======================================================
        // PEMASUKAN + PENGELUARAN
        // ======================================================

        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Pemasukan',
                amount: income,
                icon:
                    Icons.arrow_downward_rounded,
                color: successColor,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: SummaryCard(
                title: 'Pengeluaran',
                amount: expense,
                icon:
                    Icons.arrow_upward_rounded,
                color: dangerColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ======================================================
        // TABUNGAN
        // ======================================================

        _buildSavingsSummaryCard(),
      ],
    );
  }

  // ============================================================
  // SAVINGS SUMMARY CARD
  // ============================================================

  Widget _buildSavingsSummaryCard() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      decoration: BoxDecoration(
        color: _cardColor,

        borderRadius:
            BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness ==
                          Brightness.dark
                      ? 0.15
                      : 0.035,
            ),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [
          // ====================================================
          // ICON
          // ====================================================

          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color: _lightPurpleColor,
              borderRadius:
                  BorderRadius.circular(13),
            ),

            child: const Icon(
              Icons.savings_rounded,
              color: primaryPurple,
              size: 22,
            ),
          ),

          const SizedBox(width: 13),

          // ====================================================
          // TEXT
          // ====================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Total Tabungan',
                  style: TextStyle(
                    fontSize: 12,
                    color: _secondaryTextColor,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  formatRupiah(savings),
                  style: TextStyle(
                    fontSize: 16,
                    color: _textColor,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // LABEL
          // ====================================================

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),

            decoration: BoxDecoration(
              color: _lightPurpleColor,
              borderRadius:
                  BorderRadius.circular(10),
            ),

            child: const Text(
              'Tersimpan',
              style: TextStyle(
                color: primaryPurple,
                fontSize: 9.5,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRANSACTION HEADER
  // ============================================================

  Widget _buildTransactionHeader() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,

      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                'Transaksi Terbaru',
                style: TextStyle(
                  color: _textColor,
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Aktivitas keuangan terakhir',
                style: TextStyle(
                  color: _secondaryTextColor,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        TextButton(
          onPressed: () {
            // Bisa dihubungkan ke halaman
            // seluruh transaksi jika dibutuhkan.
          },

          style: TextButton.styleFrom(
            foregroundColor: primaryPurple,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            minimumSize: Size.zero,
            tapTargetSize:
                MaterialTapTargetSize.shrinkWrap,
          ),

          child: const Text(
            'Lihat Semua',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY TRANSACTION
  // ============================================================

  Widget _buildEmptyTransaction() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 35,
      ),

      decoration: BoxDecoration(
        color: _cardColor,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: _borderColor,
          width: 1,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness ==
                          Brightness.dark
                      ? 0.15
                      : 0.035,
            ),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        children: [
          // ======================================================
          // ICON
          // ======================================================

          Container(
            width: 64,
            height: 64,

            decoration: BoxDecoration(
              color: _lightPurpleColor,
              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: const Icon(
              Icons.receipt_long_rounded,
              size: 30,
              color: primaryPurple,
            ),
          ),

          const SizedBox(height: 16),

          // ======================================================
          // TITLE
          // ======================================================

          Text(
            'Belum ada transaksi',
            style: TextStyle(
              color: _textColor,
              fontSize: 15,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          // ======================================================
          // DESCRIPTION
          // ======================================================

          Text(
            'Tambahkan transaksi untuk mulai\n'
            'mencatat keuangan Anda.',
            textAlign: TextAlign.center,

            style: TextStyle(
              color: _secondaryTextColor,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}