import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color mediumPurple = Color(0xFF8B5CF6);
  static const Color darkPurple = Color(0xFF5B21B6);

  static const Color lightBackground = Color(0xFFF8F7FC);
  static const Color darkBackground = Color(0xFF111114);

  static const Color lightTextDark = Color(0xFF18181B);
  static const Color darkTextDark = Color(0xFFF4F4F5);

  static const Color lightTextSecondary = Color(0xFF667085);
  static const Color darkTextSecondary = Color(0xFFA1A1AA);

  static const Color lightBorder = Color(0xFFEAE7EF);
  static const Color darkBorder = Color(0xFF2A2A31);

  static const Color lightDivider = Color(0xFFF0EEF2);
  static const Color darkDivider = Color(0xFF2A2A31);

  static const Color incomeColor = Color(0xFF12B76A);
  static const Color expenseColor = Color(0xFFF04438);

  // ============================================================
  // REPOSITORY
  // ============================================================

  final TransactionRepository _repository = TransactionRepository();

  // ============================================================
  // PAGE / MONTH
  // ============================================================

  static const int _currentPage = 120;

  late PageController _pageController;

  DateTime selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  // ============================================================
  // DATA
  // ============================================================

  int monthlyIncome = 0;
  int monthlyExpense = 0;
  int monthlySavingsDeposit = 0;
  int monthlySavingsWithdraw = 0;
  int monthlySavings = 0;
  int openingBalance = 0;
  int monthlyBalance = 0;
  int totalSavingsBalance = 0;

  List<ReportTransaction> monthlyTransactions = [];

  bool loading = true;
  String? errorMessage;

  // ============================================================
  // THEME COLORS
  // ============================================================

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _backgroundColor =>
      _isDark ? darkBackground : lightBackground;

  Color get _textDark =>
      _isDark ? darkTextDark : lightTextDark;

  Color get _textSecondary =>
      _isDark ? darkTextSecondary : lightTextSecondary;

  Color get _cardColor =>
      Theme.of(context).cardColor;

  Color get _borderColor =>
      _isDark ? darkBorder : lightBorder;

  Color get _dividerColor =>
      _isDark ? darkDivider : lightDivider;

  Color get _emptyIconBackground =>
      _isDark
          ? const Color(0xFF24242A)
          : const Color(0xFFF1EFF5);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    selectedMonth = DateTime(
      now.year,
      now.month,
      1,
    );

    _pageController = PageController(
      initialPage: _currentPage,
    );

    loadReport();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD REPORT
  // ============================================================

  Future<void> loadReport() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      // ----------------------------------------------------------
      // Ambil seluruh transaksi
      // ----------------------------------------------------------

      final allTransactions =
          await _repository.getTransactions();

      // ----------------------------------------------------------
      // Ambil seluruh riwayat tabungan
      // ----------------------------------------------------------

      final allSavings =
          await _repository.getSavingsHistory();

      final int year = selectedMonth.year;
      final int month = selectedMonth.month;

      // ----------------------------------------------------------
      // TRANSAKSI BULAN TERPILIH
      // ----------------------------------------------------------

      final transactionsThisMonth =
          allTransactions.where((transaction) {
        return _isSameMonth(
          transaction.date,
          selectedMonth,
        );
      }).toList();

      // ----------------------------------------------------------
      // TABUNGAN BULAN TERPILIH
      // ----------------------------------------------------------

      final savingsThisMonth =
          allSavings.where((saving) {
        final date = _parseDate(saving['date']);

        if (date == null) return false;

        return _isSameMonth(
          date,
          selectedMonth,
        );
      }).toList();

      // ----------------------------------------------------------
      // HITUNG PEMASUKAN
      // ----------------------------------------------------------

      int income = 0;

      for (final transaction in transactionsThisMonth) {
        if (transaction.type == 'income') {
          income += transaction.amount;
        }
      }

      // ----------------------------------------------------------
      // HITUNG PENGELUARAN
      // ----------------------------------------------------------

      int expense = 0;

      for (final transaction in transactionsThisMonth) {
        if (transaction.type == 'expense') {
          expense += transaction.amount;
        }
      }

      // ----------------------------------------------------------
      // HITUNG TABUNGAN BULAN INI
      // ----------------------------------------------------------

      int deposit = 0;
      int withdraw = 0;

      for (final saving in savingsThisMonth) {
        final type =
            saving['type']?.toString() ?? '';

        final amount =
            _toInt(saving['amount']);

        if (type == 'deposit') {
          deposit += amount;
        } else if (type == 'withdraw') {
          withdraw += amount;
        }
      }

      // ----------------------------------------------------------
      // SALDO AWAL BULAN
      // ----------------------------------------------------------

      int previousBalance = 0;

      for (final transaction in allTransactions) {
        if (transaction.date.isBefore(selectedMonth)) {
          if (transaction.type == 'income') {
            previousBalance += transaction.amount;
          } else if (transaction.type == 'expense') {
            previousBalance -= transaction.amount;
          }
        }
      }

      // ----------------------------------------------------------
      // TABUNGAN SEBELUM BULAN INI
      // ----------------------------------------------------------

      for (final saving in allSavings) {
        final date = _parseDate(saving['date']);

        if (date == null) continue;

        if (date.isBefore(selectedMonth)) {
          final type =
              saving['type']?.toString() ?? '';

          final amount =
              _toInt(saving['amount']);

          if (type == 'deposit') {
            previousBalance -= amount;
          } else if (type == 'withdraw') {
            previousBalance += amount;
          }
        }
      }

      // ----------------------------------------------------------
      // SALDO AKHIR BULAN
      // ----------------------------------------------------------

      final int endingBalance =
          previousBalance +
          income -
          expense -
          deposit +
          withdraw;

      // ----------------------------------------------------------
      // TOTAL TABUNGAN AKTUAL
      // ----------------------------------------------------------

      int currentSavingsBalance = 0;

      for (final saving in allSavings) {
        final type =
            saving['type']?.toString() ?? '';

        final amount =
            _toInt(saving['amount']);

        if (type == 'deposit') {
          currentSavingsBalance += amount;
        } else if (type == 'withdraw') {
          currentSavingsBalance -= amount;
        }
      }

      // ----------------------------------------------------------
      // GABUNGKAN RIWAYAT TRANSAKSI
      // DENGAN RIWAYAT TABUNGAN
      // ----------------------------------------------------------

      final List<ReportTransaction> reportTransactions = [];

      // ----------------------------------------------------------
      // TRANSAKSI BIASA
      // ----------------------------------------------------------

      for (final transaction in transactionsThisMonth) {
        reportTransactions.add(
          ReportTransaction.fromTransaction(
            transaction,
          ),
        );
      }

      // ----------------------------------------------------------
      // TRANSAKSI TABUNGAN
      // ----------------------------------------------------------

      for (final saving in savingsThisMonth) {
        final type =
            saving['type']?.toString() ?? '';

        final amount =
            _toInt(saving['amount']);

        final date =
            _parseDate(saving['date']) ??
            selectedMonth;

        final description =
            saving['description']
                    ?.toString()
                    .trim() ??
                '';

        reportTransactions.add(
          ReportTransaction.savings(
            id: _toInt(saving['id']),
            type: type,
            amount: amount,
            description: description,
            date: date,
          ),
        );
      }

      // ----------------------------------------------------------
      // URUTKAN TERBARU
      // ----------------------------------------------------------

      reportTransactions.sort(
        (a, b) {
          final result =
              b.date.compareTo(a.date);

          if (result != 0) {
            return result;
          }

          return b.id.compareTo(a.id);
        },
      );

      // ----------------------------------------------------------
      // NET SAVINGS BULAN INI
      // ----------------------------------------------------------

      final int netSavings =
          deposit - withdraw;

      // ----------------------------------------------------------
      // UPDATE STATE
      // ----------------------------------------------------------

      if (!mounted) return;

      setState(() {
        monthlyIncome = income;
        monthlyExpense = expense;
        monthlySavingsDeposit = deposit;
        monthlySavingsWithdraw = withdraw;
        monthlySavings = netSavings;
        openingBalance = previousBalance;
        monthlyBalance = endingBalance;
        totalSavingsBalance =
            currentSavingsBalance;
        monthlyTransactions =
            reportTransactions;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage =
            'Gagal memuat rekapan: $e';
      });
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool _isSameMonth(
    DateTime date,
    DateTime month,
  ) {
    return date.year == month.year &&
        date.month == month.month;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    try {
      return DateTime.parse(
        value.toString(),
      );
    } catch (_) {
      return null;
    }
  }

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
  // FORMAT RUPIAH
  // ============================================================

  String _formatCurrency(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  String _formatShortCurrency(int value) {
    if (value.abs() >= 1000000000) {
      return 'Rp ${(value / 1000000000).toStringAsFixed(1)} M';
    }

    if (value.abs() >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)} Jt';
    }

    if (value.abs() >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(0)} Rb';
    }

    return _formatCurrency(value);
  }

  String _formatDate(DateTime date) {
    return DateFormat(
      'dd MMM yyyy',
      'id_ID',
    ).format(date);
  }

  String _monthName(DateTime date) {
    return DateFormat(
      'MMMM yyyy',
      'id_ID',
    ).format(date);
  }

  // ============================================================
  // MONTH NAVIGATION
  // ============================================================

  DateTime _monthFromPage(int page) {
    final now = DateTime.now();

    final currentMonth = DateTime(
      now.year,
      now.month,
      1,
    );

    final difference =
        page - _currentPage;

    return DateTime(
      currentMonth.year,
      currentMonth.month + difference,
      1,
    );
  }

  int _pageFromMonth(DateTime month) {
    final now = DateTime.now();

    final currentMonth = DateTime(
      now.year,
      now.month,
      1,
    );

    final difference =
        (month.year - currentMonth.year) * 12 +
        (month.month - currentMonth.month);

    return _currentPage + difference;
  }

  bool _isCurrentMonth() {
    final now = DateTime.now();

    return selectedMonth.year == now.year &&
        selectedMonth.month == now.month;
  }

  void _previousMonth() {
    final targetPage =
        _pageController.page!.round() - 1;

    if (targetPage < 0) return;

    _pageController.animateToPage(
      targetPage,
      duration:
          const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _nextMonth() {
    final targetPage =
        _pageController.page!.round() + 1;

    if (targetPage > _currentPage) {
      return;
    }

    _pageController.animateToPage(
      targetPage,
      duration:
          const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _selectMonth() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      helpText: 'Pilih bulan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked == null) return;

    final targetMonth = DateTime(
      picked.year,
      picked.month,
      1,
    );

    final targetPage =
        _pageFromMonth(targetMonth);

    if (targetPage < 0 ||
        targetPage > _currentPage) {
      return;
    }

    await _pageController.animateToPage(
      targetPage,
      duration:
          const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: loading
                  ? Center(
                      child:
                          CircularProgressIndicator(
                        color: primaryPurple,
                      ),
                    )
                  : errorMessage != null
                      ? _buildError()
                      : RefreshIndicator(
                          color: primaryPurple,
                          onRefresh: loadReport,
                          child:
                              PageView.builder(
                            controller:
                                _pageController,
                            itemCount:
                                _currentPage + 1,
                            onPageChanged:
                                (page) {
                              setState(() {
                                selectedMonth =
                                    _monthFromPage(
                                  page,
                                );
                              });

                              loadReport();
                            },
                            itemBuilder:
                                (
                              context,
                              index,
                            ) {
                              return _buildReportContent();
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekapan',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight:
                        FontWeight.w700,
                    color: _textDark,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Ringkasan keuangan kamu',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  primaryPurple.withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: primaryPurple,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORT CONTENT
  // ============================================================

  Widget _buildReportContent() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        120,
      ),
      children: [
        _buildMonthSelector(),

        const SizedBox(height: 16),

        _buildBalanceCard(),

        const SizedBox(height: 18),

        _buildStats(),

        const SizedBox(height: 24),

        _buildTransactionHeader(),

        const SizedBox(height: 10),

        _buildTransactionSection(),
      ],
    );
  }

  // ============================================================
  // MONTH SELECTOR
  // ============================================================

  Widget _buildMonthSelector() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: _borderColor,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(
              Icons.chevron_left_rounded,
            ),
            color: _textDark,
          ),

          Expanded(
            child: GestureDetector(
              onTap: _selectMonth,
              child: Column(
                children: [
                  Text(
                    _monthName(
                      selectedMonth,
                    ),
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w700,
                      color: _textDark,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    'Pilih bulan',
                    style: TextStyle(
                      fontSize: 11,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          IconButton(
            onPressed: _isCurrentMonth()
                ? null
                : _nextMonth,
            icon: const Icon(
              Icons.chevron_right_rounded,
            ),
            color: _isCurrentMonth()
                ? (_isDark
                    ? const Color(0xFF52525B)
                    : Colors.grey.shade300)
                : _textDark,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BALANCE CARD
  // ============================================================

  Widget _buildBalanceCard() {
    final bool positive =
        monthlyBalance >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            primaryPurple,
            mediumPurple,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPurple
                .withOpacity(0.20),
            blurRadius: 18,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(0.15),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: const Icon(
                  Icons
                      .account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'Sisa Bulan Ini',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            _formatCurrency(
              monthlyBalance,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            positive
                ? 'Saldo akhir setelah pemasukan, pengeluaran, dan tabungan'
                : 'Pengeluaran dan alokasi tabungan melebihi saldo yang tersedia',
            style: TextStyle(
              color: Colors.white
                  .withOpacity(0.78),
              fontSize: 12,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  color: Colors.white70,
                  size: 17,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    'Saldo awal: ${_formatShortCurrency(openingBalance)}',
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT CARDS
  // ============================================================

  Widget _buildStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Pemasukan',
                amount: monthlyIncome,
                icon:
                    Icons.arrow_downward_rounded,
                color: incomeColor,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildStatCard(
                title: 'Pengeluaran',
                amount: monthlyExpense,
                icon:
                    Icons.arrow_upward_rounded,
                color: expenseColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _buildSavingsCard(),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required int amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: _borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color:
                      color.withOpacity(0.10),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Text(
            _formatShortCurrency(amount),
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVINGS CARD
  // ============================================================

  Widget _buildSavingsCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: _borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primaryPurple
                  .withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.savings_outlined,
              color: primaryPurple,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Tabungan Bulan Ini',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _formatCurrency(
                    monthlySavings,
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w800,
                    color: _textDark,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Saldo tabungan: ${_formatShortCurrency(totalSavingsBalance)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              if (monthlySavingsDeposit > 0)
                Text(
                  '+ ${_formatShortCurrency(monthlySavingsDeposit)}',
                  style:
                      const TextStyle(
                    color: incomeColor,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

              if (monthlySavingsWithdraw > 0)
                const SizedBox(height: 4),

              if (monthlySavingsWithdraw > 0)
                Text(
                  '- ${_formatShortCurrency(monthlySavingsWithdraw)}',
                  style:
                      const TextStyle(
                    color: expenseColor,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
            ],
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
      children: [
        Expanded(
          child: Text(
            'Riwayat Transaksi',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w700,
              color: _textDark,
            ),
          ),
        ),

        Text(
          '${monthlyTransactions.length} transaksi',
          style: TextStyle(
            fontSize: 12,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TRANSACTION SECTION
  // ============================================================

  Widget _buildTransactionSection() {
    if (monthlyTransactions.isEmpty) {
      return Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 34,
        ),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: _borderColor,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color:
                    _emptyIconBackground,
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: _textSecondary,
                size: 25,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w700,
                color: _textDark,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Belum ada transaksi pada ${_monthName(selectedMonth)}',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: _textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: _borderColor,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        padding:
            const EdgeInsets.symmetric(
          vertical: 4,
        ),
        itemCount:
            monthlyTransactions.length,
        separatorBuilder: (_, __) {
          return Divider(
            height: 1,
            indent: 72,
            endIndent: 16,
            color: _dividerColor,
          );
        },
        itemBuilder:
            (context, index) {
          return _buildTransactionItem(
            monthlyTransactions[index],
          );
        },
      ),
    );
  }

  // ============================================================
  // TRANSACTION ITEM
  // ============================================================

  Widget _buildTransactionItem(
    ReportTransaction transaction,
  ) {
    final bool isIncome =
        transaction.type == 'income';

    final bool isDeposit =
        transaction.type == 'deposit';

    final bool isWithdraw =
        transaction.type == 'withdraw';

    Color color;
    IconData icon;
    String title;
    String prefix;

    if (isIncome) {
      color = incomeColor;
      icon = Icons.arrow_downward_rounded;

      title =
          transaction.description.isNotEmpty
              ? transaction.description
              : transaction.category;

      prefix = '+';
    } else if (isDeposit) {
      color = primaryPurple;
      icon = Icons.savings_outlined;

      title =
          transaction.description.isNotEmpty
              ? transaction.description
              : 'Setoran Tabungan';

      prefix = '-';
    } else if (isWithdraw) {
      color = incomeColor;
      icon = Icons.savings_outlined;

      title =
          transaction.description.isNotEmpty
              ? transaction.description
              : 'Penarikan Tabungan';

      prefix = '+';
    } else {
      color = expenseColor;
      icon = Icons.arrow_upward_rounded;

      title =
          transaction.description.isNotEmpty
              ? transaction.description
              : transaction.category;

      prefix = '-';
    }

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  color.withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                    color: _textDark,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    if (transaction.isSavings)
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration:
                            BoxDecoration(
                          color: primaryPurple
                              .withOpacity(
                            0.08,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            5,
                          ),
                        ),
                        child: Text(
                          isDeposit
                              ? 'Tabungan'
                              : 'Tarik Tabungan',
                          style:
                              const TextStyle(
                            fontSize: 9,
                            color:
                                primaryPurple,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      )
                    else
                      Text(
                        transaction.category,
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              _textSecondary,
                        ),
                      ),

                    const SizedBox(width: 7),

                    Text(
                      _formatDate(
                        transaction.date,
                      ),
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            _textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Text(
            '$prefix${_formatShortCurrency(transaction.amount)}',
            textAlign:
                TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: expenseColor,
              size: 48,
            ),

            const SizedBox(height: 14),

            Text(
              'Gagal memuat rekapan',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w700,
                color: _textDark,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              errorMessage ??
                  'Terjadi kesalahan.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: _textSecondary,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: loadReport,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryPurple,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
              ),
              child:
                  const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// REPORT TRANSACTION
// ============================================================
//
// Model lokal khusus tampilan ReportScreen.
// Tidak mengubah TransactionModel/database.
//
// ============================================================

class ReportTransaction {
  final int id;
  final String type;
  final int amount;
  final String category;
  final String description;
  final DateTime date;
  final bool isSavings;

  ReportTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.isSavings = false,
  });

  // ------------------------------------------------------------
  // TRANSAKSI BIASA
  // ------------------------------------------------------------

  factory ReportTransaction.fromTransaction(
    TransactionModel transaction,
  ) {
    return ReportTransaction(
      id: transaction.id ?? 0,
      type: transaction.type,
      amount: transaction.amount,
      category: transaction.category,
      description: transaction.description,
      date: transaction.date,
      isSavings: false,
    );
  }

  // ------------------------------------------------------------
  // TRANSAKSI TABUNGAN
  // ------------------------------------------------------------

  factory ReportTransaction.savings({
    required int id,
    required String type,
    required int amount,
    required String description,
    required DateTime date,
  }) {
    return ReportTransaction(
      id: id,
      type: type,
      amount: amount,
      category: 'Tabungan',
      description: description,
      date: date,
      isSavings: true,
    );
  }
}