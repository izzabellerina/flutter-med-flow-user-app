import 'dart:convert';

class Utf8TryDecode {
  static String decode(String value) {
    try {
      final str = value.toString();
      return utf8.decode(str.codeUnits);
    } catch (e) {
      return value;
    }
  }
}
