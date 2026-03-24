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
    }

    // iOS/macOS: ข้าม permission_handler ทั้งหมด
    // flutter_blue_plus จะทริก CBCentralManager authorization dialog เอง
    // ตอนเรียก startScan() (อาศัย Info.plist NSBluetoothAlwaysUsageDescription)
    return true;
  }
}
