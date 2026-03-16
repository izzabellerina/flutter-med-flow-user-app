import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:charset_converter/charset_converter.dart';
import '../helper/format_date.dart';

class AndroidBridge {
  static const platform = MethodChannel(
    'com.example.flutter_med_flow_user_app/card_reader',
  );

  /// อ่านข้อมูลบัตรทั้งหมด พร้อม error handling
  static Future<Map<String, dynamic>> readAllCardData() async {
    try {
      var status =
          await platform.invokeMethod("checkReaderAndRequestPermission");
      log("Reader Status: $status");

      if (status == "PERMISSION_GRANTED") {
        final result = await platform.invokeMethod('readAllCardData');
        final data = Map<String, String>.from(result);

        if (data.containsKey('error')) {
          return {'error': data['error'] ?? 'Unknown error'};
        }

        return {
          'cid': _extractData(data['cid']),
          'thaiName': _extractData(data['thaiName']),
          'englishName': _safeHexToAscii(_extractData(data['englishName'])),
          'birthDate': _formatDate(_extractData(data['birthDate'])),
          'gender': _extractData(data['gender']),
          'address': _extractData(data['address']),
          'issueDate': _formatDate(_extractData(data['issueDate'])),
          'expireDate': _formatDate(_extractData(data['expireDate'])),
          'photo': _hexToUint8List(_extractData(data['photo'])),
        };
      } else {
        return {'error': 'No Permission: $status'};
      }
    } catch (e, stackTrace) {
      log('Error reading card: $e');
      log('Stack trace: $stackTrace');
      return {'error': 'Error: $e'};
    }
  }

  /// ตรวจสอบสถานะเครื่องอ่านบัตรและบัตร
  static Future<Map<String, dynamic>> getCardStatus() async {
    try {
      final result = await platform.invokeMethod('getCardStatus');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      log('Error getting card status: $e');
      return {
        'readerConnected': false,
        'cardInserted': false,
      };
    }
  }

  /// ดึงข้อมูลจาก hex response (ลบ status word 9000)
  static String _extractData(String? hexResponse) {
    if (hexResponse == null || hexResponse.isEmpty) return '';
    if (hexResponse == 'ERROR') return '';

    try {
      var cleaned = hexResponse
          .replaceAll(RegExp(r'[69][0-9A-F]{3}$'), '')
          .replaceAll(RegExp(r'00+$'), '');
      return cleaned;
    } catch (e) {
      log('Error extracting data: $e');
      return '';
    }
  }

  /// แปลง hex string เป็น Uint8List สำหรับรูปภาพ
  static Uint8List? _hexToUint8List(String hex) {
    if (hex.isEmpty) return null;

    try {
      final cleaned = hex.replaceAll(' ', '').toUpperCase();
      if (cleaned.length % 2 != 0) return null;

      final bytes = <int>[];
      for (int i = 0; i < cleaned.length; i += 2) {
        final hexByte = cleaned.substring(i, i + 2);
        bytes.add(int.parse(hexByte, radix: 16));
      }
      return Uint8List.fromList(bytes);
    } catch (e) {
      log('Error converting hex to Uint8List: $e');
      return null;
    }
  }

  /// แปลง hex เป็น ASCII พร้อม error handling
  static String _safeHexToAscii(String hex) {
    if (hex.isEmpty) return '';

    try {
      return _hexToAscii(hex);
    } catch (e) {
      log('Error converting hex to ASCII: $e for hex: $hex');
      return hex;
    }
  }

  static String _hexToAscii(String hex) {
    if (hex.isEmpty) return '';

    try {
      final cleaned = hex.replaceAll(' ', '');
      if (cleaned.length % 2 != 0) {
        throw const FormatException('Hex string must have even length');
      }

      final buffer = StringBuffer();
      for (int i = 0; i < cleaned.length; i += 2) {
        final hexByte = cleaned.substring(i, i + 2);
        final byte = int.parse(hexByte, radix: 16);
        if (byte > 0x1F && byte < 0x7F || byte > 0x7F) {
          buffer.writeCharCode(byte);
        }
      }
      return buffer.toString().trim();
    } catch (e) {
      log('Error in hexToAscii: $e');
      return '';
    }
  }

  /// จัดรูปแบบวันที่จาก hex YYYYMMDD
  static String _formatDate(String dateHex) {
    if (dateHex.isEmpty || dateHex.length < 8) return '';

    try {
      final dateStr = _safeHexToAscii(dateHex);
      if (dateStr.length < 8) return dateStr;
      return FormatDate.parseDateYYYYMMDD(dateStr);
    } catch (e) {
      log('Error formatting date: $e for hex: $dateHex');
      return dateHex;
    }
  }

  /// แปลง hex เป็นภาษาไทย (TIS-620 encoding)
  static Future<String> hexToThai(String hex) async {
    try {
      String dataHex = hex.replaceAll(RegExp(r'9[0-9A-F]{3}$'), '');
      if (dataHex.isEmpty) return '';

      List<int> bytes = [];
      for (int i = 0; i < dataHex.length; i += 2) {
        if (i + 1 < dataHex.length) {
          String byte = dataHex.substring(i, i + 2);
          int value = int.parse(byte, radix: 16);
          if (value == 0) break;
          bytes.add(value);
        }
      }

      if (bytes.isEmpty) return '';

      Uint8List uint8list = Uint8List.fromList(bytes);
      String decoded = await CharsetConverter.decode('TIS-620', uint8list);
      return decoded.trim();
    } catch (e) {
      log('Error converting hex to Thai: $e');
      return '';
    }
  }
}
