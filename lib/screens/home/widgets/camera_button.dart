import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../services/permission_service.dart';

class CameraButton extends StatelessWidget {
  const CameraButton({
    super.key,
    required this.label,
    required this.onCaptured,
    this.loading = false,
  });

  final String label;
  final Future<void> Function(String path) onCaptured;
  final bool loading;

  Future<void> _takePhoto(BuildContext context) async {
    final permission = PermissionService();
    final status = await permission.requestCamera();
    if (status.isDenied) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Izin kamera diperlukan'),
          content: const Text(
            'Kamera diperlukan untuk mengambil foto presensi.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _takePhoto(context);
              },
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
      return;
    }
    if (status.isPermanentlyDenied) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Izin kamera diblokir'),
          content: const Text(
            'Aktifkan izin kamera melalui pengaturan aplikasi.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await permission.openAppSettings();
              },
              child: const Text('Pengaturan'),
            ),
          ],
        ),
      );
      return;
    }

    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;
    await onCaptured(image.path);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: loading ? null : () => _takePhoto(context),
        icon: const Icon(Icons.camera_alt),
        label: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
