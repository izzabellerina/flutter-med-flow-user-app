import 'package:flutter_med_flow_user_app/helper/utf8_try_decode.dart';

class HospitalModel {
  final Map data;

  HospitalModel({required this.data});

  String get id => data['id'] ?? '';

  String get code => data['code'] ?? '';

  String get name => Utf8TryDecode.decode(data['name'] ?? '');
}