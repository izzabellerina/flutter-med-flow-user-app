# MedFlow User App - Implementation Plan

## Overview
Mobile application for MedFlow HIS (Hospital Information System) - Doctor/User app.
Thai language UI. Theme follows MedFlow HIS web application design system.

## Tech Stack
- Flutter (Dart)
- Material Design 3
- Mock data (pending API integration)

## Color Theme (from MedFlow HIS Web)
- Primary Blue: #1565C0
- Success Green: #4CAF50
- Warning/Badge Orange: #F57C00
- Background: #F5F7FA
- Surface: #FFFFFF
- Text Primary: #212121
- Text Secondary: #757575

---

## Features

### 1. Login Screen ✅
- **Status**: Implemented
- **Description**: Login page with username/password fields and Google Sign-In button
- **UI**: Blue gradient background, white card form, Google login + standard login buttons
- **Data**: Mock authentication (any credentials accepted)

### 2. Home Screen (หน้าหลัก) ✅
- **Status**: Implemented
- **Description**: Coming soon placeholder page
- **UI**: Hospital illustration icon, "พบกับหน้าแรกในเร็ว ๆ นี้" text, version info

### 3. Patient List Screen (คนไข้) ✅
- **Status**: Implemented
- **Description**: List of registered patients with search functionality
- **UI**: Search bar, patient cards with avatar, name, HN, phone, age, gender
- **Data**: Mock patient data

### 4. Appointment List Screen (นัดหมาย) ✅
- **Status**: Implemented
- **Description**: List of appointments with date filter and search
- **UI**: Search bar, date picker, unregistered filter checkbox, appointment cards with doctor info
- **Data**: Mock appointment data

### 5. Profile Screen (ข้อมูลส่วนตัว) ✅
- **Status**: Implemented
- **Description**: User profile display with logout button
- **UI**: Centered avatar, doctor name, logout button

### 6. Bottom Navigation ✅
- **Status**: Implemented
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
│   └── profile_screen.dart
├── widgets/
│   ├── patient_card.dart
│   └── appointment_card.dart
└── data/
    └── mock_data.dart
```

---

## Pending / Future Features
- [ ] API integration (replace mock data)
- [ ] Real Google Sign-In authentication
- [ ] Patient detail screen
- [ ] Appointment detail/create screen
- [ ] Profile editing
- [ ] Push notifications
- [ ] Offline data caching
