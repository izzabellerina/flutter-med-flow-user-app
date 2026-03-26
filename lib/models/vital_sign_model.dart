import 'package:flutter_med_flow_user_app/models/alert_model.dart';
import 'package:flutter_med_flow_user_app/models/patient_model.dart';

class VitalSignModel {
  final Map data;

  VitalSignModel({required this.data});

  String get id => data['id'] ?? '';

  DateTime get createdAt => DateTime.parse(data['created_at'] ?? '');

  DateTime get updatedAt => DateTime.parse(data['updated_at'] ?? '');

  DateTime? get deletedAt => DateTime.parse(data['deleted_at'] ?? '');

  String get tenantId => data['tenant_id'] ?? '';

  String get hospitalId => data['hospital_id'] ?? '';

  String get visitId => data['visit_id'] ?? '';

  String get patientId => data['patient_id'] ?? '';

  DateTime get recordedAt => DateTime.parse(data['recorded_at'] ?? '');

  String get recordedBy => data['recorded_by'] ?? '';

  double get pulseRate => (data['pulse_rate'] ?? 0).toDouble();

  double get respiratoryRate => data['respiratory_rate'] ?? 0.0;

  double get systolicBp => (data['systolic_bp'] ?? 0).toDouble();

  double get diastolicBp => (data['diastolic_bp'] ?? 0).toDouble();

  double get meanArterialPressure => data['mean_arterial_pressure'] ?? 0.0;

  double get temperature => (data['temperature'] ?? 0).toDouble();

  double get oxygenSaturation => (data['oxygen_saturation'] ?? 0).toDouble();

  double get bodyWeight => (data['body_weight'] ?? 0).toDouble();

  double get height => (data['height'] ?? 0).toDouble();

  double get bmi => (data['bmi'] ?? 0).toDouble();

  String? get headCircumference => data['head_circumference'] ?? '';

  String? get waistCircumference => data['waist_circumference'] ?? '';

  double get bloodGlucose => data['blood_glucose'] ?? 0.0;

  int get painScore => data['pain_score'] ?? 0;

  String get source => data['source'] ?? '';

  String? get deviceId => data['device_id'] ?? '';

  String? get deviceReadingId => data['device_reading_id'] ?? '';

  String? get deviceTimestamp => data['device_timestamp'] ?? '';

  String get status => data['status'] ?? '';

  String? get verifiedBy => data['verified_by'] ?? '';

  DateTime? get verifiedAt => DateTime.parse(data['verified_at'] ?? '');

  List<AlertModel> get alerts =>
      List.from(data['alerts'] ?? []).map((e) => AlertModel(data: e)).toList();

  String get notes => data['notes'] ?? '';

  // api/v1/clinical/vital-signs?{patient_id}&limit=30
  PatientModel get patient => PatientModel(data: data['patient'] ?? {});
}
