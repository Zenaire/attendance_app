import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/attendance_record.dart';
import 'photo_viewer.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key, required this.record});
  final AttendanceRecord? record;

  String _duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours jam ${minutes.toString().padLeft(2, '0')} menit';
  }

  Widget _photo(String? path) {
    if (path == null || !File(path).existsSync()) {
      return const SizedBox(
        height: 90,
        child: Center(child: Text('Foto tidak tersedia')),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(File(path), height: 90, width: 120, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (record == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Belum ada presensi hari ini',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final time = DateFormat('HH:mm', 'id_ID');
    final checkout = record!.checkOutTime;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              checkout == null ? 'Sudah masuk' : 'Presensi selesai',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text('Jam masuk: ${time.format(record!.checkInTime)}'),
            if (checkout != null) Text('Jam pulang: ${time.format(checkout)}'),
            if (record!.totalHours != null)
              Text('Durasi: ${_duration(record!.totalHours!)}'),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      PhotoViewer.open(context, record!.checkInPhotoPath),
                  child: _photo(record!.checkInPhotoPath),
                ),
                if (checkout != null) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () =>
                        PhotoViewer.open(context, record!.checkOutPhotoPath),
                    child: _photo(record!.checkOutPhotoPath),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
