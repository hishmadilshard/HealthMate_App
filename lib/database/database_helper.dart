import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/health_records/models/health_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  // ============================================================
  // ⭐ INIT DATABASE WITH TRY–CATCH
  // ============================================================
  Future<void> init() async {
    try {
      if (_db != null) return;

      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'healthmate.db');

      _db = await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) async {
          try {
            await _insertDummyIfEmpty(db);
          } catch (e) {
            print("❌ Error inserting dummy data: $e");
          }
        },
      );

      print("✅ Database initialized successfully");
    } catch (e) {
      print("❌ Database init error: $e");
    }
  }

  // ============================================================
  // ⭐ CREATE TABLE
  // ============================================================
  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE health_records(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          steps INTEGER NOT NULL,
          calories INTEGER NOT NULL,
          water INTEGER NOT NULL
        )
      ''');
      print("✅ Table created successfully");
    } catch (e) {
      print("❌ Error creating table: $e");
    }
  }


  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      await db.execute("DROP TABLE IF EXISTS health_records");
      await _onCreate(db, newVersion);
      print("🔄 Database upgraded successfully");
    } catch (e) {
      print("❌ Error during upgrade: $e");
    }
  }

  // ============================================================
  // ⭐ DUMMY DATA INSERTION
  // ============================================================
  Future<void> _insertDummyIfEmpty(Database db) async {
    try {
      final count = Sqflite.firstIntValue(
          await db.rawQuery("SELECT COUNT(*) FROM health_records"));

      if (count != 0) return;

      final dummyRecords = [
        {'date': '2025-11-16', 'steps': 8500, 'calories': 1750, 'water': 1800},
        {'date': '2025-11-15', 'steps': 9200, 'calories': 1890, 'water': 2000},
        {'date': '2025-11-14', 'steps': 7600, 'calories': 1650, 'water': 1500},
        {'date': '2025-11-13', 'steps': 10000, 'calories': 2100, 'water': 2200},
        {'date': '2025-11-12', 'steps': 6800, 'calories': 1590, 'water': 1400},
        {'date': '2025-11-11', 'steps': 12000, 'calories': 2300, 'water': 2500},
        {'date': '2025-11-10', 'steps': 8200, 'calories': 1900, 'water': 1600},
      ];

      for (var record in dummyRecords) {
        await db.insert("health_records", record);
      }

      print("📌 Dummy data inserted");
    } catch (e) {
      print("❌ Error inserting dummy data: $e");
    }
  }

  Database get database => _db!;

  // ============================================================
  // ⭐ GET ALL RECORDS
  // ============================================================
  Future<List<HealthRecord>> getRecords() async {
    try {
      final res = await database.query('health_records', orderBy: 'date DESC');
      return res.map((e) => HealthRecord.fromMap(e)).toList();
    } catch (e) {
      print("❌ Error fetching records: $e");
      return [];
    }
  }

  // ============================================================
  // ⭐ INSERT RECORD
  // ============================================================
  Future<void> insertRecord(HealthRecord record) async {
    try {
      await database.insert(
        'health_records',
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("✅ Record inserted successfully");
    } catch (e) {
      print("❌ Error inserting record: $e");
    }
  }

  // ============================================================
  // ⭐ UPDATE RECORD
  // ============================================================
  Future<void> updateRecord(HealthRecord record) async {
    try {
      await database.update(
        'health_records',
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
      print("🔄 Record updated successfully");
    } catch (e) {
      print("❌ Error updating record: $e");
    }
  }

  // ============================================================
  // ⭐ DELETE RECORD
  // ============================================================
  Future<void> deleteRecord(int id) async {
    try {
      await database.delete(
        'health_records',
        where: 'id = ?',
        whereArgs: [id],
      );
      print("🗑️ Record deleted");
    } catch (e) {
      print("❌ Error deleting record: $e");
    }
  }

  // ============================================================
  // ⭐ GET RECORD BY DATE
  // ============================================================
  Future<List<HealthRecord>> getRecordsByDate(String date) async {
    try {
      final res = await database.query(
        'health_records',
        where: 'date LIKE ?',
        whereArgs: ['%$date%'],
      );
      return res.map((e) => HealthRecord.fromMap(e)).toList();
    } catch (e) {
      print("❌ Error fetching records by date: $e");
      return [];
    }
  }
}
