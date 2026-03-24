class VitalSignModel {
  final Map data;

  VitalSignModel({required this.data});

  String get sessionToken => data['session_token'] ?? '';

  double get bodyWeight => data['body_weight'] ?? 0.0;

  int get height => data['height'] ?? 0;

  int get systolicBp => data['systolic_bp'] ?? 0;

  int get diastolicBp => data['diastolic_bp'] ?? 0;

  double get temperature => data['temperature'] ?? 0.0;

  int get oxygenSaturation => data['oxygen_saturation'] ?? 0;

  int get pulseRate => data['pulse_rate'] ?? 0;

  int get respiratoryRate => data['respiratory_rate'] ?? 0;

  int get bloodGlucose => data['blood_glucose'] ?? 0;

  int get painScore => data['pain_score'] ?? 0;
}
