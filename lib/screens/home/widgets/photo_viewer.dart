import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class PhotoViewer extends StatelessWidget {
  const PhotoViewer({super.key, required this.photoPath});
  final String? photoPath;

  static Future<void> open(BuildContext context, String? photoPath) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PhotoViewer(photoPath: photoPath)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (photoPath != null && File(photoPath!).existsSync()) {
      content = InteractiveViewer(
        child: Image.file(File(photoPath!), fit: BoxFit.contain),
      );
    } else if (photoPath != null && photoPath!.startsWith('base64:')) {
      try {
        content = InteractiveViewer(
          child: Image.memory(
            base64Decode(photoPath!.substring(7)),
            fit: BoxFit.contain,
          ),
        );
      } catch (_) {
        content = const _PhotoPlaceholder();
      }
    } else {
      content = const _PhotoPlaceholder();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Foto presensi')),
      body: Center(child: content),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.broken_image_outlined, size: 64),
        SizedBox(height: 12),
        Text('Foto tidak tersedia'),
      ],
    );
  }
}
