import 'package:flutter_med_flow_user_app/models/patient_model.dart';
import 'package:flutter_med_flow_user_app/models/physical_exam_note_model.dart';
import 'package:flutter_med_flow_user_app/models/visit_model.dart';

class PhysicalExamModel {
  final Map data;

  PhysicalExamModel({required this.data});

  String get id => data['id'] ?? '';

  DateTime get createdAt => DateTime.parse(data['created_at'] ?? '');

  DateTime get updatedAt => DateTime.parse(data['updated_at'] ?? '');

  DateTime? get deletedAt => DateTime.parse(data['deleted_at'] ?? '');

  String get tenantId => data['tenant_id'] ?? '';

  String get hospitalId => data['hospital_id'] ?? '';

  String get visitId => data['visit_id'] ?? '';

  String get patientId => data['patient_id'] ?? '';

  String get examinerId => data['examiner_id'] ?? '';

  DateTime get examDatetime => DateTime.parse(data['exam_datetime'] ?? '');

  String get generalAppearance => data['general_appearance'] ?? '';

  PhysicalExamNoteModel get heent =>
      PhysicalExamNoteModel(data: data['heent'] ?? {});

  PhysicalExamNoteModel get neck =>
      PhysicalExamNoteModel(data: data['neck'] ?? {});

  PhysicalExamNoteModel get cardiovascular =>
      PhysicalExamNoteModel(data: data['cardiovascular'] ?? {});

  PhysicalExamNoteModel get respiratory =>
      PhysicalExamNoteModel(data: data['respiratory'] ?? {});

  PhysicalExamNoteModel get abdomen =>
      PhysicalExamNoteModel(data: data['abdomen'] ?? {});

  PhysicalExamNoteModel get extremities =>
      PhysicalExamNoteModel(data: data['extremities'] ?? {});

  PhysicalExamNoteModel get neurological =>
      PhysicalExamNoteModel(data: data['neurological'] ?? {});

  PhysicalExamNoteModel get skin =>
      PhysicalExamNoteModel(data: data['skin'] ?? {});

  PhysicalExamNoteModel get psychiatric =>
      PhysicalExamNoteModel(data: data['psychiatric'] ?? {});

  String? get specialtyExam => data['specialty_exam'] ?? '';

  String get specialtyType => data['specialty_type'] ?? '';

  String get summary => data['summary'] ?? '';

  String get notes => data['notes'] ?? '';

  PatientModel get patient => PatientModel(data: data['patient'] ?? {});

  VisitModel get visit => VisitModel(data: data['visit'] ?? {});
}
