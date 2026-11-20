import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/attendance_record.dart';
import '../../home/widgets/photo_viewer.dart';

class RecordCard extends StatelessWidget {
  const RecordCard({super.key, required this.record});
  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat("EEEE, d MMMM yyyy", 'id_ID').format(record.date);
    final time = DateFormat('HH:mm', 'id_ID');
    final checkout = record.checkOutTime;
    String duration = '';
    if (record.totalHours != null) {
      final hours = record.totalHours!.inHours;
      final minutes = record.totalHours!.inMinutes.remainder(60);
      duration = '$hours jam ${minutes.toString().padLeft(2, '0')} menit';
    }

    Widget thumbnail = const SizedBox(
      height: 64,
      width: 64,
      child: Icon(Icons.photo),
    );
    if (record.checkInPhotoPath != null &&
        File(record.checkInPhotoPath!).existsSync()) {
      thumbnail = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(record.checkInPhotoPath!),
          height: 64,
          width: 64,
          fit: BoxFit.cover,
        ),
      );
    }

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: GestureDetector(
          onTap: () => PhotoViewer.open(context, record.checkInPhotoPath),
          child: thumbnail,
        ),
        title: Text(date),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Masuk: ${time.format(record.checkInTime)}'),
            Text(
              checkout == null
                  ? 'Pulang: Belum pulang'
                  : 'Pulang: ${time.format(checkout)}',
            ),
            if (duration.isNotEmpty) Text('Durasi: $duration'),
          ],
        ),
      ),
    );
  }
}
