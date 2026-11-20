import '../models/attendance_record.dart';
import 'attendance_service.dart';

class FirestoreService {
  // Nama kelas belum berarti membaca Firestore. Versi ini hanya meneruskan ke AttendanceService.
  FirestoreService(this.attendanceService);

  final AttendanceService attendanceService;

  Stream<List<AttendanceRecord>> getAttendanceRecords(String userId) =>
      attendanceService.getAttendanceRecords(userId);

  Stream<AttendanceRecord?> getTodayRecordStream(String userId) =>
      attendanceService.getTodayRecordStream(userId);

  Future<String> createAttendanceRecord(AttendanceRecord record) =>
      attendanceService.createAttendanceRecord(record);

  Future<void> updateAttendanceRecord(AttendanceRecord record) =>
      attendanceService.updateAttendanceRecord(record);
}
