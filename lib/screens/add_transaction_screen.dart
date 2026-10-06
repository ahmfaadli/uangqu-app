import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends State<AddTransactionScreen> {
  // ============================================================
  // REPOSITORY
  // ============================================================

  final TransactionRepository _repository =
      TransactionRepository();

  // ============================================================
  // CONTROLLER
  // ============================================================

  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  // ============================================================
  // DATA
  // ============================================================

  String type = 'income';
  String category = 'Gaji';
  DateTime selectedDate = DateTime.now();

  bool loading = false;

  final List<String> incomeCategories = [
    'Gaji',
    'Bonus',
    'Freelance',
    'Penjualan',
    'Lainnya',
  ];

  final List<String> expenseCategories = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Lainnya',
  ];

  // ============================================================
  // THEME COLORS
  // ============================================================

  static const Color primaryPurple =
      Color(0xFF7C3AED);

  static const Color mediumPurple =
      Color(0xFF8B5CF6);

  static const Color darkPurple =
      Color(0xFF5B21B6);

  static const Color successColor =
      Color(0xFF12B76A);

  static const Color dangerColor =
      Color(0xFFF04438);

  // ============================================================
  // THEME HELPERS
  // ============================================================

  bool get isDark =>
      Theme.of(context).brightness ==
      Brightness.dark;

  Color get pageBackground =>
      Theme.of(context).scaffoldBackgroundColor;

  Color get cardColor =>
      Theme.of(context).cardColor;

  Color get primaryText =>
      Theme.of(context).colorScheme.onSurface;

  Color get secondaryText {
    return isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF667085);
  }

  Color get hintColor {
    return isDark
        ? const Color(0xFF71717A)
        : const Color(0xFF98A2B3);
  }

  Color get borderColor {
    return isDark
        ? const Color(0xFF2A2A31)
        : const Color(0xFFE4E7EC);
  }

  Color get inputColor {
    return isDark
        ? const Color(0xFF1C1C21)
        : Colors.white;
  }

  Color get softPurple {
    return isDark
        ? const Color(0xFF2A2140)
        : const Color(0xFFF3E8FF);
  }

  Color get headerColor {
    return isDark
        ? const Color(0xFF241B36)
        : const Color(0xFFF3E8FF);
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
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
  // SAVE TRANSACTION
  // ============================================================

  Future<void> saveTransaction() async {
    if (loading) return;

    final amountText =
        amountController.text.trim();

    if (amountText.isEmpty) {
      showMessage('Nominal wajib diisi');
      return;
    }

    // Hilangkan titik, koma, dan spasi
    final cleanAmount = amountText
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll(' ', '');

    final amount = int.tryParse(cleanAmount);

    if (amount == null || amount <= 0) {
      showMessage('Nominal tidak valid');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
    });

    try {
      final transaction = TransactionModel(
        type: type,
        amount: amount,
        category: category,
        description:
            descriptionController.text.trim(),
        date: selectedDate,
        createdAt: DateTime.now(),
      );

      await _repository.insertTransaction(
        transaction,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage(
        'Gagal menyimpan transaksi: $e',
      );
    }
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

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
  // SELECT DATE
  // ============================================================

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        final theme =
            Theme.of(context);

        return Theme(
          data: theme.copyWith(
            colorScheme:
                theme.colorScheme.copyWith(
              primary: primaryPurple,
              onPrimary: Colors.white,
              surface: theme.cardColor,
              onSurface:
                  theme.colorScheme.onSurface,
            ),
            dialogTheme:
                DialogThemeData(
              backgroundColor:
                  theme.cardColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final categories = type == 'income'
        ? incomeCategories
        : expenseCategories;

    return Scaffold(
      backgroundColor: pageBackground,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_rounded,
            color: primaryText,
          ),
        ),

        title: Text(
          'Tambah Transaksi',
          style: TextStyle(
            color: primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              _buildHeader(),

              const SizedBox(height: 24),

              // ==================================================
              // JENIS TRANSAKSI
              // ==================================================

              _buildSectionLabel(
                'Jenis Transaksi',
              ),

              const SizedBox(height: 10),

              _buildTransactionType(),

              const SizedBox(height: 24),

              // ==================================================
              // NOMINAL
              // ==================================================

              _buildSectionLabel(
                'Nominal',
              ),

              const SizedBox(height: 10),

              _buildAmountField(),

              const SizedBox(height: 22),

              // ==================================================
              // KATEGORI
              // ==================================================

              _buildSectionLabel(
                'Kategori',
              ),

              const SizedBox(height: 10),

              _buildCategoryField(
                categories,
              ),

              const SizedBox(height: 22),

              // ==================================================
              // KETERANGAN
              // ==================================================

              _buildSectionLabel(
                'Keterangan',
              ),

              const SizedBox(height: 10),

              _buildDescriptionField(),

              const SizedBox(height: 22),

              // ==================================================
              // TANGGAL
              // ==================================================

              _buildSectionLabel(
                'Tanggal',
              ),

              const SizedBox(height: 10),

              _buildDateField(),

              const SizedBox(height: 30),

              // ==================================================
              // SAVE BUTTON
              // ==================================================

              _buildSaveButton(),
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
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: Icon(
              type == 'income'
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: type == 'income'
                  ? successColor
                  : dangerColor,
              size: 23,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Catat transaksi Anda',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Masukkan informasi transaksi dengan lengkap.',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 11,
                    height: 1.4,
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
  // SECTION LABEL
  // ============================================================

  Widget _buildSectionLabel(
    String title,
  ) {
    return Text(
      title,
      style: TextStyle(
        color: primaryText,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // ============================================================
  // TRANSACTION TYPE
  // ============================================================

  Widget _buildTransactionType() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeButton(
            title: 'Pemasukan',
            icon:
                Icons.arrow_downward_rounded,
            selected:
                type == 'income',
            color: successColor,
            onTap: () {
              setState(() {
                type = 'income';
                category =
                    incomeCategories.first;
              });
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildTypeButton(
            title: 'Pengeluaran',
            icon:
                Icons.arrow_upward_rounded,
            selected:
                type == 'expense',
            color: dangerColor,
            onTap: () {
              setState(() {
                type = 'expense';
                category =
                    expenseCategories.first;
              });
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TYPE BUTTON
  // ============================================================

  Widget _buildTypeButton({
    required String title,
    required IconData icon,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(15),
        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 180,
          ),
          height: 54,
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(
                    alpha:
                        isDark ? 0.15 : 0.09,
                  )
                : cardColor,
            borderRadius:
                BorderRadius.circular(15),
            border: Border.all(
              color: selected
                  ? color
                  : borderColor,
              width:
                  selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: selected
                    ? color
                    : secondaryText,
              ),

              const SizedBox(width: 7),

              Text(
                title,
                style: TextStyle(
                  color: selected
                      ? color
                      : secondaryText,
                  fontSize: 13,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AMOUNT FIELD
  // ============================================================

  Widget _buildAmountField() {
    return TextField(
      controller: amountController,
      keyboardType:
          TextInputType.number,

      style: TextStyle(
        color: primaryText,
        fontSize: 16,
        fontWeight:
            FontWeight.w600,
      ),

      decoration: InputDecoration(
        hintText: 'Contoh: 50000',

        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 14,
          fontWeight:
              FontWeight.w400,
        ),

        prefixText: 'Rp ',

        prefixStyle: const TextStyle(
          color: primaryPurple,
          fontSize: 16,
          fontWeight:
              FontWeight.w700,
        ),

        filled: true,
        fillColor: inputColor,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide:
              const BorderSide(
            color: primaryPurple,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY FIELD
  // ============================================================

  Widget _buildCategoryField(
    List<String> categories,
  ) {
    return DropdownButtonFormField<String>(
      value: categories.contains(category)
          ? category
          : categories.first,

      decoration: InputDecoration(
        filled: true,
        fillColor: inputColor,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide:
              const BorderSide(
            color: primaryPurple,
            width: 1.5,
          ),
        ),
      ),

      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: primaryPurple,
      ),

      dropdownColor: cardColor,

      borderRadius:
          BorderRadius.circular(15),

      items: categories.map(
        (item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                color: primaryText,
                fontSize: 14,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          );
        },
      ).toList(),

      onChanged: (value) {
        if (value == null) return;

        setState(() {
          category = value;
        });
      },
    );
  }

  // ============================================================
  // DESCRIPTION FIELD
  // ============================================================

  Widget _buildDescriptionField() {
    return TextField(
      controller:
          descriptionController,
      maxLines: 3,

      style: TextStyle(
        color: primaryText,
        fontSize: 14,
      ),

      decoration: InputDecoration(
        hintText:
            'Contoh: Makan siang',

        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 13,
        ),

        filled: true,
        fillColor: inputColor,

        contentPadding:
            const EdgeInsets.all(16),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide:
              const BorderSide(
            color: primaryPurple,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _buildDateField() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: selectDate,
        borderRadius:
            BorderRadius.circular(15),
        child: Container(
          width: double.infinity,

          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),

          decoration: BoxDecoration(
            color: inputColor,
            borderRadius:
                BorderRadius.circular(15),
            border: Border.all(
              color: borderColor,
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration:
                    BoxDecoration(
                  color: softPurple,
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: primaryPurple,
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
                      'Tanggal transaksi',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      DateFormat(
                        'dd MMMM yyyy',
                        'id_ID',
                      ).format(
                        selectedDate,
                      ),
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: hintColor,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed:
            loading ? null : saveTransaction,

        style:
            FilledButton.styleFrom(
          backgroundColor:
              primaryPurple,

          disabledBackgroundColor:
              primaryPurple.withValues(
            alpha: 0.55,
          ),

          foregroundColor:
              Colors.white,

          elevation: 0,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),

        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 20,
                  ),

                  SizedBox(width: 8),

                  Text(
                    'Simpan Transaksi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}