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
