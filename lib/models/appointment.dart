class Appointment {
  final String id;
  final String patientName;
  final String? patientHn;
  final int? patientAge;
  final bool isRegistered;
  final String? patientAvatarUrl;
  final List<DoctorVisit> doctorVisits;

  Appointment({
    required this.id,
    required this.patientName,
    this.patientHn,
    this.patientAge,
    this.isRegistered = true,
    this.patientAvatarUrl,
    this.doctorVisits = const [],
  });
}

class DoctorVisit {
  final String doctorName;
  final String purpose;
  final String? forDepartment;
  final String? doctorAvatarUrl;

  DoctorVisit({
    required this.doctorName,
    required this.purpose,
    this.forDepartment,
    this.doctorAvatarUrl,
  });
}
