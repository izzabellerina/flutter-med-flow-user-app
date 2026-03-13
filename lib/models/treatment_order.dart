enum TreatmentType { medicine, procedure }

class TreatmentOrder {
  final String id;
  final TreatmentType type;
  final String name;
  final String? usage; // วิธีใช้ (เฉพาะสั่งยา)
  final int quantity; // จำนวน
  final String unit; // หน่วย (เม็ด, แคปซูล, ขวด, ครั้ง ฯลฯ)
  final double pricePerUnit; // ราคาต่อหน่วย
  final bool isActive;
  final String recorderName;
  final DateTime recordedAt;

  TreatmentOrder({
    required this.id,
    required this.type,
    required this.name,
    this.usage,
    this.quantity = 1,
    this.unit = 'ครั้ง',
    this.pricePerUnit = 0,
    this.isActive = true,
    required this.recorderName,
    required this.recordedAt,
  });

  double get totalPrice => quantity * pricePerUnit;

  bool get isToday {
    final now = DateTime.now();
    return recordedAt.year == now.year &&
        recordedAt.month == now.month &&
        recordedAt.day == now.day;
  }

  TreatmentOrder copyWith({bool? isActive}) {
    return TreatmentOrder(
      id: id,
      type: type,
      name: name,
      usage: usage,
      quantity: quantity,
      unit: unit,
      pricePerUnit: pricePerUnit,
      isActive: isActive ?? this.isActive,
      recorderName: recorderName,
      recordedAt: recordedAt,
    );
  }
}
