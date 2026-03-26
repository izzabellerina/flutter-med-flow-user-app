class PhysicalExamRequestModel {
  String visitId;
  String patientId;
  String? generalAppearance;
  String? summary;
  PhysicalExamNoteItem heent;
  PhysicalExamNoteItem neck;
  PhysicalExamNoteItem cardiovascular;
  PhysicalExamNoteItem respiratory;
  PhysicalExamNoteItem abdomen;
  PhysicalExamNoteItem extremities;
  PhysicalExamNoteItem neurological;
  PhysicalExamNoteItem skin;
  PhysicalExamNoteItem psychiatric;

  PhysicalExamRequestModel({
    required this.visitId,
    required this.patientId,
    this.generalAppearance,
    this.summary,
    required this.heent,
    required this.neck,
    required this.cardiovascular,
    required this.respiratory,
    required this.abdomen,
    required this.extremities,
    required this.neurological,
    required this.skin,
    required this.psychiatric,
  });

  Map<String, dynamic> toJson() {
    return {
      'visitId': visitId,
      'patientId': patientId,
      'generalAppearance': generalAppearance,
      'summary': summary,
      'heent': heent.toJson(),
      'neck': neck.toJson(),
      'cardiovascular': cardiovascular.toJson(),
      'respiratory': respiratory.toJson(),
      'abdomen': abdomen.toJson(),
      'extremities': extremities.toJson(),
      'neurological': neurological.toJson(),
      'skin': skin.toJson(),
      'psychiatric': psychiatric.toJson(),
    };
  }
}

class PhysicalExamNoteItem {
  bool normal;
  String notes;

  PhysicalExamNoteItem({required this.normal, required this.notes});

  Map<String, dynamic> toJson() {
    return {'normal': normal, 'notes': notes};
  }
}
