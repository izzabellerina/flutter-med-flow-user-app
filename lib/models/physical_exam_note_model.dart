class PhysicalExamNoteModel {
  final Map data;

  PhysicalExamNoteModel({required this.data});

  String get notes => data['notes'] ?? '';

  bool get normal => data['normal'] ?? false;
}
