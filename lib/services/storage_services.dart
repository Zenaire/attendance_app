import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract class PhotoStorage {
  Future<String> savePhoto(String sourcePath, String photoType);
}

class StorageServices implements PhotoStorage {
  @override
  Future<String> savePhoto(String sourcePath, String photoType) async {
    if (photoType != 'checkin' && photoType != 'checkout') {
      throw ArgumentError('photoType hanya boleh checkin atau checkout');
    }

    final directory = await getApplicationDocumentsDirectory();
    final photoDirectory = Directory(
      p.join(directory.path, 'attendance_photos'),
    );
    if (!await photoDirectory.exists()) {
      await photoDirectory.create(recursive: true);
    }

    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final targetPath = p.join(
      photoDirectory.path,
      '${timestamp}_$photoType.jpg',
    );

    final compressed = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      quality: 75,
      format: CompressFormat.jpeg,
    );
    if (compressed == null) throw Exception('Gagal mengompres foto.');
    if (!await File(compressed.path).exists()) {
      throw Exception('Gagal menyimpan foto.');
    }
    return compressed.path;
  }

  // Meski bernama upload, versi ini hanya menyimpan lokal.
  Future<String> uploadAttendancePhoto(String sourcePath, String photoType) =>
      savePhoto(sourcePath, photoType);
}
