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
      appointmentDate: '09-03-2026',
      status: 'Booked',
      doctorVisits: [
        DoctorVisit(
          doctorName: 'พญ. ธนวัฒน์ แก้วพรหม',
          purpose: 'Major OR',
          forDepartment: '',
          appointmentTime: '10:30',
          department: 'ผู้ป่วยนอก',
        ),
        DoctorVisit(
          doctorName: 'พญ. ธนวัฒน์ แก้วพรหม',
          purpose: 'Work Up',
          forDepartment: 'CD D',
          appointmentTime: '14:00',
          department: 'ผู้ป่วยนอก',
        ),
      ],
    ),
    Appointment(
      id: '2',
      patientName: 'นาย 1234 1234',
      isRegistered: false,
      appointmentDate: '09-03-2026',
      status: 'Booked',
      doctorVisits: [
        DoctorVisit(
          doctorName: 'พญ. ธนวัฒน์ แก้วพรหม',
          purpose: 'Work Up',
          forDepartment: '',
          appointmentTime: '11:00',
          department: 'ผู้ป่วยนอก',
        ),
        DoctorVisit(
          doctorName: 'พญ. ธนวัฒน์ แก้วพรหม',
          purpose: 'Work Up',
          forDepartment: '',
          appointmentTime: '15:30',
          department: 'ผู้ป่วยนอก',
        ),
      ],
    ),
    Appointment(
      id: '3',
      patientName: 'นางสาว ทดสอบผู้ติดต่อ ระบบใหม่',
      patientNameEn: 'Miss THODSOB PHUTIDTOR RABOBMAI',
      patientHn: '260306-002',
      patientAge: 30,
      isRegistered: true,
      birthDate: '15 มีนาคม 2539',
      appointmentDate: '09-03-2026',
      status: 'Booked',
      doctorVisits: [
        DoctorVisit(
          doctorName: 'พญ. ธนวัฒน์ แก้วพรหม',
          purpose: 'Follow Up',
          forDepartment: 'OPD',
          appointmentTime: '13:00',
          department: 'ผู้ป่วยนอก',
        ),
      ],
    ),
    Appointment(
      id: '4',
      patientName: 'นาง บุญมี ทองคำ',
      patientNameEn: 'Mrs. BOONMEE THONGKHAM',
      patientHn: '260225-003',
      patientAge: 75,
      isRegistered: true,
      birthDate: '2 กรกฎาคม 2493',
      appointmentDate: '09-03-2026',
      status: 'Booked',
      note: '',
      doctorVisits: [
        DoctorVisit(
          doctorName: 'พญ. ธนวัฒน์ แก้วพรหม',
          purpose: 'Work Up',
          forDepartment: '',
          appointmentTime: '19:21',
          department: 'ผู้ป่วยนอก',
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
