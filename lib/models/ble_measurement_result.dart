enum BleDeviceType { bloodPressure, weightScale, pulseOximeter, thermometer }

class BleMeasurementResult {
  final BleDeviceType deviceType;
  final double? systolic;
  final double? diastolic;
  final double? pulseRate;
  final double? weight;
  final double? spO2;
  final double? temperature;
  final DateTime timestamp;

  BleMeasurementResult({
    required this.deviceType,
    this.systolic,
    this.diastolic,
    this.pulseRate,
    this.weight,
    this.spO2,
    this.temperature,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
