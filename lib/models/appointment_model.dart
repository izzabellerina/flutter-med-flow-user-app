import 'package:flutter_med_flow_user_app/helper/utf8_try_decode.dart';
import 'package:flutter_med_flow_user_app/models/doctor_model.dart';
import 'package:flutter_med_flow_user_app/models/patient_model.dart';

class AppointmentModel {
  final Map data;

  AppointmentModel({required this.data});

  String get id => data['id'] ?? '';

  DateTime get createdAt => DateTime.parse(data['created_at'] ?? '');

  DateTime get updatedAt => DateTime.parse(data['updated_at'] ?? '');

  DateTime? get deletedAt => DateTime.parse(data['deleted_at'] ?? '');

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

  DateTime get scheduledAt => DateTime.parse(data['scheduled_at'] ?? '');

  DateTime get startedAt => DateTime.parse(data['started_at'] ?? '');

  DateTime? get endedAt => DateTime.parse(data['ended_at'] ?? '');

  String? get durationMinutes => data['duration_minutes'] ?? '';

  String get chiefComplaint =>
      Utf8TryDecode.decode(data['chief_complaint'] ?? '');

  String get notes => data['notes'] ?? '';

  String get videoProvider => data['video_provider'] ?? '';

  bool get recordingConsent => data['recording_consent'] ?? false;

  String get recordingUrl => data['recording_url'] ?? '';

  DateTime get linkExpiredAt => DateTime.parse(data['link_expired_at'] ?? '');

  PatientModel get patient => PatientModel(data: data['patient'] ?? {});

  DoctorModel get doctor => DoctorModel(data: data['doctor'] ?? {});
}
