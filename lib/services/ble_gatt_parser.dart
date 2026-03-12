import 'dart:typed_data';
import '../models/ble_measurement_result.dart';

class BleGattParser {
  /// Parse Blood Pressure Measurement (UUID 0x2A35)
  static BleMeasurementResult parseBloodPressure(List<int> data) {
    final bytes = Uint8List.fromList(data);
    final byteData = ByteData.sublistView(bytes);
    final flags = bytes[0];
    final isKpa = (flags & 0x01) != 0;

    double systolic = _parseSFloat(byteData, 1);
    double diastolic = _parseSFloat(byteData, 3);

    double? pulseRate;
    if ((flags & 0x04) != 0) {
      int offset = 7;
      if ((flags & 0x02) != 0) offset += 7; // timestamp present
      if (offset + 1 < bytes.length) {
        pulseRate = _parseSFloat(byteData, offset);
      }
    }

    if (isKpa) {
      systolic *= 7.50062;
      diastolic *= 7.50062;
    }

    return BleMeasurementResult(
      deviceType: BleDeviceType.bloodPressure,
      systolic: systolic,
      diastolic: diastolic,
      pulseRate: pulseRate,
    );
  }

  /// Parse Weight Measurement (UUID 0x2A9D)
  static BleMeasurementResult parseWeight(List<int> data) {
    final bytes = Uint8List.fromList(data);
    final byteData = ByteData.sublistView(bytes);
    final flags = bytes[0];
    final isImperial = (flags & 0x01) != 0;

    double weight = byteData.getUint16(1, Endian.little) / 200.0;
    if (isImperial) {
      weight *= 0.453592;
    }

    return BleMeasurementResult(
      deviceType: BleDeviceType.weightScale,
      weight: weight,
    );
  }

  /// Parse PLX Spot-Check Measurement (UUID 0x2A5E)
  static BleMeasurementResult parsePulseOximeter(List<int> data) {
    final bytes = Uint8List.fromList(data);
    final byteData = ByteData.sublistView(bytes);

    double spO2 = _parseSFloat(byteData, 1);
    double pulseRate = _parseSFloat(byteData, 3);

    return BleMeasurementResult(
      deviceType: BleDeviceType.pulseOximeter,
      spO2: spO2,
      pulseRate: pulseRate,
    );
  }

  /// Parse Temperature Measurement (UUID 0x2A1C)
  static BleMeasurementResult parseTemperature(List<int> data) {
    final bytes = Uint8List.fromList(data);
    final byteData = ByteData.sublistView(bytes);
    final flags = bytes[0];
    final isFahrenheit = (flags & 0x01) != 0;

    double temp = _parseFloat32(byteData, 1);
    if (isFahrenheit) {
      temp = (temp - 32) * 5 / 9;
    }

    return BleMeasurementResult(
      deviceType: BleDeviceType.thermometer,
      temperature: temp,
    );
  }

  /// Parse Body Composition Measurement (UUID 0x2A9C)
  /// ดึงค่าน้ำหนักจากเครื่องชั่งที่ใช้ Body Composition Service (0x181B)
  static BleMeasurementResult parseBodyComposition(List<int> data) {
    final bytes = Uint8List.fromList(data);
    final byteData = ByteData.sublistView(bytes);
    final flags = byteData.getUint16(0, Endian.little);
    final isImperial = (flags & 0x01) != 0;

    // ข้าม fields ตามลำดับ spec จนถึง Weight
    int offset = 2; // flags (2 bytes)

    // Body Fat Percentage (always present)
    offset += 2;

    // Time Stamp (7 bytes) if bit 1
    if ((flags & 0x02) != 0) offset += 7;
    // User ID (1 byte) if bit 2
    if ((flags & 0x04) != 0) offset += 1;
    // Basal Metabolism (2 bytes) if bit 3
    if ((flags & 0x08) != 0) offset += 2;
    // Muscle Percentage (2 bytes) if bit 4
    if ((flags & 0x10) != 0) offset += 2;
    // Muscle Mass (2 bytes) if bit 5
    if ((flags & 0x20) != 0) offset += 2;
    // Fat Free Mass (2 bytes) if bit 6
    if ((flags & 0x40) != 0) offset += 2;
    // Soft Lean Mass (2 bytes) if bit 7
    if ((flags & 0x80) != 0) offset += 2;
    // Body Water Mass (2 bytes) if bit 8
    if ((flags & 0x100) != 0) offset += 2;
    // Impedance (2 bytes) if bit 9
    if ((flags & 0x200) != 0) offset += 2;

    // Weight (2 bytes) if bit 10
    double? weight;
    if ((flags & 0x400) != 0 && offset + 1 < bytes.length) {
      weight = byteData.getUint16(offset, Endian.little) / 200.0;
      if (isImperial) weight *= 0.453592;
    }

    return BleMeasurementResult(
      deviceType: BleDeviceType.weightScale,
      weight: weight,
    );
  }

  /// Parse Intermediate Cuff Pressure (UUID 0x2A36)
  /// ส่ง realtime ระหว่างวัดความดัน — ค่า systolic = ความดัน cuff ปัจจุบัน
  static double? parseIntermediateCuffPressure(List<int> data) {
    if (data.length < 7) return null;
    final bytes = Uint8List.fromList(data);
    final byteData = ByteData.sublistView(bytes);
    final flags = bytes[0];
    final isKpa = (flags & 0x01) != 0;

    double pressure = _parseSFloat(byteData, 1);
    if (isKpa) pressure *= 7.50062;

    // ค่า cuff pressure ต้องอยู่ในช่วงที่สมเหตุสมผล
    if (pressure < 0 || pressure > 300) return null;
    return pressure;
  }

  /// Parse custom pulse oximeter data (Yuwell, BerryMed, etc.)
  /// Returns (spO2, pulseRate) if valid, null otherwise.
  static (double, double)? tryParseCustomPulseOximeter(List<int> data) {
    if (data.length < 6) return null;

    // Yuwell BO-YX series: 10-byte packet
    // [0xFE, ?, ?, ?, PR, SpO2, ?, ?, counter, checksum]
    if (data.length >= 10 && data[0] == 0xFE) {
      final pr = data[4];
      final spo2 = data[5];
      if (spo2 >= 70 && spo2 <= 100 && pr >= 30 && pr <= 250) {
        return (spo2.toDouble(), pr.toDouble());
      }
    }

    // Fallback: ลองหาค่า SpO2/PR ใน byte ต่างๆ
    // หลายรุ่นใช้ byte[4]=PR, byte[5]=SpO2
    if (data.length >= 6) {
      final pr = data[4];
      final spo2 = data[5];
      if (spo2 >= 70 && spo2 <= 100 && pr >= 30 && pr <= 250) {
        return (spo2.toDouble(), pr.toDouble());
      }
    }

    return null;
  }

  /// Parse IEEE 11073 SFLOAT (16-bit)
  static double _parseSFloat(ByteData data, int offset) {
    final raw = data.getInt16(offset, Endian.little);
    final mantissa = raw & 0x0FFF;
    final exponent = (raw >> 12);
    final signedExp = exponent >= 8 ? exponent - 16 : exponent;
    final signedMantissa = mantissa >= 0x0800 ? mantissa - 0x1000 : mantissa;
    return signedMantissa * _pow10(signedExp);
  }

  /// Parse IEEE 11073 FLOAT (32-bit)
  static double _parseFloat32(ByteData data, int offset) {
    final raw = data.getInt32(offset, Endian.little);
    final mantissa = raw & 0x00FFFFFF;
    final exponent = (raw >> 24);
    final signedExp = exponent >= 128 ? exponent - 256 : exponent;
    final signedMantissa =
        mantissa >= 0x800000 ? mantissa - 0x1000000 : mantissa;
    return signedMantissa * _pow10(signedExp);
  }

  static double _pow10(int exp) {
    double result = 1.0;
    if (exp >= 0) {
      for (int i = 0; i < exp; i++) {
        result *= 10;
      }
    } else {
      for (int i = 0; i < -exp; i++) {
        result /= 10;
      }
    }
    return result;
  }
}
