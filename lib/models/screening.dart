class Screening {
  final String id;
  final String cc; // Chief Complaint
  final String pi; // Present Illness
  final String ph; // Past History
  final String pe; // Physical Examination
  final String recorderName;
  final DateTime recordedAt;

  Screening({
    required this.id,
    required this.cc,
    required this.pi,
    required this.ph,
    required this.pe,
    required this.recorderName,
    required this.recordedAt,
  });

  bool get isToday {
    final now = DateTime.now();
    return recordedAt.year == now.year &&
        recordedAt.month == now.month &&
        recordedAt.day == now.day;
  }
}
