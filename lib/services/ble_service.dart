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

/// Exception เมื่ออุปกรณ์ตัดการเชื่อมต่อระหว่างวัดค่า
class BleDeviceDisconnectedException implements Exception {
  final String message;
  BleDeviceDisconnectedException(this.message);
  @override
  String toString() => message;
}

class BleUuids {
  static final bloodPressureService =
      Guid('00001810-0000-1000-8000-00805f9b34fb');
  static final bloodPressureMeasurement =
      Guid('00002a35-0000-1000-8000-00805f9b34fb');
  static final intermediateCuffPressure =
      Guid('00002a36-0000-1000-8000-00805f9b34fb');

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
  StreamSubscription<List<int>>? _intermediateBpSub;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSub;
  final _scanResultsController =
      StreamController<List<BleDeviceInfo>>.broadcast();
  final List<BleDeviceInfo> _discoveredDevices = [];
  bool _disposed = false;

  Stream<List<BleDeviceInfo>> get scanResults => _scanResultsController.stream;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  Stream<BluetoothAdapterState> get adapterState =>
      FlutterBluePlus.adapterState;

  Future<void> startScan(
      {Duration timeout = const Duration(seconds: 10)}) async {
    _discoveredDevices.clear();
    if (!_disposed) _scanResultsController.add([]);

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
      if (!_disposed) {
        _scanResultsController.add(List.from(_discoveredDevices));
      }
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
      BleDeviceType deviceType, {
      void Function(double cuffPressure)? onIntermediateBp,
      void Function(double weight)? onIntermediateWeight,
  }) async {
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

    // สำหรับเครื่องวัดความดัน: subscribe Intermediate Cuff Pressure (0x2A36)
    // เพื่อแสดงค่า cuff pressure แบบ realtime ระหว่างวัด
    if (deviceType == BleDeviceType.bloodPressure && onIntermediateBp != null) {
      final intermChar = service.characteristics
          .cast<BluetoothCharacteristic?>()
          .firstWhere(
            (c) => c!.characteristicUuid == BleUuids.intermediateCuffPressure,
            orElse: () => null,
          );
      if (intermChar != null) {
        try {
          await intermChar.setNotifyValue(true);
          _intermediateBpSub =
              intermChar.onValueReceived.listen((value) {
            final pressure =
                BleGattParser.parseIntermediateCuffPressure(value);
            if (pressure != null) {
              dev.log('Intermediate cuff pressure: $pressure mmHg');
              onIntermediateBp(pressure);
            }
          });
        } catch (e) {
          dev.log('Intermediate cuff pressure not available: $e');
        }
      }
    }

    // Custom devices ที่ส่งข้อมูลต่อเนื่อง — ต้องรวบรวมหลาย packets
    if (isCustom && deviceType == BleDeviceType.pulseOximeter) {
      return _readCustomPulseOximeter(characteristic);
    }
    if (isCustom && deviceType == BleDeviceType.weightScale) {
      return _readBodyCompositionScale(characteristic, onIntermediateWeight);
    }

    // ใช้ timeout นานขึ้นสำหรับเครื่องวัดความดัน (ต้องรอวัดเสร็จ)
    final timeoutDuration = deviceType == BleDeviceType.bloodPressure
        ? const Duration(seconds: 90)
        : const Duration(seconds: 30);

    final completer = Completer<BleMeasurementResult>();

    // ฟังสถานะ connection — ถ้า disconnect ให้ fail fast
    _connectionStateSub?.cancel();
    _connectionStateSub =
        _connectedDevice!.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected &&
          !completer.isCompleted) {
        dev.log('Device disconnected during measurement ($deviceType)');
        completer.completeError(BleDeviceDisconnectedException(
            'เครื่องตัดการเชื่อมต่อระหว่างวัดค่า'));
      }
    });

    _notifySubscription = characteristic.onValueReceived.listen((value) {
      dev.log('BLE data received for $deviceType: $value (${value.length} bytes)');
      if (!completer.isCompleted) {
        final BleMeasurementResult result;
        if (isCustom && deviceType == BleDeviceType.weightScale) {
          result = BleGattParser.parseBodyComposition(value);
        } else {
          result = _parseData(deviceType, value);
        }
        completer.complete(result);
      }
    });

    try {
      return await completer.future.timeout(
        timeoutDuration,
        onTimeout: () {
          throw TimeoutException(
              'ไม่ได้รับค่าจากเครื่องภายใน ${timeoutDuration.inSeconds} วินาที');
        },
      );
    } finally {
      await _connectionStateSub?.cancel();
      _connectionStateSub = null;
      await _intermediateBpSub?.cancel();
      _intermediateBpSub = null;
    }
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
      BleDeviceType.weightScale: [
        (Guid('181b'), Guid('2a9c')), // Body Composition Service
      ],
    };

    final configs = customConfigs[deviceType];
    if (configs == null) return null;

    for (final (svcGuid, charGuid) in configs) {
      for (final svc in services) {
        if (svc.serviceUuid == svcGuid) {
          // หา characteristic ที่มี notify หรือ indicate
          final hasChar = svc.characteristics.any(
            (c) =>
                c.characteristicUuid == charGuid &&
                (c.properties.notify || c.properties.indicate),
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

  /// อ่านค่าจาก Body Composition Scale (0x181B / 0x2A9C)
  /// เครื่องส่งค่าต่อเนื่องระหว่างชั่ง — รอค่านิ่งก่อนส่งกลับ
  Future<BleMeasurementResult> _readBodyCompositionScale(
      BluetoothCharacteristic characteristic,
      void Function(double weight)? onIntermediate) async {
    final completer = Completer<BleMeasurementResult>();
    int stableCount = 0;
    double lastWeight = 0;
    BleMeasurementResult? lastResult;

    _notifySubscription = characteristic.onValueReceived.listen((value) {
      if (completer.isCompleted) return;

      final result = BleGattParser.parseBodyComposition(value);
      final weight = result.weight;
      if (weight == null || weight <= 0) return;

      dev.log('Body composition weight: $weight kg (stable=$stableCount)');
      onIntermediate?.call(weight);
      lastResult = result;

      // รอค่านิ่ง: ±0.3 kg ติดกัน 5 ครั้ง
      if ((weight - lastWeight).abs() < 0.3) {
        stableCount++;
      } else {
        stableCount = 1;
      }
      lastWeight = weight;

      if (stableCount >= 5) {
        completer.complete(result);
      }
    });

    return completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        if (lastResult != null && lastWeight > 0) {
          return lastResult!;
        }
        throw TimeoutException('ไม่ได้รับค่าจากเครื่องภายใน 60 วินาที');
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
    await _connectionStateSub?.cancel();
    _connectionStateSub = null;
    await _intermediateBpSub?.cancel();
    _intermediateBpSub = null;
    await _notifySubscription?.cancel();
    _notifySubscription = null;
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
  }

  void dispose() {
    _disposed = true;
    stopScan();
    disconnect();
    _scanResultsController.close();
  }
}
