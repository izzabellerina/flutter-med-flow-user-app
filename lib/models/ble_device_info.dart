import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleDeviceInfo {
  final BluetoothDevice device;
  final String name;
  final int rssi;
  final List<Guid> serviceUuids;

  BleDeviceInfo({
    required this.device,
    required this.name,
    required this.rssi,
    required this.serviceUuids,
  });

  factory BleDeviceInfo.fromScanResult(ScanResult result) {
    return BleDeviceInfo(
      device: result.device,
      name: result.device.advName.isNotEmpty
          ? result.device.advName
          : 'Unknown Device',
      rssi: result.rssi,
      serviceUuids: result.advertisementData.serviceUuids,
    );
  }
}
