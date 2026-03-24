class VitalSign {
  final String id;
  final double? bw; // Body Weight (kg)
  final double? ht; // Height (cm)
  final double? bmi; // Body Mass Index
  final double? sBp; // Systolic Blood Pressure
  final double? dBp; // Diastolic Blood Pressure
  final double? pr; // Pulse Rate
  final double? o2; // Oxygen Saturation
  final double? temp; // Temperature (°C)
  final String recorderName; // ผู้บันทึก
  final DateTime recordedAt;

  VitalSign({
    required this.id,
    this.bw,
    this.ht,
    this.bmi,
    this.sBp,
    this.dBp,
    this.pr,
    this.o2,
    this.temp,
    required this.recorderName,
    required this.recordedAt,
  });

  factory VitalSign.fromJson(Map<String, dynamic> json) {
    return VitalSign(
      id: json['id']?.toString() ?? '',
      bw: _toDouble(json['body_weight']),
      ht: _toDouble(json['height']),
      bmi: _toDouble(json['bmi']),
      sBp: _toDouble(json['systolic_bp']),
      dBp: _toDouble(json['diastolic_bp']),
      pr: _toDouble(json['pulse_rate']),
      o2: _toDouble(json['oxygen_saturation']),
      temp: _toDouble(json['temperature']),
      recorderName: json['recorder_name']?.toString() ?? '-',
      recordedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  bool get isToday {
    final now = DateTime.now();
    return recordedAt.year == now.year &&
        recordedAt.month == now.month &&
        recordedAt.day == now.day;
  }

  /// Auto-calculate BMI from bw and ht
  static double? calculateBmi(double? bw, double? ht) {
    if (bw == null || ht == null || ht == 0) return null;
    final htM = ht / 100;
    return bw / (htM * htM);
  }
}
