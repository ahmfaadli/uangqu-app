import '../database/database_helper.dart';
import '../models/saving_model.dart';

class SavingRepository {
  final DatabaseHelper _databaseHelper =
      DatabaseHelper.instance;

  // ============================================================
  // INSERT SAVING
  // ============================================================

  Future<int> insertSaving(
    SavingModel saving,
  ) async {
    final db = await _databaseHelper.database;

    return await db.insert(
      'savings',
      saving.toMap(),
    );
  }

  // ============================================================
  // GET ALL SAVINGS
  // ============================================================

  Future<List<SavingModel>> getSavings() async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'savings',
      orderBy: 'id DESC',
    );

    return result
        .map(
          (item) => SavingModel.fromMap(item),
        )
        .toList();
  }

  // ============================================================
  // UPDATE SAVING AMOUNT
  // ============================================================

  Future<int> updateSavingAmount(
    int id,
    int currentAmount,
  ) async {
    final db = await _databaseHelper.database;

    return await db.update(
      'savings',
      {
        'current_amount': currentAmount,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // DELETE SAVING
  // ============================================================

  Future<int> deleteSaving(int id) async {
    final db = await _databaseHelper.database;

    return await db.delete(
      'savings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}