import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/attendance_record.dart';

class AttendanceService {
  AttendanceService() {
    _initStorage();
  }

  static const _storageKey = 'local_attendance_records_v1';
  final List<AttendanceRecord> _records = [];
  final Map<String, StreamController<List<AttendanceRecord>>> _controllers = {};
  bool _initialized = false;

  Future<void> _initStorage() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _records.addAll(
        list.map(
          (item) => AttendanceRecord.fromJson(item as Map<String, dynamic>),
        ),
      );
    }
    _initialized = true;
  }

  Future<void> _ensureInitialized() async {
    while (!_initialized) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  Future<bool> _persistRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_records.map((record) => record.toJson()).toList());
    return prefs.setString(_storageKey, raw);
  }

  void _emitUpdates() {
    for (final entry in _controllers.entries) {
      final userId = entry.key;
      if (!entry.value.isClosed) {
        entry.value.add(
          _records.where((record) => record.userId == userId).toList(),
        );
      }
    }
  }

  Stream<List<AttendanceRecord>> getAttendanceRecords(String userId) async* {
    await _ensureInitialized();
    final controller = _controllers.putIfAbsent(
      userId,
      () => StreamController<List<AttendanceRecord>>.broadcast(
        onCancel: () {
          _controllers.remove(userId);
        },
      ),
    );
    yield _records.where((record) => record.userId == userId).toList();
    yield* controller.stream;
  }

  Stream<AttendanceRecord?> getTodayRecordStream(String userId) async* {
    await for (final records in getAttendanceRecords(userId)) {
      final now = DateTime.now();
      yield records.cast<AttendanceRecord?>().where((record) {
            return record != null &&
                record.date.year == now.year &&
                record.date.month == now.month &&
                record.date.day == now.day;
          }).isEmpty
          ? null
          : records.cast<AttendanceRecord?>().firstWhere((record) {
              return record != null &&
                  record.date.year == now.year &&
                  record.date.month == now.month &&
                  record.date.day == now.day;
            });
    }
  }

  Future<String> createAttendanceRecord(AttendanceRecord record) async {
    await _ensureInitialized();
    final exists = _records.any((item) {
      return item.userId == record.userId &&
          item.date.year == record.date.year &&
          item.date.month == record.date.month &&
          item.date.day == record.date.day;
    });
    if (exists) throw StateError('Presensi hari ini sudah ada.');

    _records.add(record);
    final saved = await _persistRecords();
    if (!saved) {
      _records.removeWhere((item) => item.id == record.id);
      throw Exception('Gagal menyimpan presensi lokal.');
    }
    _emitUpdates();
    return record.id;
  }

  Future<void> updateAttendanceRecord(AttendanceRecord record) async {
    await _ensureInitialized();
    final index = _records.indexWhere(
      (item) => item.id == record.id && item.userId == record.userId,
    );
    if (index == -1) throw StateError('Presensi tidak ditemukan.');
    _records[index] = record;
    final saved = await _persistRecords();
    if (!saved) {
      throw Exception('Gagal menyimpan perubahan presensi lokal.');
    }
    _emitUpdates();
  }
}
