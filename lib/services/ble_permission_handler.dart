import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class BlePermissionHandler {
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      return statuses.values
          .every((s) => s == PermissionStatus.granted);
    } else if (Platform.isIOS || Platform.isMacOS) {
      final status = await Permission.bluetooth.request();
      return status == PermissionStatus.granted;
    }
    return true;
  }
}
