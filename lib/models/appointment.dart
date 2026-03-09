class Appointment {
  final String id;
  final String patientName;
  final String? patientNameEn;
  final String? patientHn;
  final int? patientAge;
  final bool isRegistered;
  final String? patientAvatarUrl;
  final String? birthDate;
  final String? appointmentDate;
  final String status; // Booked, Checked-In, Completed, Cancelled
  final String? arrivalTime; // null = ยังไม่มาโรงพยาบาล
  final String? note;
  final List<DoctorVisit> doctorVisits;

  Appointment({
    required this.id,
    required this.patientName,
    this.patientNameEn,
    this.patientHn,
    this.patientAge,
    this.isRegistered = true,
    this.patientAvatarUrl,
    this.birthDate,
    this.appointmentDate,
    this.status = 'Booked',
    this.arrivalTime,
    this.note,
    this.doctorVisits = const [],
  });
}

class DoctorVisit {
  final String doctorName;
  final String purpose;
  final String? forDepartment;
  final String? doctorAvatarUrl;
  final String? appointmentTime;
  final String? department;

  DoctorVisit({
    required this.doctorName,
    required this.purpose,
    this.forDepartment,
    this.doctorAvatarUrl,
    this.appointmentTime,
    this.department,
  });
}
