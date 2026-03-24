import 'package:flutter_med_flow_user_app/helper/utf8_try_decode.dart';
import 'package:flutter_med_flow_user_app/models/clinical_info_model.dart';
import 'package:flutter_med_flow_user_app/models/contact_model.dart';
import 'package:flutter_med_flow_user_app/models/custom_data_model.dart';

class PatientModel {
  final Map data;

  PatientModel({required this.data});

  String get id => data['id'] ?? '';

  DateTime get createdAt => DateTime.parse(data['created_at'] ?? '');

  DateTime get updatedAt => DateTime.parse(data['updated_at'] ?? '');

  DateTime? get deletedAt => DateTime.parse(data['deleted_at'] ?? '');

  String get tenantId => data['tenant_id'] ?? '';

  String get hospitalId => data['hospital_id'] ?? '';

  String get hn => data['hn'] ?? '';

  String get cid => data['cid'] ?? '';

  String get passportNo => data['passport_no'] ?? '';

  String get prefix => Utf8TryDecode.decode(data['prefix'] ?? '');

  String get firstName => Utf8TryDecode.decode(data['first_name'] ?? '');

  String get lastName => Utf8TryDecode.decode(data['last_name'] ?? '');

  String get firstNameEn => data['first_name_en'] ?? '';

  String get lastNameEn => data['last_name_en'] ?? '';

  DateTime get birthDate => DateTime.parse(data['birth_date'] ?? '');

  String get gender => data['gender'] ?? '';

  String get bloodType => data['blood_type'] ?? '';

  String get phone => data['phone'] ?? '';

  String get address => data['address'] ?? '';

  String get province => data['province'] ?? '';

  String get allergies => data['allergies'] ?? '';

  String get photoUrl => data['photo_url'] ?? '';

  CustomDataModel get customData =>
      CustomDataModel(data: data['custom_data'] ?? '');

  bool get isActive => data['is_active'] ?? false;

  String get idType => data['id_type'] ?? '';

  String get foreignId => data['foreign_id'] ?? '';

  String get titleCode => data['title_code'] ?? '';

  String get nickname => data['nickname'] ?? '';

  String get rhFactor => data['rh_factor'] ?? '';

  String get nationalityCode => data['nationality_code'] ?? '';

  String get raceCode => data['race_code'] ?? '';

  String get religionCode => data['religion_code'] ?? '';

  String get maritalStatus => data['marital_status'] ?? '';

  String get educationLevel => data['education_level'] ?? '';

  String get occupationCode => data['occupation_code'] ?? '';

  String get birthProvinceCode => data['birth_province_code'] ?? '';

  String get birthCountryCode => data['birth_country_code'] ?? '';

  String? get addressCurrent => data['address_current'] ?? '';

  String? get addressPermanent => data['address_permanent'] ?? '';

  String? get addressWork => data['address_work'] ?? '';

  ContactModel get contacts => ContactModel(data: data['contacts'] ?? []);

  List<String> get emergencyContacts => data['emergency_contacts'] ?? [];

  ClinicalInfoModel get clinicalInfo =>
      ClinicalInfoModel(data: data['clinical_info'] ?? {});

  String get patientStatus => data['patient_status'] ?? '';

  DateTime? get firstVisitDate =>
      DateTime.parse(data['first_visit_date'] ?? '');

  DateTime? get lastVisitDate => DateTime.parse(data['last_visit_date'] ?? '');

  bool get isDeceased => data['is_deceased'] ?? false;

  DateTime? get deceasedDate => DateTime.parse(data['deceased_date'] ?? '');

  String? get createdBy => data['created_by'] ?? '';

  String? get updatedBy => data['updated_by'] ?? '';
}
