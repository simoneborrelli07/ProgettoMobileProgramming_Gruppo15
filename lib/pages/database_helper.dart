import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../data_model.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'esami.db'),
      onCreate: (db, version) async {
        await db.execute('DROP TABLE IF EXISTS esami');
        await db.execute(
          'CREATE TABLE esami (Nome TEXT PRIMARY KEY, Corso_di_studi TEXT, CFU INTEGER, Data TEXT, Ora TEXT, Tipologia TEXT, Docente TEXT, Voto INTEGER, Categorie TEXT, Diario TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertExam(Exam esame) async {
    final db = await database;
    await db.insert(
      'esami',
      esame.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Exam>> exams() async {
    final db = await database;
    final List<Map<String, dynamic>> esamiMaps = await db.query('esami');

    return [
      for (final esamiMap in esamiMaps) Exam.fromMap(esamiMap),
    ];
  }

  Future<void> updateExam(Exam esame) async {
    final db = await database;
    await db.update(
      'esami',
      esame.toMap(),
      where: 'Nome = ?',
      whereArgs: [esame.name],
    );
  }

  Future<void> deleteExam(String name) async {
    final db = await database;
    await db.delete(
      'esami',
      where: 'Nome = ?',
      whereArgs: [name],
    );
  }
}
