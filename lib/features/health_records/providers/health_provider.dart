import 'dart:async';
import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../models/health_record.dart';

class HealthProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  //  Local cache of records
  List<HealthRecord> _records = [];
  List<HealthRecord> get records => _records;

  //  Stream controller for real-time UI updates
  final StreamController<List<HealthRecord>> _recordsStreamController =
      StreamController<List<HealthRecord>>.broadcast();

  Stream<List<HealthRecord>> get recordsStream =>
      _recordsStreamController.stream;

  Timer? _autoRefreshTimer;

  //  Load all records from database
  Future<void> loadRecords() async {
    await _dbHelper.init();
    _records = await _dbHelper.getRecords();
    _recordsStreamController.add(_records);
    notifyListeners();
  }

  // Auto-refresh every few seconds
  void startAutoRefresh() {
    _autoRefreshTimer ??= Timer.periodic(
      const Duration(seconds: 3),
      (_) async => await _refreshRecords(),
    );
  }

  Future<void> _refreshRecords() async {
    final newRecords = await _dbHelper.getRecords();

    // If the list changed → update stream
    if (!_areRecordsEqual(newRecords, _records)) {
      _records = newRecords;
      _recordsStreamController.add(_records);
      notifyListeners();
    }
  }

  //  Check equal lists
  bool _areRecordsEqual(List<HealthRecord> a, List<HealthRecord> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].steps != b[i].steps ||
          a[i].calories != b[i].calories ||
          a[i].water != b[i].water ||
          a[i].date != b[i].date) {
        return false;
      }
    }
    return true;
  }

  //  Add record
  Future<void> addRecord(HealthRecord record) async {
    await _dbHelper.insertRecord(record);
    await _refreshRecords();
  }

  //  Update record
  Future<void> updateRecord(HealthRecord record) async {
    await _dbHelper.updateRecord(record);
    await _refreshRecords();
  }

  //  Delete record
  Future<void> deleteRecord(int id) async {
    await _dbHelper.deleteRecord(id);
    await _refreshRecords();
  }

  //  SEARCH FUNCTION 
  void filterByDate(String query) {
    query = query.trim();

    // If empty, show all
    if (query.isEmpty) {
      _recordsStreamController.add(_records);
      return;
    }

    // Filter by starting date match (correct)
    final filtered = _records.where((record) {
      return record.date.toString().startsWith(query);
    }).toList();

    // Send filtered list to UI
    _recordsStreamController.add(filtered);
  }

  //  Today's totals
  int getTodayTotal(String field) {
    DateTime today = DateTime.now();
    String todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    List<HealthRecord> todayRecords =
        _records.where((r) => r.date == todayStr).toList();

    if (field == 'water') {
      return todayRecords.fold(0, (sum, r) => sum + r.water);
    } else if (field == 'steps') {
      return todayRecords.fold(0, (sum, r) => sum + r.steps);
    } else if (field == 'calories') {
      return todayRecords.fold(0, (sum, r) => sum + r.calories);
    }
    return 0;
  }

  //  Monthly totals
  int getMonthTotal(String field) {
    DateTime now = DateTime.now();
    String month = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    List<HealthRecord> monthRecords =
        _records.where((r) => r.date.startsWith(month)).toList();

    if (field == 'water') {
      return monthRecords.fold(0, (sum, r) => sum + r.water);
    } else if (field == 'steps') {
      return monthRecords.fold(0, (sum, r) => sum + r.steps);
    } else if (field == 'calories') {
      return monthRecords.fold(0, (sum, r) => sum + r.calories);
    }
    return 0;
  }

  //  Daily streak
  int getDailyStreak() {
    if (_records.isEmpty) return 0;

    List<DateTime> dates = _records
        .map((r) => DateTime.parse(r.date))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 1;

    for (int i = 0; i < dates.length - 1; i++) {
      final current = dates[i];
      final next = dates[i + 1];

      final diff = current.difference(next).inDays;

      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

//  UPDATED ACHIEVEMENTS (Based on 10,000 steps per day)
List<String> getAchievements() {
  List<String> badges = [];

  // Today totals
  int todaySteps = getTodayTotal("steps");
  int todayWater = getTodayTotal("water");

  // Streak
  int streak = getDailyStreak();

  //  Steps Achievement (10,000 per day)
  if (todaySteps >= 10000) {
    badges.add("10,000 Steps Today");
  }

  //  Water Achievement (2000 ml per day)
  if (todayWater >= 2000) {
    badges.add("2000ml Water Goal Reached");
  }

  //  Consistency (Streak Achievements)
  if (streak >= 3) {
    badges.add("3-Day Streak");
  }
  if (streak >= 7) {
    badges.add("7-Day Streak");
  }

  return badges;
}


  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _recordsStreamController.close();
    super.dispose();
  }
}
