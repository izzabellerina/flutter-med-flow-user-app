import '../models/patient.dart';
import '../models/appointment.dart';
import '../models/patient_registration.dart';

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

  /// รายการยา (mock)
  static final List<Map<String, dynamic>> medicines = [
    {'id': 'MED001', 'name': 'Paracetamol 500 mg', 'usage': 'รับประทานครั้งละ 1-2 เม็ด ทุก 4-6 ชั่วโมง เมื่อมีอาการปวด', 'unit': 'เม็ด', 'pricePerUnit': 2.0},
    {'id': 'MED002', 'name': 'Ibuprofen 400 mg', 'usage': 'รับประทานครั้งละ 1 เม็ด วันละ 3 ครั้ง หลังอาหาร', 'unit': 'เม็ด', 'pricePerUnit': 5.0},
    {'id': 'MED003', 'name': 'Amoxicillin 500 mg', 'usage': 'รับประทานครั้งละ 1 เม็ด วันละ 3 ครั้ง หลังอาหาร', 'unit': 'แคปซูล', 'pricePerUnit': 8.0},
    {'id': 'MED004', 'name': 'Dexamethasone 0.025% in BSS Eye Drops 16 mL', 'usage': 'ตามคำสั่งแพทย์', 'unit': 'ขวด', 'pricePerUnit': 350.0},
    {'id': 'MED005', 'name': 'Metformin 500 mg', 'usage': 'รับประทานครั้งละ 1 เม็ด วันละ 2 ครั้ง หลังอาหาร', 'unit': 'เม็ด', 'pricePerUnit': 3.0},
    {'id': 'MED006', 'name': 'Amlodipine 5 mg', 'usage': 'รับประทานครั้งละ 1 เม็ด วันละ 1 ครั้ง', 'unit': 'เม็ด', 'pricePerUnit': 6.0},
    {'id': 'MED007', 'name': 'Omeprazole 20 mg', 'usage': 'รับประทานครั้งละ 1 เม็ด วันละ 1 ครั้ง ก่อนอาหารเช้า', 'unit': 'แคปซูล', 'pricePerUnit': 12.0},
    {'id': 'MED008', 'name': 'Atorvastatin 20 mg', 'usage': 'รับประทานครั้งละ 1 เม็ด วันละ 1 ครั้ง ก่อนนอน', 'unit': 'เม็ด', 'pricePerUnit': 15.0},
    {'id': 'MED009', 'name': 'Losartan 50 mg', 'usage': 'รับประทานครั้งละ 1 เม็ด วันละ 1 ครั้ง', 'unit': 'เม็ด', 'pricePerUnit': 10.0},
    {'id': 'MED010', 'name': 'Aspirin 81 mg', 'usage': 'รับประทานครั้งละ 1 เม็ด วันละ 1 ครั้ง หลังอาหาร', 'unit': 'เม็ด', 'pricePerUnit': 1.5},
    {'id': 'MED011', 'name': 'Ciprofloxacin 500 mg', 'usage': 'รับประทานครั้งละ 1 เม็ด วันละ 2 ครั้ง', 'unit': 'เม็ด', 'pricePerUnit': 18.0},
    {'id': 'MED012', 'name': 'Prednisolone 5 mg', 'usage': 'ตามคำสั่งแพทย์', 'unit': 'เม็ด', 'pricePerUnit': 4.0},
    {'id': 'MED013', 'name': 'Diclofenac 25 mg', 'usage': 'รับประทานครั้งละ 1 เม็ด วันละ 3 ครั้ง หลังอาหาร', 'unit': 'เม็ด', 'pricePerUnit': 3.5},
    {'id': 'MED014', 'name': 'Cetirizine 10 mg', 'usage': 'รับประทานครั้งละ 1 เม็ด วันละ 1 ครั้ง ก่อนนอน', 'unit': 'เม็ด', 'pricePerUnit': 5.0},
    {'id': 'MED015', 'name': 'Simvastatin 20 mg', 'usage': 'รับประทานครั้งละ 1 เม็ด วันละ 1 ครั้ง ก่อนนอน', 'unit': 'เม็ด', 'pricePerUnit': 8.0},
  ];

  /// วิธีใช้ยา (mock)
  static final List<Map<String, String>> medicineUsages = [
    {'id': 'USG001', 'name': 'รับประทานครั้งละ 1 เม็ด วันละ 1 ครั้ง'},
    {'id': 'USG002', 'name': 'รับประทานครั้งละ 1 เม็ด วันละ 2 ครั้ง'},
    {'id': 'USG003', 'name': 'รับประทานครั้งละ 1 เม็ด วันละ 3 ครั้ง หลังอาหาร'},
    {'id': 'USG004', 'name': 'รับประทานครั้งละ 1-2 เม็ด ทุก 4-6 ชั่วโมง เมื่อมีอาการปวด'},
    {'id': 'USG005', 'name': 'รับประทานครั้งละ 1 เม็ด วันละ 1 ครั้ง ก่อนอาหารเช้า'},
    {'id': 'USG006', 'name': 'รับประทานครั้งละ 1 เม็ด วันละ 1 ครั้ง ก่อนนอน'},
    {'id': 'USG007', 'name': 'รับประทานครั้งละ 1 เม็ด วันละ 1 ครั้ง หลังอาหาร'},
    {'id': 'USG008', 'name': 'หยดตา 1 หยด วันละ 4 ครั้ง'},
    {'id': 'USG009', 'name': 'หยดตา 1 หยด ทุก 1 ชั่วโมง'},
    {'id': 'USG010', 'name': 'ทาบริเวณที่เป็น วันละ 2 ครั้ง'},
    {'id': 'USG011', 'name': 'ตามคำสั่งแพทย์'},
    {'id': 'USG012', 'name': 'อมใต้ลิ้น 1 เม็ด เมื่อมีอาการ'},
    {'id': 'USG013', 'name': 'พ่นปาก 1-2 พ่น วันละ 2 ครั้ง'},
    {'id': 'USG014', 'name': 'ฉีดเข้าใต้ผิวหนัง วันละ 1 ครั้ง'},
    {'id': 'USG015', 'name': 'รับประทานครั้งละ 2 เม็ด วันละ 2 ครั้ง หลังอาหาร'},
  ];

  /// รายการหัตถการ (mock)
  static final List<Map<String, dynamic>> procedures = [
    {'id': 'PRC001', 'name': 'Xen Implantation/OS', 'pricePerUnit': 25000.0},
    {'id': 'PRC002', 'name': 'Phacoemulsification with IOL implantation', 'pricePerUnit': 35000.0},
    {'id': 'PRC003', 'name': 'Trabeculectomy', 'pricePerUnit': 20000.0},
    {'id': 'PRC004', 'name': 'Intravitreal Injection', 'pricePerUnit': 15000.0},
    {'id': 'PRC005', 'name': 'YAG Laser Capsulotomy', 'pricePerUnit': 5000.0},
    {'id': 'PRC006', 'name': 'Selective Laser Trabeculoplasty (SLT)', 'pricePerUnit': 8000.0},
    {'id': 'PRC007', 'name': 'Pterygium Excision with Graft', 'pricePerUnit': 12000.0},
    {'id': 'PRC008', 'name': 'Chalazion Incision & Curettage', 'pricePerUnit': 3000.0},
    {'id': 'PRC009', 'name': 'Fundus Fluorescein Angiography (FFA)', 'pricePerUnit': 4500.0},
    {'id': 'PRC010', 'name': 'Retinal Laser Photocoagulation', 'pricePerUnit': 10000.0},
  ];

  /// รายการ ICD-10 (mock)
  static final List<Map<String, String>> icd10Codes = [
    {'code': 'A00.0', 'desc': 'Cholera due to Vibrio cholerae 01, biovar cholerae', 'snTerm': 'Cholera due to Vibrio cholerae O1 Classical biotype (disorder)'},
    {'code': 'A09.0', 'desc': 'Other and unspecified gastroenteritis and colitis of infectious origin', 'snTerm': 'Infectious gastroenteritis (disorder)'},
    {'code': 'E11.9', 'desc': 'Type 2 diabetes mellitus without complications', 'snTerm': 'Type 2 diabetes mellitus (disorder)'},
    {'code': 'E78.0', 'desc': 'Pure hypercholesterolaemia', 'snTerm': 'Hypercholesterolemia (disorder)'},
    {'code': 'H40.1', 'desc': 'Primary open-angle glaucoma', 'snTerm': 'Open-angle glaucoma (disorder)'},
    {'code': 'H25.9', 'desc': 'Senile cataract, unspecified', 'snTerm': 'Age-related cataract (disorder)'},
    {'code': 'H11.0', 'desc': 'Pterygium', 'snTerm': 'Pterygium (disorder)'},
    {'code': 'H35.3', 'desc': 'Degeneration of macula and posterior pole', 'snTerm': 'Macular degeneration (disorder)'},
    {'code': 'I10', 'desc': 'Essential (primary) hypertension', 'snTerm': 'Essential hypertension (disorder)'},
    {'code': 'I25.1', 'desc': 'Atherosclerotic heart disease', 'snTerm': 'Atherosclerotic heart disease (disorder)'},
    {'code': 'J06.9', 'desc': 'Acute upper respiratory infection, unspecified', 'snTerm': 'Upper respiratory infection (disorder)'},
    {'code': 'J45.9', 'desc': 'Asthma, unspecified', 'snTerm': 'Asthma (disorder)'},
    {'code': 'K21.0', 'desc': 'Gastro-oesophageal reflux disease with oesophagitis', 'snTerm': 'Gastroesophageal reflux disease with esophagitis (disorder)'},
    {'code': 'K29.7', 'desc': 'Gastritis, unspecified', 'snTerm': 'Gastritis (disorder)'},
    {'code': 'M54.5', 'desc': 'Low back pain', 'snTerm': 'Low back pain (finding)'},
    {'code': 'N39.0', 'desc': 'Urinary tract infection, site not specified', 'snTerm': 'Urinary tract infection (disorder)'},
    {'code': 'R50.9', 'desc': 'Fever, unspecified', 'snTerm': 'Fever (finding)'},
    {'code': 'R51', 'desc': 'Headache', 'snTerm': 'Headache (finding)'},
    {'code': 'Z00.0', 'desc': 'General medical examination', 'snTerm': 'General examination of patient (procedure)'},
    {'code': 'Z01.0', 'desc': 'Examination of eyes and vision', 'snTerm': 'Eye examination (procedure)'},
  ];

  /// แผนก (mock)
  static final List<Map<String, String>> departments = [
    {'id': 'DEP001', 'name': 'จักษุ'},
    {'id': 'DEP002', 'name': 'อายุรกรรม'},
    {'id': 'DEP003', 'name': 'ศัลยกรรม'},
    {'id': 'DEP004', 'name': 'ออร์โธปิดิกส์'},
    {'id': 'DEP005', 'name': 'สูติ-นรีเวช'},
    {'id': 'DEP006', 'name': 'กุมารเวชกรรม'},
  ];

  /// วัตถุประสงค์การนัด (mock)
  static const List<String> appointmentPurposes = [
    'Work Up',
    'Follow Up',
    'Check Up',
    'OR',
  ];

  /// แพทย์ (mock)
  static final List<Map<String, dynamic>> doctors = [
    {
      'id': 'DOC001',
      'name': 'พญ. ธนวัฒน์ แก้วพรหม',
      'departmentId': 'DEP001',
      'specialty': 'จักษุวิทยา',
    },
    {
      'id': 'DOC002',
      'name': 'นพ. สมชาย รักษ์ดี',
      'departmentId': 'DEP001',
      'specialty': 'จักษุวิทยา',
    },
    {
      'id': 'DOC003',
      'name': 'พญ. วรรณา สุขใจ',
      'departmentId': 'DEP002',
      'specialty': 'อายุรศาสตร์',
    },
    {
      'id': 'DOC004',
      'name': 'นพ. ประยุทธ์ มั่นคง',
      'departmentId': 'DEP002',
      'specialty': 'อายุรศาสตร์โรคหัวใจ',
    },
    {
      'id': 'DOC005',
      'name': 'นพ. วิชัย เก่งกาจ',
      'departmentId': 'DEP003',
      'specialty': 'ศัลยศาสตร์',
    },
    {
      'id': 'DOC006',
      'name': 'พญ. สุดา ใจดี',
      'departmentId': 'DEP004',
      'specialty': 'ออร์โธปิดิกส์',
    },
  ];

  /// ตารางออกตรวจแพทย์ (mock) — key = doctorId
  /// shifts: morning (กะเช้า 09:00-12:00), afternoon (กะบ่าย 13:00-16:00)
  static final List<Map<String, dynamic>> doctorSchedules = [
    {
      'doctorId': 'DOC001',
      'date': '2026-03-13',
      'shifts': ['morning', 'afternoon'],
      'purposes': ['Work Up', 'Follow Up'],
    },
    {
      'doctorId': 'DOC002',
      'date': '2026-03-13',
      'shifts': ['morning'],
      'purposes': ['Work Up', 'Check Up'],
    },
    {
      'doctorId': 'DOC003',
      'date': '2026-03-13',
      'shifts': ['afternoon'],
      'purposes': ['Follow Up'],
    },
    {
      'doctorId': 'DOC001',
      'date': '2026-03-14',
      'shifts': ['morning'],
      'purposes': ['OR'],
    },
    {
      'doctorId': 'DOC004',
      'date': '2026-03-14',
      'shifts': ['morning', 'afternoon'],
      'purposes': ['Work Up', 'Follow Up', 'Check Up'],
    },
    {
      'doctorId': 'DOC005',
      'date': '2026-03-14',
      'shifts': ['afternoon'],
      'purposes': ['OR'],
    },
    {
      'doctorId': 'DOC002',
      'date': '2026-03-15',
      'shifts': ['morning', 'afternoon'],
      'purposes': ['Work Up', 'Follow Up'],
    },
    {
      'doctorId': 'DOC006',
      'date': '2026-03-15',
      'shifts': ['morning'],
      'purposes': ['Check Up', 'Follow Up'],
    },
  ];

  /// ข้อมูลลงทะเบียนคนไข้ (mock) — key = patientHn
  static final Map<String, PatientRegistration> patientRegistrations = {
    '260306-002': PatientRegistration(
      fullName: 'นางสาว ทดสอบผู้ติดต่อ ระบบใหม่',
      fullNameEn: 'Miss THODSOB PHUTIDTOR RABOBMAI',
      hn: '260306-002',
      nationalId: '1104200345550',
      gender: 'หญิง',
      bloodType: '-',
      birthDate: '15 มีนาคม 2539 | Mar 15, 1996',
      age: 30,
      religion: '-',
      nationality: '-',
      patientSource: 'TELEMED',
      phone: '089-999-8888',
      officePhone: '-',
      email: '-',
      currentAddress: '123 ถ.สุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110',
      maritalStatus: 'โสด',
      occupation: 'พนักงานบริษัท',
      workplace: 'บริษัท ทดสอบ จำกัด',
      emergencyContact: 'นาย ทดสอบ ระบบใหม่',
      emergencyPhone: '081-234-5678',
      emergencyRelation: 'บิดา',
      underlyingDisease: '-',
      surgeryHistory: '-',
      familyHistory: '-',
      smokingStatus: 'ไม่สูบ',
      drinkingStatus: 'ไม่ดื่ม',
      otherAllergy: '-',
      foodAllergy: '-',
      drugAllergies: [],
    ),
    '260225-003': PatientRegistration(
      fullName: 'นาง บุญมี ทองคำ',
      fullNameEn: 'Mrs. BOONMEE THONGKHAM',
      hn: '260225-003',
      nationalId: '3100500789012',
      gender: 'หญิง',
      bloodType: 'O',
      birthDate: '2 กรกฎาคม 2493 | Jul 2, 1950',
      age: 75,
      religion: 'พุทธ',
      nationality: 'ไทย',
      patientSource: 'Walk-in',
      phone: '081-234-5678',
      officePhone: '-',
      email: '-',
      currentAddress: '45/2 ม.3 ต.บางปู อ.เมือง จ.สมุทรปราการ 10280',
      maritalStatus: 'สมรส',
      occupation: 'แม่บ้าน',
      workplace: '-',
      emergencyContact: 'นาย สมชาย ทองคำ',
      emergencyPhone: '089-876-5432',
      emergencyRelation: 'บุตร',
      underlyingDisease: 'เบาหวาน, ความดันโลหิตสูง',
      surgeryHistory: 'ผ่าตัดไส้ติ่ง พ.ศ.2545',
      familyHistory: 'บิดาเป็นเบาหวาน',
      smokingStatus: 'ไม่สูบ',
      drinkingStatus: 'ไม่ดื่ม',
      otherAllergy: 'ฝุ่น, ละอองเกสรดอกไม้',
      foodAllergy: 'อาหารทะเล',
      drugAllergies: [
        DrugAllergy(
          drugName: 'Aspirin',
          reaction: 'ผื่นแดง คัน',
          severity: 'moderate',
        ),
        DrugAllergy(
          drugName: 'Penicillin',
          reaction: 'หายใจลำบาก บวม',
          severity: 'severe',
        ),
      ],
    ),
  };
}
