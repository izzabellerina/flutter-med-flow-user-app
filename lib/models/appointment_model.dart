import 'package:flutter_med_flow_user_app/helper/utf8_try_decode.dart';
import 'package:flutter_med_flow_user_app/models/doctor_model.dart';
import 'package:flutter_med_flow_user_app/models/patient_model.dart';
import 'package:flutter_med_flow_user_app/models/visit_model.dart';

class AppointmentModel {
  final Map data;

  AppointmentModel({required this.data});

  static DateTime? _tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String get id => data['id'] ?? '';

  DateTime? get createdAt => _tryParse(data['created_at']);

  DateTime? get updatedAt => _tryParse(data['updated_at']);

  DateTime? get deletedAt => _tryParse(data['deleted_at']);

  String get tenantId => data['tenant_id'] ?? '';

  String get hospitalId => data['hospital_id'] ?? '';

  String get sessionNo => data['session_no'] ?? '';

  String get visitId => data['visit_id'] ?? '';

  String get patientId => data['patient_id'] ?? '';

  String get doctorId => data['doctor_id'] ?? '';

  String? get appointmentId => data['appointment_id'] ?? '';

  String get sessionType => data['session_type'] ?? '';

  String get status => data['status'] ?? '';

  String get roomName => data['room_name'] ?? '';

  String get sessionToken => data['session_token'] ?? '';

  String get sessionLink => data['session_link'] ?? '';

  DateTime? get scheduledAt => _tryParse(data['scheduled_at']);

  DateTime? get startedAt => _tryParse(data['started_at']);

  DateTime? get endedAt => _tryParse(data['ended_at']);

  String? get durationMinutes => data['duration_minutes'] ?? '';

  String get chiefComplaint =>
      Utf8TryDecode.decode(data['chief_complaint'] ?? '');

  String get notes => data['notes'] ?? '';

  String get videoProvider => data['video_provider'] ?? '';

  bool get recordingConsent => data['recording_consent'] ?? false;

  String get recordingUrl => data['recording_url'] ?? '';

  DateTime? get linkExpiredAt => _tryParse(data['link_expired_at']);

  PatientModel get patient => PatientModel(data: data['patient'] ?? {});

  DoctorModel get doctor => DoctorModel(data: data['doctor'] ?? {});

  // https://med3.medflow.in.th/api/api/v1/telemed/sessions/{id}
  VisitModel get visit => VisitModel(data: data['visit'] ?? {});
}
