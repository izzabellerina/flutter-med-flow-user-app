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
      // iOS: ขอ Bluetooth permission
      // ถ้า permission_handler ไม่ทริก dialog ให้ใช้ flutter_blue_plus
      // ซึ่งจะทริก CBCentralManager authorization dialog เอง
      final btStatus = await Permission.bluetooth.request();
      if (btStatus == PermissionStatus.granted ||
          btStatus == PermissionStatus.limited) {
        return true;
      }

      // ถ้า status เป็น denied แต่ยังไม่เคยถาม (iOS อาจ return denied ก่อนที่ CBCentralManager จะทริก)
      // ให้ return true แล้วปล่อยให้ flutter_blue_plus ทริก dialog ตอน startScan()
      if (btStatus == PermissionStatus.denied) {
        return true;
      }

      // permanentlyDenied → ต้องไปเปิดใน Settings
      return false;
    }
    return true;
  }
}
