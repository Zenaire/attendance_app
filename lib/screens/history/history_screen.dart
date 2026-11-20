import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/attendance_record.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_services.dart';
import 'widgets/record_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.authServices,
    required this.attendanceService,
  });
  final AuthServices authServices;
  final AttendanceService attendanceService;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  StreamSubscription<List<AttendanceRecord>>? _subscription;
  List<AttendanceRecord> _records = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    final uid = widget.authServices.currentUser?.uid;
    if (uid != null) {
      _subscription = widget.attendanceService
          .getAttendanceRecords(uid)
          .listen(
            (records) {
              records.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
              setState(() {
                _records = records;
                _error = null;
              });
            },
            onError: (Object error) {
              setState(() => _error = 'Gagal memuat riwayat: $error');
            },
          );
    } else {
      _error = 'Sesi akun tidak ditemukan.';
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : _records.isEmpty
          ? const Center(child: Text('Belum ada riwayat presensi'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _records.length,
              itemBuilder: (_, index) => RecordCard(record: _records[index]),
            ),
    );
  }
}
