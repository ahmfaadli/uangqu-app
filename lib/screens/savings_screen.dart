import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../repositories/transaction_repository.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => SavingsScreenState();
}

class SavingsScreenState extends State<SavingsScreen> {
  final TransactionRepository _repository = TransactionRepository();

  bool loading = true;

  int totalSavings = 0;
  int currentBalance = 0;

  List<Map<String, dynamic>> monthlySavings = [];

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color mediumPurple = Color(0xFF8B5CF6);
  static const Color darkPurple = Color(0xFF5B21B6);

  static const Color successColor = Color(0xFF12B76A);
  static const Color dangerColor = Color(0xFFF04438);

  // ============================================================
  // THEME COLORS
  // ============================================================

  Color get pageBackground {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  Color get cardColor {
    return Theme.of(context).cardColor;
  }

  Color get primaryText {
    return Theme.of(context).colorScheme.onSurface;
  }

  Color get secondaryText {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF667085);
  }

  Color get borderColor {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? const Color(0xFF2A2A31)
        : const Color(0xFFF0EEF5);
  }

  Color get dividerColor {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? const Color(0xFF2A2A31)
        : const Color(0xFFF2F1F5);
  }

  Color get softPurple {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? const Color(0xFF2A2140)
        : const Color(0xFFF3E8FF);
  }

  Color get softGreen {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? const Color(0xFF143528)
        : const Color(0xFFEAFBF2);
  }

  Color get softRed {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? const Color(0xFF3A2020)
        : const Color(0xFFFFEFED);
  }

  bool get isDark {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadSavings();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> loadSavings() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final savings = await _repository.getTotalSavings();
      final balance = await _repository.getBalance();
      final monthly = await _repository.getAllMonthlySavings();

      if (!mounted) return;

      setState(() {
        totalSavings = savings;
        currentBalance = balance;
        monthlySavings = monthly;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Gagal memuat data tabungan: $e',
      );
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
  // FORMAT BULAN
  // ============================================================

  String formatMonth(
    dynamic year,
    dynamic month,
  ) {
    final int y =
        int.tryParse(year.toString()) ?? 0;

    final int m =
        int.tryParse(month.toString()) ?? 1;

    if (y <= 0) {
      return '-';
    }

    return DateFormat(
      'MMMM yyyy',
      'id_ID',
    ).format(
      DateTime(y, m),
    );
  }

  // ============================================================
  // TAMBAH TABUNGAN
  // ============================================================

  Future<void> openAddSavingsDialog() async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AddSavingsDialog(
          currentBalance: currentBalance,
          formatRupiah: formatRupiah,
          repository: _repository,
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      await loadSavings();

      if (!mounted) return;

      _showMessage(
        'Tabungan berhasil ditambahkan',
      );
    }
  }

  // ============================================================
  // AMBIL TABUNGAN
  // ============================================================

  Future<void> openWithdrawSavingsDialog() async {
    if (totalSavings <= 0) {
      _showMessage(
        'Belum ada saldo tabungan yang dapat diambil',
      );
      return;
    }

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return WithdrawSavingsDialog(
          totalSavings: totalSavings,
          formatRupiah: formatRupiah,
          repository: _repository,
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      await loadSavings();

      if (!mounted) return;

      _showMessage(
        'Tabungan berhasil diambil',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,

      // ========================================================
      // HEADER
      // ========================================================

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(86),
        child: Container(
          color: pageBackground,
          child: SafeArea(
            bottom: false,
            child: Padding(
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
                          'Tabungan',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                            height: 1.15,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Kelola dan pantau tabungan kamu',
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryText,
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
                      color: primaryPurple.withValues(
                        alpha: isDark ? 0.16 : 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.savings_rounded,
                      color: primaryPurple,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: RefreshIndicator(
        color: primaryPurple,
        backgroundColor: cardColor,
        displacement: 30,
        onRefresh: loadSavings,
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
                  _buildTotalSavingsCard(),

                  const SizedBox(height: 28),

                  _buildSectionHeader(),

                  const SizedBox(height: 14),

                  if (monthlySavings.isEmpty)
                    _buildEmptyState()
                  else
                    ...monthlySavings.map(
                      (item) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child:
                              _buildMonthlyCard(
                            item,
                          ),
                        );
                      },
                    ),
                ],
              ),
      ),
    );
  }

  // ============================================================
  // TOTAL TABUNGAN CARD
  // ============================================================

  Widget _buildTotalSavingsCard() {
    return Container(
      padding: const EdgeInsets.all(21),
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
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.16,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),

              const Spacer(),

              TextButton.icon(
                onPressed:
                    openAddSavingsDialog,
                style:
                    TextButton.styleFrom(
                  backgroundColor:
                      Colors.white.withValues(
                    alpha: 0.15,
                  ),
                  foregroundColor:
                      Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.add_rounded,
                  size: 18,
                ),
                label: const Text(
                  'Tambah',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          const Text(
            'Total Tabungan',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 7),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatRupiah(totalSavings),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white70,
                size: 16,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  'Saldo tersedia: ${formatRupiah(currentBalance)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: totalSavings > 0
                  ? openWithdrawSavingsDialog
                  : null,
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    Colors.white,
                disabledForegroundColor:
                    Colors.white38,
                side: const BorderSide(
                  color: Colors.white38,
                ),
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 11,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
              ),
              icon: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 17,
              ),
              label: const Text(
                'Ambil Tabungan',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Rekap Tabungan',
          style: TextStyle(
            color: primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          'Riwayat tabungan berdasarkan bulan',
          style: TextStyle(
            color: secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MONTHLY CARD
  // ============================================================

  Widget _buildMonthlyCard(
    Map<String, dynamic> item,
  ) {
    final int deposit =
        (item['deposit'] as num?)?.toInt() ?? 0;

    final int withdraw =
        (item['withdraw'] as num?)?.toInt() ?? 0;

    final int total =
        deposit - withdraw;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.12 : 0.035,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: softPurple,
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: primaryPurple,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatMonth(
                        item['year'],
                        item['month'],
                      ),
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'Pergerakan tabungan',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 11.5,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Flexible(
                child: Text(
                  formatRupiah(total),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  textAlign:
                      TextAlign.right,
                  style: TextStyle(
                    color: total >= 0
                        ? successColor
                        : dangerColor,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            height: 1,
            color: dividerColor,
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildMonthlyInfo(
                  icon: Icons.add_circle_outline_rounded,
                  iconColor: successColor,
                  backgroundColor: softGreen,
                  label: 'Ditabung',
                  value: formatRupiah(deposit),
                ),
              ),

              Container(
                width: 1,
                height: 35,
                color: borderColor,
              ),

              Expanded(
                child: _buildMonthlyInfo(
                  icon: Icons.remove_circle_outline_rounded,
                  iconColor: dangerColor,
                  backgroundColor: softRed,
                  label: 'Diambil',
                  value: formatRupiah(withdraw),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MONTHLY INFO
  // ============================================================

  Widget _buildMonthlyInfo({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 16,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 10.5,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 11.5,
                    fontWeight:
                        FontWeight.w700,
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
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: softPurple,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.savings_outlined,
              color: primaryPurple,
              size: 30,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            'Belum ada tabungan',
            style: TextStyle(
              color: primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Tekan tombol Tambah pada kartu total tabungan untuk mulai menabung.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondaryText,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DIALOG TAMBAH TABUNGAN
// ============================================================================

class AddSavingsDialog extends StatefulWidget {
  final int currentBalance;
  final String Function(int) formatRupiah;
  final TransactionRepository repository;

  const AddSavingsDialog({
    super.key,
    required this.currentBalance,
    required this.formatRupiah,
    required this.repository,
  });

  @override
  State<AddSavingsDialog> createState() =>
      _AddSavingsDialogState();
}

class _AddSavingsDialogState
    extends State<AddSavingsDialog> {
  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  bool saving = false;

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get dialogColor =>
      Theme.of(context).colorScheme.surface;

  Color get primaryText =>
      Theme.of(context).colorScheme.onSurface;

  Color get secondaryText {
    return isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF667085);
  }

  Color get inputColor {
    return isDark
        ? const Color(0xFF111114)
        : const Color(0xFFF8F7FC);
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> save() async {
    if (saving) return;

    final String cleanAmount =
        amountController.text
            .trim()
            .replaceAll('.', '')
            .replaceAll(',', '')
            .replaceAll(' ', '');

    final int? amount =
        int.tryParse(cleanAmount);

    if (amount == null || amount <= 0) {
      _showMessage(
        'Nominal tabungan tidak valid',
      );
      return;
    }

    if (amount > widget.currentBalance) {
      _showMessage(
        'Nominal melebihi saldo saat ini',
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final bool success =
          await widget.repository.addSavings(
        amount: amount,
        description:
            descriptionController.text.trim(),
      );

      if (!mounted) return;

      if (!success) {
        setState(() {
          saving = false;
        });

        _showMessage(
          'Tabungan gagal ditambahkan',
        );

        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      _showMessage(
        'Gagal menambahkan tabungan: $e',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: dialogColor,
      elevation: 0,
      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(
          maxWidth: 430,
          maxHeight: 650,
        ),
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            22,
            22,
            22,
            20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 18),

              _buildBalanceCard(),

              const SizedBox(height: 18),

              _buildLabel('Nominal'),

              const SizedBox(height: 8),

              TextField(
                controller: amountController,
                keyboardType:
                    TextInputType.number,
                autofocus: true,
                enabled: !saving,
                decoration:
                    _inputDecoration(
                  hintText:
                      'Contoh: 500000',
                  prefixText: 'Rp ',
                  color:
                      SavingsScreenState
                          .primaryPurple,
                ),
              ),

              const SizedBox(height: 16),

              _buildLabel('Keterangan'),

              const SizedBox(height: 8),

              TextField(
                controller:
                    descriptionController,
                textCapitalization:
                    TextCapitalization
                        .sentences,
                maxLines: 2,
                enabled: !saving,
                decoration:
                    _inputDecoration(
                  hintText:
                      'Contoh: Tabungan bulanan',
                  color:
                      SavingsScreenState
                          .primaryPurple,
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: saving
                          ? null
                          : () {
                              Navigator.of(
                                context,
                              ).pop(false);
                            },
                      style:
                          TextButton.styleFrom(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 13,
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: secondaryText,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          saving ? null : save,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            SavingsScreenState
                                .primaryPurple,
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 13,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                      ),
                      child: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                color:
                                    Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Simpan',
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2A2140)
                : const Color(0xFFF3E8FF),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.savings_rounded,
            color:
                SavingsScreenState
                    .primaryPurple,
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            'Tambah Tabungan',
            style: TextStyle(
              color: primaryText,
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BALANCE CARD
  // ============================================================

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_rounded,
            color: secondaryText,
            size: 19,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              'Saldo saat ini',
              style: TextStyle(
                color: secondaryText,
                fontSize: 12,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          Flexible(
            child: Text(
              widget.formatRupiah(
                widget.currentBalance,
              ),
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              textAlign:
                  TextAlign.right,
              style: TextStyle(
                color: primaryText,
                fontSize: 13,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: primaryText,
        fontSize: 12,
        fontWeight:
            FontWeight.w700,
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required Color color,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      prefixStyle: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight:
            FontWeight.w800,
      ),
      filled: true,
      fillColor: inputColor,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            BorderSide.none,
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            BorderSide.none,
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide(
          color: color,
          width: 1.5,
        ),
      ),
    );
  }
}

// ============================================================================
// DIALOG AMBIL TABUNGAN
// ============================================================================

class WithdrawSavingsDialog
    extends StatefulWidget {
  final int totalSavings;
  final String Function(int) formatRupiah;
  final TransactionRepository repository;

  const WithdrawSavingsDialog({
    super.key,
    required this.totalSavings,
    required this.formatRupiah,
    required this.repository,
  });

  @override
  State<WithdrawSavingsDialog> createState() =>
      _WithdrawSavingsDialogState();
}

class _WithdrawSavingsDialogState
    extends State<WithdrawSavingsDialog> {
  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  bool saving = false;

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get dialogColor =>
      Theme.of(context).colorScheme.surface;

  Color get primaryText =>
      Theme.of(context).colorScheme.onSurface;

  Color get secondaryText {
    return isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF667085);
  }

  Color get inputColor {
    return isDark
        ? const Color(0xFF111114)
        : const Color(0xFFF8F7FC);
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // WITHDRAW
  // ============================================================

  Future<void> withdraw() async {
    if (saving) return;

    final String cleanAmount =
        amountController.text
            .trim()
            .replaceAll('.', '')
            .replaceAll(',', '')
            .replaceAll(' ', '');

    final int? amount =
        int.tryParse(cleanAmount);

    if (amount == null || amount <= 0) {
      _showMessage(
        'Nominal tidak valid',
      );
      return;
    }

    if (amount > widget.totalSavings) {
      _showMessage(
        'Nominal melebihi saldo tabungan',
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final bool success =
          await widget.repository.withdrawSavings(
        amount: amount,
        description:
            descriptionController.text.trim(),
      );

      if (!mounted) return;

      if (!success) {
        setState(() {
          saving = false;
        });

        _showMessage(
          'Gagal mengambil tabungan',
        );

        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      _showMessage(
        'Gagal mengambil tabungan: $e',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: dialogColor,
      elevation: 0,
      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(
          maxWidth: 430,
          maxHeight: 650,
        ),
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            22,
            22,
            22,
            20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 18),

              _buildBalanceCard(),

              const SizedBox(height: 18),

              _buildLabel('Nominal'),

              const SizedBox(height: 8),

              TextField(
                controller: amountController,
                keyboardType:
                    TextInputType.number,
                autofocus: true,
                enabled: !saving,
                decoration:
                    _inputDecoration(
                  hintText:
                      'Contoh: 300000',
                  prefixText: 'Rp ',
                  color:
                      SavingsScreenState
                          .successColor,
                ),
              ),

              const SizedBox(height: 16),

              _buildLabel('Keterangan'),

              const SizedBox(height: 8),

              TextField(
                controller:
                    descriptionController,
                textCapitalization:
                    TextCapitalization
                        .sentences,
                maxLines: 2,
                enabled: !saving,
                decoration:
                    _inputDecoration(
                  hintText:
                      'Contoh: Digunakan untuk kebutuhan',
                  color:
                      SavingsScreenState
                          .successColor,
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: saving
                          ? null
                          : () {
                              Navigator.of(
                                context,
                              ).pop(false);
                            },
                      style:
                          TextButton.styleFrom(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 13,
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: secondaryText,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          saving
                              ? null
                              : withdraw,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            SavingsScreenState
                                .successColor,
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 13,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                      ),
                      child: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                color:
                                    Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Ambil',
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF143528)
                : const Color(0xFFEAFBF2),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color:
                SavingsScreenState
                    .successColor,
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            'Ambil Tabungan',
            style: TextStyle(
              color: primaryText,
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BALANCE CARD
  // ============================================================

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.savings_rounded,
            color:
                SavingsScreenState
                    .primaryPurple,
            size: 19,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              'Saldo tabungan',
              style: TextStyle(
                color: secondaryText,
                fontSize: 12,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          Flexible(
            child: Text(
              widget.formatRupiah(
                widget.totalSavings,
              ),
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              textAlign:
                  TextAlign.right,
              style: const TextStyle(
                color:
                    SavingsScreenState
                        .primaryPurple,
                fontSize: 13,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: primaryText,
        fontSize: 12,
        fontWeight:
            FontWeight.w700,
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required Color color,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      prefixStyle: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight:
            FontWeight.w800,
      ),
      filled: true,
      fillColor: inputColor,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            BorderSide.none,
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            BorderSide.none,
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide(
          color: color,
          width: 1.5,
        ),
      ),
    );
  }
}