import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/ble_device_info.dart';
import '../models/ble_measurement_result.dart';
import 'ble_gatt_parser.dart';

/// Exception เมื่ออุปกรณ์ไม่มี GATT service ที่ต้องการ
class BleServiceNotFoundException implements Exception {
  final String message;
  BleServiceNotFoundException(this.message);
  @override
  String toString() => message;
}

class BleUuids {
  static final bloodPressureService =
      Guid('00001810-0000-1000-8000-00805f9b34fb');
  static final bloodPressureMeasurement =
      Guid('00002a35-0000-1000-8000-00805f9b34fb');

  static final weightScaleService =
      Guid('0000181d-0000-1000-8000-00805f9b34fb');
  static final weightMeasurement =
      Guid('00002a9d-0000-1000-8000-00805f9b34fb');

  static final pulseOximeterService =
      Guid('00001822-0000-1000-8000-00805f9b34fb');
  static final plxSpotCheck =
      Guid('00002a5e-0000-1000-8000-00805f9b34fb');

  static final healthThermometerService =
      Guid('00001809-0000-1000-8000-00805f9b34fb');
  static final temperatureMeasurement =
      Guid('00002a1c-0000-1000-8000-00805f9b34fb');

  static Guid serviceUuidFor(BleDeviceType type) {
    switch (type) {
      case BleDeviceType.bloodPressure:
        return bloodPressureService;
      case BleDeviceType.weightScale:
        return weightScaleService;
      case BleDeviceType.pulseOximeter:
        return pulseOximeterService;
      case BleDeviceType.thermometer:
        return healthThermometerService;
    }
  }

  static Guid characteristicUuidFor(BleDeviceType type) {
    switch (type) {
      case BleDeviceType.bloodPressure:
        return bloodPressureMeasurement;
      case BleDeviceType.weightScale:
        return weightMeasurement;
      case BleDeviceType.pulseOximeter:
        return plxSpotCheck;
      case BleDeviceType.thermometer:
        return temperatureMeasurement;
    }
  }
}

class BleService {
  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _notifySubscription;
  final _scanResultsController =
      StreamController<List<BleDeviceInfo>>.broadcast();
  final List<BleDeviceInfo> _discoveredDevices = [];

  Stream<List<BleDeviceInfo>> get scanResults => _scanResultsController.stream;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  Stream<BluetoothAdapterState> get adapterState =>
      FlutterBluePlus.adapterState;

  Future<void> startScan(
      {Duration timeout = const Duration(seconds: 10)}) async {
    _discoveredDevices.clear();
    _scanResultsController.add([]);

    // ต้อง listen ก่อน startScan เพื่อไม่ให้พลาดผลลัพธ์
    _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
      for (final result in results) {
        // ข้ามอุปกรณ์ที่ไม่มีชื่อ
        if (result.device.advName.isEmpty) continue;

        final existing = _discoveredDevices.indexWhere(
          (d) => d.device.remoteId == result.device.remoteId,
        );
        final info = BleDeviceInfo.fromScanResult(result);
        if (existing >= 0) {
          _discoveredDevices[existing] = info;
        } else {
          _discoveredDevices.add(info);
        }
      }
      _scanResultsController.add(List.from(_discoveredDevices));
    });

    // สแกนอุปกรณ์ BLE ทั้งหมด (ไม่ filter service UUID)
    await FlutterBluePlus.startScan(timeout: timeout);
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Future<void> connect(BluetoothDevice device, {int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await device.connect(
          timeout: const Duration(seconds: 15),
          autoConnect: false,
        );
        _connectedDevice = device;
        return;
      } catch (e) {
        if (attempt < maxRetries) {
          try {
            await device.disconnect();
          } catch (_) {}
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        } else {
          rethrow;
        }
      }
    }
  }

  Future<BleMeasurementResult> readMeasurement(
      BleDeviceType deviceType) async {
    if (_connectedDevice == null) {
      throw Exception('No device connected');
    }

    final services = await _connectedDevice!.discoverServices();
    final targetServiceUuid = BleUuids.serviceUuidFor(deviceType);
    final targetCharUuid = BleUuids.characteristicUuidFor(deviceType);

    // ลองหา standard service ก่อน
    var service = services.cast<BluetoothService?>().firstWhere(
      (s) => s!.serviceUuid == targetServiceUuid,
      orElse: () => null,
    );
    var charUuid = targetCharUuid;
    bool isCustom = false;

    // ถ้าไม่พบ standard → ลอง custom UUIDs (เช่น Yuwell)
    if (service == null) {
      final fallback = _findCustomService(services, deviceType);
      if (fallback != null) {
        service = fallback.$1;
        charUuid = fallback.$2;
        isCustom = true;
        dev.log('Using custom service: ${service.serviceUuid} / $charUuid');
      }
    }

    if (service == null) {
      dev.log('=== Services found on device ===');
      for (final s in services) {
        dev.log('Service: ${s.serviceUuid}');
        for (final c in s.characteristics) {
          dev.log('  Char: ${c.characteristicUuid} | props: ${c.properties}');
        }
      }
      throw BleServiceNotFoundException(
          'อุปกรณ์นี้ไม่รองรับการวัด${_deviceTypeLabel(deviceType)}');
    }

    final characteristic = service.characteristics.cast<BluetoothCharacteristic?>().firstWhere(
      (c) => c!.characteristicUuid == charUuid,
      orElse: () => null,
    );

    if (characteristic == null) {
      throw BleServiceNotFoundException(
          'ไม่พบ Characteristic สำหรับการวัด${_deviceTypeLabel(deviceType)}');
    }

    await characteristic.setNotifyValue(true);

    // Custom devices (Yuwell) ส่งข้อมูลต่อเนื่อง — ต้องรวบรวมหลาย packets
    if (isCustom && deviceType == BleDeviceType.pulseOximeter) {
      return _readCustomPulseOximeter(characteristic);
    }

    final completer = Completer<BleMeasurementResult>();

    _notifySubscription = characteristic.onValueReceived.listen((value) {
      if (!completer.isCompleted) {
        final result = _parseData(deviceType, value);
        completer.complete(result);
      }
    });

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException('No measurement received within 30 seconds');
      },
    );
  }

  /// หา custom service/characteristic สำหรับอุปกรณ์ที่ไม่ใช้ standard GATT
  (BluetoothService, Guid)? _findCustomService(
      List<BluetoothService> services, BleDeviceType deviceType) {
    // Custom UUIDs ที่พบบ่อยในอุปกรณ์ Yuwell, BerryMed, etc.
    // ใช้ Guid ตรงๆ เพื่อให้ flutter_blue_plus เปรียบเทียบถูกต้อง
    final customConfigs = <BleDeviceType, List<(Guid, Guid)>>{
      BleDeviceType.pulseOximeter: [
        (Guid('ffe0'), Guid('ffe4')), // Yuwell BO-YX series
        (Guid('fff0'), Guid('fff3')), // บางรุ่น
      ],
    };

    final configs = customConfigs[deviceType];
    if (configs == null) return null;

    for (final (svcGuid, charGuid) in configs) {
      for (final svc in services) {
        if (svc.serviceUuid == svcGuid) {
          // หา characteristic ที่มี notify
          final hasChar = svc.characteristics.any(
            (c) => c.characteristicUuid == charGuid && c.properties.notify,
          );
          if (hasChar) return (svc, charGuid);
        }
      }
    }
    return null;
  }

  /// อ่านค่าจาก custom pulse oximeter (Yuwell/BerryMed)
  /// เก็บ notifications หลาย packets แล้วหาค่า SpO2/PR ที่ valid
  Future<BleMeasurementResult> _readCustomPulseOximeter(
      BluetoothCharacteristic characteristic) async {
    final completer = Completer<BleMeasurementResult>();
    int validCount = 0;
    double lastSpO2 = 0;
    double lastPr = 0;

    _notifySubscription = characteristic.onValueReceived.listen((value) {
      if (completer.isCompleted) return;

      dev.log('Custom O2 raw: $value (${value.length} bytes)');

      final parsed = BleGattParser.tryParseCustomPulseOximeter(value);
      if (parsed != null) {
        lastSpO2 = parsed.$1;
        lastPr = parsed.$2;
        validCount++;
        dev.log('Parsed SpO2=$lastSpO2, PR=$lastPr (count=$validCount)');

        // รอค่า stable 3 ครั้งติดกัน
        if (validCount >= 3) {
          completer.complete(BleMeasurementResult(
            deviceType: BleDeviceType.pulseOximeter,
            spO2: lastSpO2,
            pulseRate: lastPr,
          ));
        }
      }
    });

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        // ถ้ามีค่าบางส่วน ส่งกลับ
        if (lastSpO2 > 0 && lastPr > 0) {
          return BleMeasurementResult(
            deviceType: BleDeviceType.pulseOximeter,
            spO2: lastSpO2,
            pulseRate: lastPr,
          );
        }
        throw TimeoutException('ไม่ได้รับค่าจากเครื่องภายใน 30 วินาที');
      },
    );
  }

  static String _deviceTypeLabel(BleDeviceType type) {
    switch (type) {
      case BleDeviceType.bloodPressure:
        return 'ความดัน';
      case BleDeviceType.weightScale:
        return 'น้ำหนัก';
      case BleDeviceType.pulseOximeter:
        return 'O2';
      case BleDeviceType.thermometer:
        return 'อุณหภูมิ';
    }
  }

  BleMeasurementResult _parseData(BleDeviceType type, List<int> data) {
    switch (type) {
      case BleDeviceType.bloodPressure:
        return BleGattParser.parseBloodPressure(data);
      case BleDeviceType.weightScale:
        return BleGattParser.parseWeight(data);
      case BleDeviceType.pulseOximeter:
        return BleGattParser.parsePulseOximeter(data);
      case BleDeviceType.thermometer:
        return BleGattParser.parseTemperature(data);
    }
  }

  Future<void> disconnect() async {
    await _notifySubscription?.cancel();
    _notifySubscription = null;
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
  }

  void dispose() {
    stopScan();
    disconnect();
    _scanResultsController.close();
  }
}
