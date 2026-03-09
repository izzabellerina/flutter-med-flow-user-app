class Diagnosis {
  final String id;
  final String recordNote; // บันทึกผลตรวจ
  final String diagnosisType; // e.g. "Exam"
  final String icd10;
  final String icdDesc;
  final String snTerm;
  final String diagnosisNote; // คำวินิจฉัย
  final String recorderName; // ผู้บันทึก
  final DateTime recordedAt;

  Diagnosis({
    required this.id,
    required this.recordNote,
    required this.diagnosisType,
    required this.icd10,
    required this.icdDesc,
    required this.snTerm,
    required this.diagnosisNote,
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
