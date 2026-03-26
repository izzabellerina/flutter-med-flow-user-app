class CreateVitalSignModel {
  String sessionToken;
  double? bodyWeight;
  double? height;
  double? systolicBp;
  double? diastolicBp;
  double? temperature;
  double? oxygenSaturation;
  double? pulseRate;
  double? respiratoryRate;
  double? bloodGlucose;
  int? painScore;

  CreateVitalSignModel({
    required this.sessionToken,
    this.height,
    this.bodyWeight,
    this.systolicBp,
    this.diastolicBp,
    this.temperature,
    this.oxygenSaturation,
    this.pulseRate,
    this.respiratoryRate,
    this.bloodGlucose,
    this.painScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'session_token': sessionToken,
      'body_weight': bodyWeight,
      'height': height,
      'systolic_bp': systolicBp,
      'diastolic_bp': diastolicBp,
      'temperature': temperature,
      'oxygen_saturation': oxygenSaturation,
      'pulse_rate': pulseRate,
      'respiratory_rate': respiratoryRate,
      'blood_glucose': bloodGlucose,
      'pain_score': painScore,
    };
  }

  List<Map<String, dynamic>> toJsonList() {
    return [toJson()];
  }
}
