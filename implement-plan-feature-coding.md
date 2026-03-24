# MedFlow User App - Implementation Plan

> **สำคัญ**: ต้อง update ไฟล์นี้ทุกครั้ง เมื่อมีการเพิ่มฟีเจอร์ใหม่ หรือแก้ไขอะไรเพิ่มเติมภายในโปรเจค

## Overview
Mobile application for MedFlow HIS (Hospital Information System) - Doctor/User app.
Thai language UI. Theme follows MedFlow HIS web application design system.

## Tech Stack
- Flutter (Dart)
- Material Design 3
- Google Fonts (Athiti)
- flutter_blue_plus (BLE medical device communication)
- permission_handler (runtime permissions for Bluetooth)
- API integration (auth, telemed/appointment)
- Mock data (for patient list, vital signs — pending API integration)

## Color Theme (Teal-based)
- Primary Teal: #0d9488
- Primary Dark: #115e59
- Primary Light: #14b8a6
- Background: #f8fafc
- Surface: #FFFFFF
- Text Primary: #1E293B
- Text Secondary: #64748B
- Line/Border: #E2E8F0

---

## Features

### 1. Login Page ✅
- **Status**: Implemented (API integrated)
- **File**: `lib/pages/login_page.dart`
- **Description**: Login page with username/password fields and Google Sign-In button
- **UI**: Teal gradient background, white card form, Google login + standard login buttons
- **Data**: API — `AuthService.login()` → `/api/v1/auth/login`, then `AuthService.me()` → `/api/v1/auth/me`
- **Features**:
  - Riverpod (`ConsumerStatefulWidget`) — stores token/user in `loginProvider`/`userProvider`
  - "จดจำบัญชีผู้ใช้" checkbox — saves/loads credentials via `shared_preferences` (`LocalStorageService`)
  - Loading spinner + error SnackBar
- **Dependencies**: `lib/services/auth_service.dart`, `lib/services/local_storage_service.dart`, `lib/provider/common_provider.dart`

### 2. Home Page (หน้าหลัก) ✅
- **Status**: Implemented (API integrated)
- **File**: `lib/pages/home_page.dart`
- **Description**: Dashboard หน้าแรก — profile card, เมนูแนะนำ, ส่งต่อโรงพยาบาล, ประกาศ
- **UI**: Profile card (gradient, user fullName/systemRole from `userProvider`), 4 menu icons (Vital Sign, รายการสั่งยา, ผลวินิจฉัย, รายงาน), queue cards, announcement cards
- **Data**: `ref.watch(userProvider)` for profile info (from API `/me`)

### 3. Patient List Page (คนไข้) ✅
- **Status**: Implemented
- **File**: `lib/pages/patient_list_page.dart`
- **Description**: List of registered patients with search functionality
- **UI**: Search bar, patient cards with avatar, name, HN, phone, age, gender
- **Responsive**: Tablet landscape — search panel ซ้าย (350px), card list ขวา (>= 700px)
- **Data**: Mock patient data (5 patients)

### 4. Appointment List Page (นัดหมาย) ✅
- **Status**: Implemented (API integrated)
- **File**: `lib/pages/appointment_list_page.dart`
- **Description**: List of appointments with date filter and search
- **UI**: Search bar (ชื่อ/HN), date picker, appointment cards with doctor info, loading/error/empty states, pull-to-refresh
- **Responsive**: Tablet landscape — search panel ซ้าย (350px), card list ขวา (>= 700px)
- **Data**: API — `TelemedService.appointment()` → `/api/v1/telemed/sessions?date=YYYY-MM-DD`
- **Models**: `AppointmentModel` (with nested `PatientModel`, `DoctorModel`)
- **FAB**: ปุ่ม + สำหรับสร้างนัดหมายใหม่ → push to CreateAppointmentPage

### 5. Create Appointment Page (สร้างนัดหมายใหม่) 🚧
- **Status**: In Progress (Step 1 done, Step 2-3 placeholder)
- **File**: `lib/pages/create_appointment_page.dart`
- **Description**: สร้างนัดหมายใหม่แบบ step-by-step (3 steps)
- **UI**:
  - Step indicator ด้านบน: วงกลมตัวเลข + เส้นเชื่อม (สีเปลี่ยนตาม state: completed/active/pending)
  - Bottom nav: ปุ่ม "ย้อนกลับ" (outline) + "ถัดไป"/"ยืนยัน" (primary)
  - **Step 1 (เลือกคนไข้)**: ช่องค้นหาชื่อ/HN, รายการคนไข้แบบการ์ด (avatar, ชื่อ, HN, อายุ), กดเลือกได้ 1 คน (radio-style), ต้องเลือกก่อนถึงกด "ถัดไป" ได้
  - **Step 2 (รายละเอียดนัด)**: placeholder — รอ implement
  - **Step 3 (ยืนยัน)**: placeholder — รอ implement
- **Navigation**: กดจาก FAB ในหน้า AppointmentListPage → push to create page

### 6. Appointment Detail Page (รายละเอียดนัดหมาย) ✅
- **Status**: Implemented
- **File**: `lib/pages/appointment_detail_page.dart`
- **Description**: รายละเอียดการนัดหมาย เข้าถึงจากการกดที่ AppointmentCard
- **UI**:
  - การ์ดคนไข้ด้านบน: avatar, ชื่อ TH/EN, วดป เกิด, badge HN
  - ปุ่ม "รายละเอียด" (info icon) + "Telemed" (phone icon)
  - 5 แท็ป: ข้อมูลนัด | คัดกรอง | การวัด | วินิจฉัย | สั่งการรักษา
  - แท็ป "ข้อมูลนัด": วันที่นัด (badge สีเขียว), สถานะ, เวลามา, การ์ดแพทย์ (badge เวลานัดสีฟ้า), โน้ต
  - แท็ป "คัดกรอง": ฟอร์มกรอก CC, PI, PH, PE (2 คอลัมน์), ปุ่มเพิ่ม, รายการ "ปัจจุบัน" / "ย้อนหลัง", การ์ดแสดง CC/PI/PH/PE + ผู้บันทึก + วันเวลา, ปุ่มแก้ไข/ลบ
  - แท็ป "การวัด": ปุ่ม "อ่านค่าจากเครื่อง" (BLE), ฟอร์มกรอกค่า vital signs (Bw, Ht, BMI auto-calc, sBp, dBp, Pr, O2, Temp), ตารางข้อมูลแบ่ง "ปัจจุบัน" / "ย้อนหลัง", ปุ่มลบ
  - แท็ป "วินิจฉัย": ฟอร์มเพิ่มวินิจฉัย (บันทึกผลตรวจ, คำวินิจฉัย, เลือก ICD10), รายการ "วินิจฉัยปัจจุบัน" (วันนี้), รายการ "ย้อนหลัง" (วันก่อน), ปุ่มแก้ไข/ลบ
  - แท็ป "สั่งการรักษา": การ์ดเตือนแพ้ยา (แสดงเมื่อคนไข้มีประวัติแพ้ยา, แสดงชื่อยา + อาการ + ระดับความรุนแรง), ปุ่ม "+สั่งยา" / "+หัตถการ", ฟอร์ม inline ตามประเภท (SearchSelector สำหรับชื่อยา/หัตถการ/วิธีใช้, ยาที่แพ้จะมี badge "แพ้ยานี้" สีแดง + กดเลือกไม่ได้), จำนวน + หน่วย + ราคาต่อหน่วย (ยา: แก้ไขจำนวนได้, หัตถการ: ล็อก 1 ครั้ง), การ์ดแสดงข้อมูล (badge สีตามประเภท, จำนวน, ราคา, ราคารวม, toggle ON/OFF, ปุ่มแก้ไข/ลบ), สรุปรายการ (จำนวน + ราคารวม ทั้งปัจจุบันและย้อนหลัง), ย้อนหลัง group ตามวัน
- **Responsive**: Tablet landscape — การ์ดคนไข้ซ้าย (380px), แท็ปขวา (>= 700px)
- **Navigation**: กดจาก AppointmentCard → push to detail page

### 7. Patient Detail Page (รายละเอียดคนไข้) ✅
- **Status**: Implemented
- **File**: `lib/pages/patient_detail_page.dart`
- **Description**: รายละเอียดคนไข้ เข้าถึงจากการกดที่ PatientCard ในหน้ารายการคนไข้
- **UI**:
  - การ์ดคนไข้ด้านบน: avatar (initials สีตามเพศ), ชื่อ TH/EN, badge HN, เบอร์โทร, อายุ, ไอคอนเพศ
  - 4 แท็ป: สำคัญ | ส่วนตัว | สุขภาพ | แพ้ยา
  - แท็ป "สำคัญ": ข้อมูลตามบัตรประชาชน (HN, เลขบัตร, เพศ, กรุ๊ปเลือด, วันเกิด ฯลฯ), ช่องทางติดต่อ, ที่อยู่ปัจจุบัน
  - แท็ป "ส่วนตัว": สถานภาพ, อาชีพ, สถานที่ทำงาน, ผู้ติดต่อฉุกเฉิน
  - แท็ป "สุขภาพ": โรคประจำตัว, ประวัติผ่าตัด, ประวัติครอบครัว, แพ้อื่นๆ, แพ้อาหาร, พฤติกรรม (แต่ละรายการเป็นการ์ดแยก)
  - แท็ป "แพ้ยา": การ์ดแสดงยาที่แพ้ + อาการ + ระดับความรุนแรง (badge สี)
- **Responsive**: Tablet landscape — การ์ดคนไข้ซ้าย (380px), แท็ปขวา (>= 700px)
- **Navigation**: กดจาก PatientCard → push to detail page
- **Data**: ดึงจาก MockData.patientRegistrations ตาม HN

### 8. Profile Page (ข้อมูลส่วนตัว) ✅
- **Status**: Implemented
- **File**: `lib/pages/profile_page.dart`
- **Description**: User profile display with logout button
- **UI**: Centered avatar, doctor name, logout button

### 9. Bottom Navigation ✅
- **Status**: Implemented
- **File**: `lib/pages/main_page.dart`
- **Tabs**: หน้าหลัก | คนไข้ | นัดหมาย | ผู้ใช้งาน

---

## Project Structure
```
lib/
├── main.dart
├── app/
│   └── theme.dart
├── models/
│   ├── patient.dart
│   ├── patient_model.dart          (API model — Map-based)
│   ├── appointment.dart            (legacy mock model)
│   ├── appointment_model.dart      (API model — Map-based, with PatientModel/DoctorModel)
│   ├── doctor_model.dart           (API model)
│   ├── login_model.dart            (API model — access_token, refresh_token, user, hospital)
│   ├── user_model.dart             (API model — id, username, fullName, systemRole, features)
│   ├── hospital_model.dart         (API model)
│   ├── response_model.dart         (generic API response wrapper)
│   ├── diagnosis.dart
│   ├── screening.dart
│   ├── vital_sign.dart
│   └── treatment_order.dart
├── pages/
│   ├── login_page.dart
│   ├── main_page.dart
│   ├── home_page.dart
│   ├── patient_list_page.dart
│   ├── appointment_list_page.dart
│   ├── patient_detail_page.dart
│   ├── create_appointment_page.dart
│   ├── appointment_detail_page.dart
│   └── profile_page.dart
├── services/
│   ├── auth_service.dart           (login, me API)
│   ├── telemed_service.dart        (appointment sessions API)
│   ├── local_storage_service.dart  (shared_preferences — remember credentials)
│   ├── configuration.dart          (API base URL, port config)
│   ├── android_bridge.dart         (MethodChannel — Thai ID card reader)
│   ├── ble_service.dart
│   ├── ble_permission_handler.dart
│   └── ble_gatt_parser.dart
├── provider/
│   └── common_provider.dart        (loginProvider, userProvider)
├── widgets/
│   ├── patient_card.dart
│   ├── appointment_card.dart
│   ├── diagnosis_tab.dart
│   ├── screening_tab.dart
│   ├── measurement_tab.dart
│   ├── treatment_order_tab.dart
│   ├── search_selector_field.dart
│   ├── patient_detail_bottom_sheet.dart
│   └── ble_measurement_bottom_sheet.dart
└── data/
    └── mock_data.dart
```

---

## Data Models

### Patient (`lib/models/patient.dart`)
- id, prefix, firstName, lastName, hn, phone, age, gender, avatarUrl?

### Appointment (`lib/models/appointment.dart`)
- id, patientName, patientNameEn?, patientHn?, patientAge?, isRegistered, patientAvatarUrl?
- birthDate?, appointmentDate?, status, arrivalTime?, note?
- doctorVisits: List<DoctorVisit>

### DoctorVisit (ใน appointment.dart)
- doctorName, purpose, forDepartment?, doctorAvatarUrl?, appointmentTime?, department?

### Diagnosis (`lib/models/diagnosis.dart`)
- id, recordNote, diagnosisType, icd10, icdDesc, snTerm, diagnosisNote, recorderName, recordedAt
- isToday (computed): ตรวจว่าเป็นข้อมูลวันนี้หรือไม่

### VitalSign (`lib/models/vital_sign.dart`)
- id, bw?, ht?, bmi?, sBp?, dBp?, pr?, o2?, temp?, recorderName, recordedAt
- isToday (computed): ตรวจว่าเป็นข้อมูลวันนี้หรือไม่
- calculateBmi(bw, ht) (static): คำนวณ BMI จาก น้ำหนัก/ส่วนสูง

### Screening (`lib/models/screening.dart`)
- id, cc, pi, ph, pe, recorderName, recordedAt
- isToday (computed): ตรวจว่าเป็นข้อมูลวันนี้หรือไม่

### TreatmentOrder (`lib/models/treatment_order.dart`)
- id, type (enum: medicine/procedure), name, usage?, quantity, unit, pricePerUnit, isActive, recorderName, recordedAt
- totalPrice (computed): quantity * pricePerUnit
- isToday (computed): ตรวจว่าเป็นข้อมูลวันนี้หรือไม่
- copyWith(isActive): สร้าง copy พร้อมเปลี่ยน isActive

### BleDeviceInfo (`lib/models/ble_device_info.dart`)
- device (BluetoothDevice), name, rssi, serviceUuids
- fromScanResult(ScanResult): factory สร้างจาก scan result

### BleMeasurementResult (`lib/models/ble_measurement_result.dart`)
- deviceType (enum: bloodPressure/weightScale/pulseOximeter/thermometer)
- systolic?, diastolic?, pulseRate?, weight?, spO2?, temperature?
- timestamp

---

## BLE Integration

### ฟีเจอร์ "อ่านค่าจากเครื่อง" ✅
- **Status**: Implemented
- **ปุ่มใน**: `lib/widgets/measurement_tab.dart`
- **Bottom Sheet**: `lib/widgets/ble_measurement_bottom_sheet.dart`
- **Services**: `lib/services/ble_service.dart`, `ble_permission_handler.dart`, `ble_gatt_parser.dart`
- **Description**: เชื่อมต่ออุปกรณ์วัดค่าทางการแพทย์ผ่าน Bluetooth Low Energy
- **4 แท็ป**: ความดัน (0x1810) | น้ำหนัก (0x181D) | O2 (0x1822) | อุณหภูมิ (0x1809)
- **Flow**: กดปุ่ม → เปิด bottom sheet → สแกน → เลือกอุปกรณ์ → เชื่อมต่อ → อ่านค่า → autofill ฟอร์ม
- **Platform Configs**: Android (BLUETOOTH_SCAN, BLUETOOTH_CONNECT, ACCESS_FINE_LOCATION), iOS (NSBluetoothAlwaysUsageDescription), macOS (com.apple.security.device.bluetooth)

---

## Pending / Future Features
- [x] API integration — Login (`AuthService`), User profile (`AuthService.me`), Appointments (`TelemedService`)
- [ ] API integration — Patient list, Vital Signs (ยังใช้ mock data)
- [ ] Real Google Sign-In authentication
- [x] Patient detail page — กดจาก PatientCard → push to detail page, 4 แท็ป (สำคัญ/ส่วนตัว/สุขภาพ/แพ้ยา)
- [x] Appointment detail — แท็ปคัดกรอง (CC, PI, PH, PE)
- [x] Treatment order — จำนวน + หน่วย + ราคา, สรุปรายการ, group ย้อนหลังตามวัน
- [ ] Appointment detail — แท็ปการวัด sub-tabs: อาการ, โน้ตพยาบาล
- [ ] Profile editing
- [ ] Push notifications
- [ ] Offline data caching
