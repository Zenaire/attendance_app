import 'package:attendance_app/models/attendance_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final record = AttendanceRecord(
    id: '1',
    userId: 'uid',
    checkInTime: DateTime(2026, 11, 12, 8, 15),
    checkOutTime: DateTime(2026, 11, 12, 16, 45),
    date: DateTime(2026, 11, 12),
  );

  test('round trip toJson dan fromJson', () {
    final copy = AttendanceRecord.fromJson(record.toJson());
    expect(copy.id, record.id);
    expect(copy.userId, record.userId);
    expect(copy.checkInTime, record.checkInTime);
  });

  test('tanggal berformat YYYY-MM-DD', () {
    expect(record.toJson()['date'], '2026-11-12');
  });

  test('copyWith melengkapi checkOutTime', () {
    final before = AttendanceRecord(
      id: '1',
      userId: 'uid',
      checkInTime: DateTime(2026, 11, 12, 8),
      date: DateTime(2026, 11, 12),
    );
    final after = before.copyWith(checkOutTime: DateTime(2026, 11, 12, 16));
    expect(after.checkOutTime, DateTime(2026, 11, 12, 16));
  });

  test('totalHours null sebelum pulang', () {
    final before = AttendanceRecord(
      id: '1',
      userId: 'uid',
      checkInTime: DateTime(2026, 11, 12, 8),
      date: DateTime(2026, 11, 12),
    );
    expect(before.totalHours, isNull);
  });

  test('totalHours 8 jam untuk 08 sampai 16', () {
    final before = AttendanceRecord(
      id: '1',
      userId: 'uid',
      checkInTime: DateTime(2026, 11, 12, 8),
      checkOutTime: DateTime(2026, 11, 12, 16),
      date: DateTime(2026, 11, 12),
    );
    expect(before.totalHours, const Duration(hours: 8));
  });

  test('totalHours 8 jam 30 menit untuk 08.15 sampai 16.45', () {
    expect(record.totalHours, const Duration(hours: 8, minutes: 30));
  });
}
