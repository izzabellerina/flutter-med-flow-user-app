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
