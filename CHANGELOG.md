# Changelog

บันทึกการเปลี่ยนแปลงของแอป MedFlow User App แต่ละเวอร์ชัน

รูปแบบอ้างอิง [Keep a Changelog](https://keepachangelog.com/) และใช้ [Semantic Versioning](https://semver.org/)

---

<details>
<summary><b>[0.7.1] - 2026-04-24 (Current)</b> — Impeller fix + iOS BLE permission + Version display</summary>

### Added
- **Version display** ในหน้า login — โชว์ `v0.7.1 (1) · 2026-04-24`
- `package_info_plus: ^8.0.0` — อ่าน version/buildNumber จาก `pubspec.yaml` ที่ runtime (ซิงก์อัตโนมัติ)
- `AppVersion` class ([lib/app/app_version.dart](lib/app/app_version.dart)) — เก็บ version กลาง + `buildDate` constant
- `CHANGELOG.md` — บันทึกประวัติการเปลี่ยนแปลงย้อนหลังทุก version (v0.1.0 → v0.7.1)

### Fixed
- ปิด Impeller rendering backend บน Android (ใช้ Skia แทน) — แก้ปัญหาหน้าจอดำบนเครื่อง iQOO I2508
  - เพิ่ม meta-data `io.flutter.embedding.android.EnableImpeller=false` ใน `AndroidManifest.xml`
- iOS Bluetooth permission — ข้าม `permission_handler` แล้วปล่อยให้ `flutter_blue_plus` ทริก native dialog เอง (อาศัย `NSBluetoothAlwaysUsageDescription` ใน `Info.plist`)
- iOS Camera/Mic permission — ให้ `InAppWebView` ทริก native dialog ผ่าน `onPermissionRequest` callback โดยไม่ผ่าน `permission_handler`

### Changed
- `BlePermissionHandler.requestPermissions()` บน iOS/macOS return `true` ทันที (ให้ native library จัดการเอง)
- `VitalSignModel.height` เปลี่ยน type จาก `int` เป็น `double` เพื่อให้ compatible กับ formatter
- `pubspec.yaml` version จาก `1.0.0+1` → `0.7.1+1` (ให้ตรงกับสถานะจริงของแอป)

</details>

---

<details>
<summary><b>[0.7.0] - 2026-03-26</b> — Physical Exam + Get All Vital Signs</summary>

### Added
- **แท็ปตรวจสุขภาพ (PE)** — เพิ่มแท็ปใหม่ก่อนแท็ปการวัด
  - General Appearance + PE Summary (text fields)
  - 9 ระบบร่างกาย: HEENT, Neck, Cardiovascular, Respiratory, Abdomen, Extremities, Neurological, Skin, Psychiatric
  - Toggle Normal/Abnormal — ถ้า Abnormal จะโชว์ช่องกรอกความผิดปกติ
  - เรียก `getPhysicalExam` ตอนเปิดแท็ป, `savePhysicalExam` ตอนกดบันทึก (update-only ไม่มีประวัติย้อนหลัง)
- `PhysicalExamRequestModel` + `PhysicalExamNoteItem` สำหรับ request body
- API `getAllVitalSign` — ดึง vital signs ย้อนหลังทั้งหมดของผู้ป่วยมาแสดงในการ์ด "สัญญาณชีพ"
  - เพิ่มวันที่บันทึกต่อจากผู้บันทึก

### Changed
- `CreateVitalSignModel` — ทำให้ทุก field เป็น optional ยกเว้น `sessionToken` (field ที่ไม่มีค่าจะส่ง `null`)
- Measurement tab เคลียร์ mock data ออก ใช้ API จริงแทน

</details>

---

<details>
<summary><b>[0.6.0] - 2026-03-24</b> — API Integration + Telemed Video Call</summary>

### Added
- **Login Service** — เชื่อม API login จริง (เดิมเป็น mock)
- **Profile card** ผูกกับ `UserProvider` (watch state)
- **Appointment APIs**
  - `appointment` — list นัดหมาย
  - `findOneAppointment` — รายละเอียดนัดหมายตาม id
- **Telemed Video Call** — ผสาน WebRTC ผ่าน `flutter_inappwebview ^6.1.5`
  - เปิด URL: `https://med3.medflow.in.th/teleconsult/join/{session_token}`
  - Fullscreen mode + Mini inline embed mode (สลับได้)
  - Responsive layout — Landscape: video ฝั่งซ้ายใต้ patient card / Portrait: ระหว่างแท็ปกับ content
  - Mini telemed scroll ไปพร้อม tab content (`NestedScrollView` + `SliverToBoxAdapter`)
  - โผล่ทุกแท็ป (ไม่ใช่เฉพาะแท็ปข้อมูลนัด)
- **Create/Get Vital Sign API** — POST `/api/public/telemed/join/{token}/vitals`
- **iOS Permissions**
  - Camera & Microphone (สำหรับ Telemed)
  - Bluetooth (สำหรับ BLE devices)
  - เพิ่ม `NSCameraUsageDescription`, `NSMicrophoneUsageDescription`, `NSBluetoothAlwaysUsageDescription` ใน `Info.plist`
  - ตั้ง permission macros ใน `Podfile` (`PERMISSION_CAMERA`, `PERMISSION_MICROPHONE`, `PERMISSION_BLUETOOTH`, `PERMISSION_LOCATION`)
- **Android Permissions** — Camera, RECORD_AUDIO, MODIFY_AUDIO_SETTINGS, INTERNET

### Changed
- หน้า login ใช้ service จริงแทน hardcode

</details>

---

<details>
<summary><b>[0.5.0] - 2026-03-16</b> — Smart Card Reader + Home + Vital Sign UI</summary>

### Added
- **Smart Card Reader** integration (USB Host)
  - `<uses-feature android:name="android.hardware.usb.host" />`
  - USB device filter + `USB_DEVICE_ATTACHED` intent filter
- **หน้า Home** — dashboard หลัก
- **Vital Sign UI** — layout การแสดงสัญญาณชีพในการ์ด

</details>

---

<details>
<summary><b>[0.4.0] - 2026-03-13</b> — Patient Registration + Create Appointment Flow</summary>

### Added
- **หน้า Patient Detail** — รายละเอียดผู้ป่วย
- **หน้า Patient Register** — ลงทะเบียนผู้ป่วยใหม่
- **Create Appointment Flow** 3 ขั้นตอน
  - Step 1: เลือกผู้ป่วย
  - Step 2: เลือกวัน/เวลา
  - Step 3: ยืนยันและบันทึก
- **UI Treatment tab** — เพิ่มโครงสร้างแท็ป Rx/Treatment Order

</details>

---

<details>
<summary><b>[0.3.0] - 2026-03-12</b> — Patient Info + Screening</summary>

### Added
- **หน้า Patient Info** — ข้อมูลผู้ป่วย
- **Screening Tab** — แท็ปคัดกรอง
- **Custom Widgets**
  - `OutlinedButton` — ปุ่มแบบ outline มาตรฐาน
  - `SelectorForm` — form เลือกตัวเลือก (dropdown/radio)

</details>

---

<details>
<summary><b>[0.2.0] - 2026-03-10</b> — Diagnosis + Measurement + BLE</summary>

### Added
- **Diagnosis Tab** — แท็ปวินิจฉัย (UI + form)
- **Measurement Tab** — แท็ปการวัด (input Bw, Ht, sBp, dBp, Pr, O2, Temp)
- **Treatment Order Tab** — แท็ปคำสั่งการรักษา
- **BLE Device Reading** — อ่านค่าจากอุปกรณ์ Bluetooth ผ่าน `flutter_blue_plus`
  - `BleMeasurementBottomSheet` — bottom sheet เลือกและเชื่อมต่อ device
  - `BlePermissionHandler` — จัดการ permission BLE

### Changed
- ปรับ UI แท็ป Diagnosis

</details>

---

<details>
<summary><b>[0.1.0] - 2026-03-09</b> — Initial Release</summary>

### Added
- **Flutter Project** setup (initial)
- **Login Page** — หน้าล็อกอิน (mock)
- **หน้ารายละเอียดนัดหมาย** (Appointment Detail) พร้อม 4 แท็ปเริ่มต้น
  - ข้อมูลนัด
  - การวัด
  - วินิจฉัย
  - คำสั่งการรักษา
- ปรับโครงสร้างโฟลเดอร์ให้ใช้ `pages/` แทนชื่อเดิม

</details>

---

## Version Guide

| Version | วันที่ | จุดสำคัญ |
|---------|-------|----------|
| 0.7.1 | 2026-04-24 | Impeller fix + iOS permission refinements |
| 0.7.0 | 2026-03-26 | Physical Exam tab + Vital signs history API |
| 0.6.0 | 2026-03-24 | API integration + Telemed video call |
| 0.5.0 | 2026-03-16 | Smart Card Reader + Home |
| 0.4.0 | 2026-03-13 | Patient registration + Create appointment |
| 0.3.0 | 2026-03-12 | Patient info + Screening |
| 0.2.0 | 2026-03-10 | Diagnosis + Measurement + BLE |
| 0.1.0 | 2026-03-09 | Initial UI + Login + 4 tabs |

## Versioning Scheme

- **0.x.y** — ยังอยู่ในช่วง pre-release (pre-1.0)
- **MAJOR** (x) — เพิ่มขึ้นเมื่อมี feature ใหญ่หรือ breaking change
- **MINOR** (ไม่ใช้ช่วง 0.x) — สงวนไว้สำหรับหลัง 1.0
- **PATCH** (y) — bug fix หรือ minor tweak
- **1.0.0** — จะ release เมื่อครบ feature set สำหรับ production
