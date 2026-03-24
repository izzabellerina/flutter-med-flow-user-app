import 'package:flutter_med_flow_user_app/helper/utf8_try_decode.dart';

class DoctorModel {
  final Map data;

  DoctorModel({required this.data});

  static DateTime? _tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String get id => data['id'] ?? '';

  DateTime? get createdAt => _tryParse(data['created_at']);

  DateTime? get updatedAt => _tryParse(data['updated_at']);

  DateTime? get deletedAt => _tryParse(data['deleted_at']);

  String get tenantId => data['tenant_id'] ?? '';

  String get username => data['username'] ?? '';

  String get email => data['email'] ?? '';

  String get fullName => Utf8TryDecode.decode(data['full_name'] ?? '');

  String get systemRole => data['system_role'] ?? '';

  String get licenseNo => Utf8TryDecode.decode(data['license_no'] ?? '');

  bool get isActive => data['is_active'] ?? false;

  DateTime? get lastLoginAt => _tryParse(data['last_login_at']);
}
