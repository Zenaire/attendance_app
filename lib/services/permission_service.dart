import 'package:permission_handler/permission_handler.dart' as handler;

class PermissionService {
  Future<handler.PermissionStatus> requestCamera() =>
      handler.Permission.camera.request();

  Future<bool> openAppSettings() => handler.openAppSettings();
}
