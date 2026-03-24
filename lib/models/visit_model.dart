import 'package:flutter_med_flow_user_app/helper/utf8_try_decode.dart';
import 'package:flutter_med_flow_user_app/models/custom_data_model.dart';

class VisitModel {
  final Map data;

  VisitModel({required this.data});

  static DateTime? _tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String get id => data['id'] ?? '';

  DateTime? get createdAt => _tryParse(data['created_at']);

  DateTime? get updatedAt => _tryParse(data['updated_at']);

  DateTime? get deletedAt => _tryParse(data['deleted_at']);

  String get tenantId => data['tenant_id'] ?? '';

  String get hospitalId => data['hospital_id'] ?? '';

  String get patientId => data['patient_id'] ?? '';

  String get vn => data['vn'] ?? '';

  DateTime? get visitDate => _tryParse(data['visit_date']);

  String get visitType => data['visit_type'] ?? '';

  String get department => data['department'] ?? '';

  String get doctorId => data['doctor_id'] ?? '';

  String get chiefComplaint =>
      Utf8TryDecode.decode(data['chief_complaint'] ?? '');

  String get status => data['status'] ?? '';

  DateTime? get screeningStartAt => _tryParse(data['screening_start_at']);

  DateTime? get doctorStartAt => _tryParse(data['doctor_start_at']);

  DateTime? get doctorEndAt => _tryParse(data['doctor_end_at']);

  DateTime? get completedAt => _tryParse(data['completed_at']);

  String? get waitTimeMinutes => data['wait_time_minutes'] ?? '';

  String? get serviceTimeMinutes => data['service_time_minutes'] ?? '';

  String? get triageLevel => data['triage_level'] ?? '';

  String get priority => data['priority'] ?? '';

  String get currentLocation => data['current_location'] ?? '';

  String? get currentStationId => data['current_station_id'] ?? '';

  String get disposition => data['disposition'] ?? '';

  String get nhsoAuthCode => data['nhso_authen_code'] ?? '';

  String get nhsoClaimStatus => data['nhso_claim_status'] ?? '';

  CustomDataModel get customData =>
      CustomDataModel(data: data['custom_data'] ?? {});
}
