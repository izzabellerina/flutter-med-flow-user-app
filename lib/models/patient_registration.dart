class PatientRegistration {
  // สำคัญ
  final String fullName;
  final String? fullNameEn;
  final String? hn;
  final String? nationalId;
  final String? passportNo;
  final String? gender;
  final String? bloodType;
  final String? birthDate;
  final int? age;
  final String? religion;
  final String? nationality;
  final String? patientSource;
  final String? avatarUrl;

  // ติดต่อ
  final String? phone;
  final String? officePhone;
  final String? email;
  final String? currentAddress;

  // ส่วนตัว
  final String? maritalStatus;
  final String? occupation;
  final String? workplace;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? emergencyRelation;

  // สุขภาพ
  final String? underlyingDisease;
  final String? surgeryHistory;
  final String? familyHistory;
  final String? smokingStatus;
  final String? drinkingStatus;

  // แพ้ยา
  final List<DrugAllergy> drugAllergies;

  PatientRegistration({
    required this.fullName,
    this.fullNameEn,
    this.hn,
    this.nationalId,
    this.passportNo,
    this.gender,
    this.bloodType,
    this.birthDate,
    this.age,
    this.religion,
    this.nationality,
    this.patientSource,
    this.avatarUrl,
    this.phone,
    this.officePhone,
    this.email,
    this.currentAddress,
    this.maritalStatus,
    this.occupation,
    this.workplace,
    this.emergencyContact,
    this.emergencyPhone,
    this.emergencyRelation,
    this.underlyingDisease,
    this.surgeryHistory,
    this.familyHistory,
    this.smokingStatus,
    this.drinkingStatus,
    this.drugAllergies = const [],
  });
}

class DrugAllergy {
  final String drugName;
  final String? reaction;
  final String? severity; // mild, moderate, severe

  DrugAllergy({
    required this.drugName,
    this.reaction,
    this.severity,
  });
}
