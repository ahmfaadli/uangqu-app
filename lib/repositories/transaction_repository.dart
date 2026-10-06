
import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // ============================================================
  // MEMASTIKAN TABEL RIWAYAT TABUNGAN TERSEDIA
  // ============================================================

  Future<void> _ensureSavingsTable() async {
    final db = await _databaseHelper.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS savings_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount INTEGER NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ============================================================
  // HELPER TANGGAL
  // ============================================================

  DateTime _monthStart(int year, int month) {
    return DateTime(year, month, 1);
  }

  DateTime _nextMonthStart(int year, int month) {
    return DateTime(year, month + 1, 1);
  }

  List<String> _monthDateRange(int year, int month) {
    return [
      _monthStart(year, month).toIso8601String(),
      _nextMonthStart(year, month).toIso8601String(),
    ];
  }

  int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ============================================================
  // TAMBAH TRANSAKSI
  // ============================================================

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await _databaseHelper.database;
    return db.insert('transactions', transaction.toMap());
  }

  // ============================================================
  // AMBIL SEMUA TRANSAKSI
  // ============================================================

  Future<List<TransactionModel>> getTransactions() async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'transactions',
      orderBy: 'date DESC, id DESC',
    );

    return result.map(TransactionModel.fromMap).toList();
  }

  // ============================================================
  // TRANSAKSI TERBARU
  // ============================================================

  Future<List<TransactionModel>> getRecentTransactions({
    int limit = 5,
  }) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'transactions',
      orderBy: 'date DESC, id DESC',
      limit: limit,
    );

    return result.map(TransactionModel.fromMap).toList();
  }

  // ============================================================
  // HAPUS TRANSAKSI
  // ============================================================

  Future<int> deleteTransaction(int id) async {
    final db = await _databaseHelper.database;

    return db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // TOTAL PEMASUKAN KESELURUHAN
  // ============================================================

  Future<int> getTotalIncome() async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE type = ?
    ''', ['income']);

    return _toInt(result.first['total']);
  }

  // ============================================================
  // TOTAL PENGELUARAN KESELURUHAN
  // ============================================================

  Future<int> getTotalExpense() async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE type = ?
    ''', ['expense']);

    return _toInt(result.first['total']);
  }

  // ============================================================
  // SALDO TRANSAKSI SEBELUM ALOKASI TABUNGAN
  // ============================================================

  Future<int> getTransactionBalance() async {
    final income = await getTotalIncome();
    final expense = await getTotalExpense();

    return income - expense;
  }

  // ============================================================
  // TOTAL TABUNGAN BERSIH
  // Setoran menambah tabungan, penarikan menguranginya.
  // ============================================================

  Future<int> getTotalSavings() async {
    await _ensureSavingsTable();

    final db = await _databaseHelper.database;

    final result = await db.rawQuery('''
      SELECT COALESCE(
        SUM(
          CASE
            WHEN type = 'deposit' THEN amount
            WHEN type = 'withdraw' THEN -amount
            ELSE 0
          END
        ),
        0
      ) AS total
      FROM savings_transactions
    ''');

    return _toInt(result.first['total']);
  }

  // ============================================================
  // SALDO YANG TERSEDIA
  // Saldo = pemasukan - pengeluaran - tabungan bersih.
  // ============================================================

  Future<int> getBalance() async {
    final transactionBalance = await getTransactionBalance();
    final savings = await getTotalSavings();

    return transactionBalance - savings;
  }

  // ============================================================
  // TRANSAKSI BERDASARKAN BULAN
  // ============================================================

  Future<List<TransactionModel>> getTransactionsByMonth({
    required int year,
    required int month,
  }) async {
    final db = await _databaseHelper.database;
    final range = _monthDateRange(year, month);

    final result = await db.query(
      'transactions',
      where: 'date >= ? AND date < ?',
      whereArgs: range,
      orderBy: 'date DESC, id DESC',
    );

    return result.map(TransactionModel.fromMap).toList();
  }

  // ============================================================
  // PEMASUKAN BULANAN
  // ============================================================

  Future<int> getMonthlyIncome({
    required int year,
    required int month,
  }) async {
    final db = await _databaseHelper.database;
    final range = _monthDateRange(year, month);

    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE type = ?
        AND date >= ?
        AND date < ?
    ''', ['income', ...range]);

    return _toInt(result.first['total']);
  }

  // ============================================================
  // PENGELUARAN BULANAN
  // ============================================================

  Future<int> getMonthlyExpense({
    required int year,
    required int month,
  }) async {
    final db = await _databaseHelper.database;
    final range = _monthDateRange(year, month);

    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE type = ?
        AND date >= ?
        AND date < ?
    ''', ['expense', ...range]);

    return _toInt(result.first['total']);
  }

  // ============================================================
  // PENGELUARAN BERDASARKAN KATEGORI BULAN TERPILIH
  // ============================================================

  Future<Map<String, int>> getExpenseByCategory({
    required int year,
    required int month,
  }) async {
    final db = await _databaseHelper.database;
    final range = _monthDateRange(year, month);

    final result = await db.rawQuery('''
      SELECT category, COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE type = ?
        AND date >= ?
        AND date < ?
      GROUP BY category
      ORDER BY total DESC
    ''', ['expense', ...range]);

    final Map<String, int> categories = {};

    for (final row in result) {
      final category = row['category']?.toString() ?? 'Lainnya';
      categories[category] = _toInt(row['total']);
    }

    return categories;
  }

  // ============================================================
  // MENAMBAH TABUNGAN
  // ============================================================

  Future<bool> addSavings({
    required int amount,
    String description = '',
    DateTime? date,
  }) async {
    if (amount <= 0) return false;

    await _ensureSavingsTable();

    final currentBalance = await getBalance();

    if (amount > currentBalance) return false;

    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final savingDate = date ?? now;

    await db.insert('savings_transactions', {
      'type': 'deposit',
      'amount': amount,
      'description': description,
      'date': savingDate.toIso8601String(),
      'created_at': now.toIso8601String(),
    });

    return true;
  }

  // ============================================================
  // MENARIK TABUNGAN
  // ============================================================

  Future<bool> withdrawSavings({
    required int amount,
    String description = '',
    DateTime? date,
  }) async {
    if (amount <= 0) return false;

    await _ensureSavingsTable();

    final currentSavings = await getTotalSavings();

    if (amount > currentSavings) return false;

    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final savingDate = date ?? now;

    await db.insert('savings_transactions', {
      'type': 'withdraw',
      'amount': amount,
      'description': description,
      'date': savingDate.toIso8601String(),
      'created_at': now.toIso8601String(),
    });

    return true;
  }

  // ============================================================
  // SEMUA RIWAYAT TABUNGAN
  // ============================================================

  Future<List<Map<String, dynamic>>> getSavingsHistory() async {
    await _ensureSavingsTable();

    final db = await _databaseHelper.database;

    return db.query(
      'savings_transactions',
      orderBy: 'date DESC, id DESC',
    );
  }

  // ============================================================
  // RIWAYAT TABUNGAN BULAN TERPILIH
  // ============================================================

  Future<List<Map<String, dynamic>>> getSavingsByMonth({
    required int year,
    required int month,
  }) async {
    await _ensureSavingsTable();

    final db = await _databaseHelper.database;
    final range = _monthDateRange(year, month);

    return db.query(
      'savings_transactions',
      where: 'date >= ? AND date < ?',
      whereArgs: range,
      orderBy: 'date DESC, id DESC',
    );
  }

  // ============================================================
  // REKAP SETORAN DAN PENARIKAN TABUNGAN PER BULAN
  // ============================================================

  Future<Map<String, int>> getMonthlySavings({
    required int year,
    required int month,
  }) async {
    await _ensureSavingsTable();

    final db = await _databaseHelper.database;
    final range = _monthDateRange(year, month);

    final result = await db.rawQuery('''
      SELECT
        COALESCE(
          SUM(CASE WHEN type = 'deposit' THEN amount ELSE 0 END),
          0
        ) AS deposit,
        COALESCE(
          SUM(CASE WHEN type = 'withdraw' THEN amount ELSE 0 END),
          0
        ) AS withdraw
      FROM savings_transactions
      WHERE date >= ? AND date < ?
    ''', range);

    final row = result.first;

    return {
      'deposit': _toInt(row['deposit']),
      'withdraw': _toInt(row['withdraw']),
    };
  }

  // ============================================================
  // REKAP TABUNGAN SEMUA BULAN
  // ============================================================

  Future<List<Map<String, dynamic>>> getAllMonthlySavings() async {
    await _ensureSavingsTable();

    final db = await _databaseHelper.database;

    return db.rawQuery('''
      SELECT
        strftime('%Y', date) AS year,
        strftime('%m', date) AS month,
        COALESCE(
          SUM(CASE WHEN type = 'deposit' THEN amount ELSE 0 END),
          0
        ) AS deposit,
        COALESCE(
          SUM(CASE WHEN type = 'withdraw' THEN amount ELSE 0 END),
          0
        ) AS withdraw
      FROM savings_transactions
      GROUP BY
        strftime('%Y', date),
        strftime('%m', date)
      ORDER BY year DESC, month DESC
    ''');
  }
}