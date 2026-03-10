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
- Mock data (pending API integration)

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
- **Status**: Implemented
- **File**: `lib/pages/login_page.dart`
- **Description**: Login page with username/password fields and Google Sign-In button
- **UI**: Teal gradient background, white card form, Google login + standard login buttons
- **Data**: Mock authentication (any credentials accepted)

### 2. Home Page (หน้าหลัก) ✅
- **Status**: Implemented
- **File**: `lib/pages/home_page.dart`
- **Description**: Coming soon placeholder page
- **UI**: Hospital illustration icon, "พบกับหน้าแรกในเร็ว ๆ นี้" text, version info

### 3. Patient List Page (คนไข้) ✅
- **Status**: Implemented
- **File**: `lib/pages/patient_list_page.dart`
- **Description**: List of registered patients with search functionality
- **UI**: Search bar, patient cards with avatar, name, HN, phone, age, gender
- **Responsive**: Tablet landscape — search panel ซ้าย (350px), card list ขวา (>= 700px)
- **Data**: Mock patient data (5 patients)

### 4. Appointment List Page (นัดหมาย) ✅
- **Status**: Implemented
- **File**: `lib/pages/appointment_list_page.dart`
- **Description**: List of appointments with date filter and search
- **UI**: Search bar, date picker, unregistered filter checkbox, appointment cards with doctor info
- **Responsive**: Tablet landscape — search panel ซ้าย (350px), card list ขวา (>= 700px)
- **Data**: Mock appointment data (4 appointments)

### 5. Appointment Detail Page (รายละเอียดนัดหมาย) ✅
- **Status**: Implemented
- **File**: `lib/pages/appointment_detail_page.dart`
- **Description**: รายละเอียดการนัดหมาย เข้าถึงจากการกดที่ AppointmentCard
- **UI**:
  - การ์ดคนไข้ด้านบน: avatar, ชื่อ TH/EN, วดป เกิด, badge HN
  - ปุ่ม "รายละเอียด" (info icon) + "Telemed" (phone icon)
  - 4 แท็ป: ข้อมูลนัด | การวัด | วินิจฉัย | สั่งการรักษา
  - แท็ป "ข้อมูลนัด": วันที่นัด (badge สีเขียว), สถานะ, เวลามา, การ์ดแพทย์ (badge เวลานัดสีฟ้า), โน้ต
  - แท็ป "การวัด": ปุ่ม "อ่านค่าจากเครื่อง" (BLE), ฟอร์มกรอกค่า vital signs (Bw, Ht, BMI auto-calc, sBp, dBp, Pr, O2, Temp), ตารางข้อมูลแบ่ง "ปัจจุบัน" / "ย้อนหลัง", ปุ่มลบ
  - แท็ป "วินิจฉัย": ฟอร์มเพิ่มวินิจฉัย (บันทึกผลตรวจ, คำวินิจฉัย, เลือก ICD10), รายการ "วินิจฉัยปัจจุบัน" (วันนี้), รายการ "ย้อนหลัง" (วันก่อน), ปุ่มแก้ไข/ลบ
  - แท็ป "สั่งการรักษา": ปุ่ม "+สั่งยา" / "+หัตถการ", ฟอร์ม inline ตามประเภท, การ์ดแสดงข้อมูล (badge สีตามประเภท, toggle ON/OFF, ปุ่มแก้ไข/ลบ), แบ่ง "ปัจจุบัน" / "ย้อนหลัง"
- **Responsive**: Tablet landscape — การ์ดคนไข้ซ้าย (380px), แท็ปขวา (>= 700px)
- **Navigation**: กดจาก AppointmentCard → push to detail page

### 6. Profile Page (ข้อมูลส่วนตัว) ✅
- **Status**: Implemented
- **File**: `lib/pages/profile_page.dart`
- **Description**: User profile display with logout button
- **UI**: Centered avatar, doctor name, logout button

### 7. Bottom Navigation ✅
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
│   ├── appointment.dart
│   ├── diagnosis.dart
│   ├── vital_sign.dart
│   └── treatment_order.dart
├── pages/
│   ├── login_page.dart
│   ├── main_page.dart
│   ├── home_page.dart
│   ├── patient_list_page.dart
│   ├── appointment_list_page.dart
│   ├── appointment_detail_page.dart
│   └── profile_page.dart
├── services/
│   ├── ble_service.dart
│   ├── ble_permission_handler.dart
│   └── ble_gatt_parser.dart
├── widgets/
│   ├── patient_card.dart
│   ├── appointment_card.dart
│   ├── diagnosis_tab.dart
│   ├── measurement_tab.dart
│   ├── treatment_order_tab.dart
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

### TreatmentOrder (`lib/models/treatment_order.dart`)
- id, type (enum: medicine/procedure), name, usage?, isActive, recorderName, recordedAt
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
- [ ] API integration (replace mock data)
- [ ] Real Google Sign-In authentication
- [ ] Patient detail page
- [ ] Appointment detail — แท็ปการวัด sub-tabs: อาการ, โน้ตพยาบาล
- [ ] Profile editing
- [ ] Push notifications
- [ ] Offline data caching
