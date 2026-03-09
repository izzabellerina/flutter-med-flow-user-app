import '../models/patient.dart';
import '../models/appointment.dart';

class MockData {
  static final List<Patient> patients = [
    Patient(
      id: '1',
      prefix: 'นางสาว ',
      firstName: 'ทดสอบผู้ติดต่อ',
      lastName: 'ระบบใหม่',
      hn: '260306-002',
      phone: '089 - 999 - 8888',
      age: 30,
      gender: 'female',
    ),
    Patient(
      id: '2',
      prefix: 'นาย ',
      firstName: 'ทดสอบแก้ไข',
      lastName: 'สำเร็จแล้ว',
      hn: '260306-001',
      phone: '089 - 999 - 8888',
      age: 35,
      gender: 'male',
    ),
    Patient(
      id: '3',
      prefix: 'นาย ',
      firstName: 'ก',
      lastName: 'จ',
      hn: '260225-005',
      phone: '080 - 000 - 0001',
      age: 26,
      gender: 'male',
    ),
    Patient(
      id: '4',
      prefix: 'เด็กชาย ',
      firstName: 'ภูมิพัฒน์',
      lastName: 'ศรีวิไล',
      hn: '260225-004',
      phone: '089 - 123 - 4567',
      age: 12,
      gender: 'male',
    ),
    Patient(
      id: '5',
      prefix: 'นาง ',
      firstName: 'สมหญิง',
      lastName: 'ดีงาม',
      hn: '260225-003',
      phone: '081 - 234 - 5678',
      age: 45,
      gender: 'female',
    ),
  ];

  static final List<Appointment> appointments = [
    Appointment(
      id: '1',
      patientName: 'MR. Alen Berry',
      isRegistered: false,
      doctorVisits: [
        DoctorVisit(
          doctorName: 'พญ. ธนวัฒน์ แก้วพรหม',
          purpose: 'Major OR',
          forDepartment: '',
        ),
        DoctorVisit(
          doctorName: 'พญ. ธนวัฒน์ แก้วพรหม',
          purpose: 'Work Up',
          forDepartment: 'CD D',
        ),
      ],
    ),
    Appointment(
      id: '2',
      patientName: 'นาย 1234 1234',
      isRegistered: false,
      doctorVisits: [
        DoctorVisit(
          doctorName: 'พญ. ธนวัฒน์ แก้วพรหม',
          purpose: 'Work Up',
          forDepartment: '',
        ),
        DoctorVisit(
          doctorName: 'พญ. ธนวัฒน์ แก้วพรหม',
          purpose: 'Work Up',
          forDepartment: '',
        ),
      ],
    ),
    Appointment(
      id: '3',
      patientName: 'นางสาว ทดสอบผู้ติดต่อ ระบบใหม่',
      patientHn: '260306-002',
      patientAge: 30,
      isRegistered: true,
      doctorVisits: [
        DoctorVisit(
          doctorName: 'พญ. ธนวัฒน์ แก้วพรหม',
          purpose: 'Follow Up',
          forDepartment: 'OPD',
        ),
      ],
    ),
    Appointment(
      id: '4',
      patientName: 'นาย ทดสอบแก้ไข สำเร็จแล้ว',
      patientHn: '260306-001',
      patientAge: 35,
      isRegistered: true,
      doctorVisits: [
        DoctorVisit(
          doctorName: 'พญ. ธนวัฒน์ แก้วพรหม',
          purpose: 'Check Up',
          forDepartment: 'OPD',
        ),
      ],
    ),
  ];

  static const Map<String, String> currentUser = {
    'name': 'Dr. ธนวัฒน์ แก้วพรหม',
    'username': 'doctor_demo_01',
    'role': 'แพทย์',
  };
}
