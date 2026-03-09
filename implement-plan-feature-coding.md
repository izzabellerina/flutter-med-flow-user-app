# MedFlow User App - Implementation Plan

> **สำคัญ**: ต้อง update ไฟล์นี้ทุกครั้ง เมื่อมีการเพิ่มฟีเจอร์ใหม่ หรือแก้ไขอะไรเพิ่มเติมภายในโปรเจค

## Overview
Mobile application for MedFlow HIS (Hospital Information System) - Doctor/User app.
Thai language UI. Theme follows MedFlow HIS web application design system.

## Tech Stack
- Flutter (Dart)
- Material Design 3
- Google Fonts (Athiti)
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

### 1. Login Screen ✅
- **Status**: Implemented
- **File**: `lib/screens/login_screen.dart`
- **Description**: Login page with username/password fields and Google Sign-In button
- **UI**: Teal gradient background, white card form, Google login + standard login buttons
- **Data**: Mock authentication (any credentials accepted)

### 2. Home Screen (หน้าหลัก) ✅
- **Status**: Implemented
- **File**: `lib/screens/home_screen.dart`
- **Description**: Coming soon placeholder page
- **UI**: Hospital illustration icon, "พบกับหน้าแรกในเร็ว ๆ นี้" text, version info

### 3. Patient List Screen (คนไข้) ✅
- **Status**: Implemented
- **File**: `lib/screens/patient_list_screen.dart`
- **Description**: List of registered patients with search functionality
- **UI**: Search bar, patient cards with avatar, name, HN, phone, age, gender
- **Responsive**: Tablet landscape — search panel ซ้าย (350px), card list ขวา (>= 700px)
- **Data**: Mock patient data (5 patients)

### 4. Appointment List Screen (นัดหมาย) ✅
- **Status**: Implemented
- **File**: `lib/screens/appointment_list_screen.dart`
- **Description**: List of appointments with date filter and search
- **UI**: Search bar, date picker, unregistered filter checkbox, appointment cards with doctor info
- **Responsive**: Tablet landscape — search panel ซ้าย (350px), card list ขวา (>= 700px)
- **Data**: Mock appointment data (4 appointments)

### 5. Appointment Detail Screen (รายละเอียดนัดหมาย) ✅
- **Status**: Implemented
- **File**: `lib/screens/appointment_detail_screen.dart`
- **Description**: รายละเอียดการนัดหมาย เข้าถึงจากการกดที่ AppointmentCard
- **UI**:
  - การ์ดคนไข้ด้านบน: avatar, ชื่อ TH/EN, วดป เกิด, badge HN
  - ปุ่ม "รายละเอียด" (info icon) + "Telemed" (phone icon)
  - 5 แท็ป: ข้อมูลนัด | การวัด | วินิจฉัย | สั่งยา | สั่งการรักษา
  - แท็ป "ข้อมูลนัด": วันที่นัด (badge สีเขียว), สถานะ, เวลามา, การ์ดแพทย์ (badge เวลานัดสีฟ้า), โน้ต
  - แท็ปอื่น: placeholder "พบกันเร็ว ๆ นี้"
- **Responsive**: Tablet landscape — การ์ดคนไข้ซ้าย (380px), แท็ปขวา (>= 700px)
- **Navigation**: กดจาก AppointmentCard → push to detail screen

### 6. Profile Screen (ข้อมูลส่วนตัว) ✅
- **Status**: Implemented
- **File**: `lib/screens/profile_screen.dart`
- **Description**: User profile display with logout button
- **UI**: Centered avatar, doctor name, logout button

### 7. Bottom Navigation ✅
- **Status**: Implemented
- **File**: `lib/screens/main_screen.dart`
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
│   └── appointment.dart
├── screens/
│   ├── login_screen.dart
│   ├── main_screen.dart
│   ├── home_screen.dart
│   ├── patient_list_screen.dart
│   ├── appointment_list_screen.dart
│   ├── appointment_detail_screen.dart
│   └── profile_screen.dart
├── widgets/
│   ├── patient_card.dart
│   └── appointment_card.dart
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

---

## Pending / Future Features
- [ ] API integration (replace mock data)
- [ ] Real Google Sign-In authentication
- [ ] Patient detail screen
- [ ] Appointment detail — เนื้อหาแท็ป: การวัด, วินิจฉัย, สั่งยา, สั่งการรักษา
- [ ] Profile editing
- [ ] Push notifications
- [ ] Offline data caching
