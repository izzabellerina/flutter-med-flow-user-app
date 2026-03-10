enum TreatmentType { medicine, procedure }

class TreatmentOrder {
  final String id;
  final TreatmentType type;
  final String name;
  final String? usage; // วิธีใช้ (เฉพาะสั่งยา)
  final bool isActive;
  final String recorderName;
  final DateTime recordedAt;

  TreatmentOrder({
    required this.id,
    required this.type,
    required this.name,
    this.usage,
    this.isActive = true,
    required this.recorderName,
    required this.recordedAt,
  });

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
      isActive: isActive ?? this.isActive,
      recorderName: recorderName,
      recordedAt: recordedAt,
    );
  }
}
