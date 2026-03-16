import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../services/android_bridge.dart';

class PatientRegistrationPage extends StatefulWidget {
  const PatientRegistrationPage({super.key});

  @override
  State<PatientRegistrationPage> createState() =>
      _PatientRegistrationPageState();
}

class _PatientRegistrationPageState extends State<PatientRegistrationPage> {
  // ── Thai name ──
  String? _prefixTh;
  final _firstNameThController = TextEditingController();
  final _middleNameThController = TextEditingController();
  final _lastNameThController = TextEditingController();

  // ── English name ──
  String? _prefixEn;
  final _firstNameEnController = TextEditingController();
  final _middleNameEnController = TextEditingController();
  final _lastNameEnController = TextEditingController();

  // ── ID ──
  final _nationalIdController = TextEditingController();
  final _passportController = TextEditingController();

  // ── Personal ──
  DateTime? _birthDate;
  String? _bloodType;
  String? _gender;

  // ── Contact ──
  final _phoneController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _emailController = TextEditingController();
  final _officePhoneController = TextEditingController();

  // ── Address ──
  final _addressController = TextEditingController();
  final _subdistrictController = TextEditingController();
  final _districtController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // ── Emergency ──
  final _emergencyPhoneController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  String? _emergencyRelation;

  bool _isScanning = false;

  // ── Card reader ──
  Timer? _statusTimer;
  bool _readerConnected = false;
  bool _cardInserted = false;
  Uint8List? _photoBytes;

  static const _prefixesTh = ['นาย', 'นาง', 'นางสาว', 'เด็กชาย', 'เด็กหญิง'];
  static const _prefixesEn = ['Mr.', 'Mrs.', 'Miss', 'Master'];
  static const _bloodTypes = ['A', 'B', 'AB', 'O', '-'];
  static const _genders = ['ชาย', 'หญิง'];
  static const _relations = [
    'บิดา',
    'มารดา',
    'บุตร',
    'คู่สมรส',
    'พี่น้อง',
    'อื่นๆ',
  ];

  @override
  void initState() {
    super.initState();
    _initCardReader();
  }

  void _initCardReader() {
    _pollCardStatus();
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _pollCardStatus();
    });
  }

  Future<void> _pollCardStatus() async {
    final status = await AndroidBridge.getCardStatus();
    if (!mounted) return;
    setState(() {
      _readerConnected = status['readerConnected'] == true;
      _cardInserted = status['cardInserted'] == true;
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _firstNameThController.dispose();
    _middleNameThController.dispose();
    _lastNameThController.dispose();
    _firstNameEnController.dispose();
    _middleNameEnController.dispose();
    _lastNameEnController.dispose();
    _nationalIdController.dispose();
    _passportController.dispose();
    _phoneController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _officePhoneController.dispose();
    _addressController.dispose();
    _subdistrictController.dispose();
    _districtController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyNameController.dispose();
    super.dispose();
  }

  Future<void> _readFromCardReader() async {
    if (_isScanning) return;
    setState(() => _isScanning = true);

    // Stop polling during read to avoid concurrent reader access
    _statusTimer?.cancel();

    try {
      final data = await AndroidBridge.readAllCardData();

      if (!mounted) return;

      if (data.containsKey('error')) {
        throw Exception(data['error']);
      }

      // Parse Thai name (format: "คำนำหน้า#ชื่อ#นามสกุล" or "คำนำหน้า#ชื่อ#ชื่อกลาง#นามสกุล")
      final thaiName = (data['thaiName'] as String? ?? '').trim();
      final thaiParts = thaiName
          .split('#')
          .where((s) => s.trim().isNotEmpty)
          .toList();
      String? parsedPrefixTh;
      String firstNameTh = '';
      String lastNameTh = '';
      if (thaiParts.isNotEmpty) {
        for (final prefix in _prefixesTh) {
          if (thaiParts[0].trim() == prefix ||
              thaiParts[0].trim().startsWith(prefix)) {
            parsedPrefixTh = prefix;
            break;
          }
        }
        if (thaiParts.length >= 3) {
          firstNameTh = thaiParts[1].trim();
          lastNameTh = thaiParts.last.trim();
        } else if (thaiParts.length == 2) {
          firstNameTh = thaiParts[1].trim();
        }
      }

      // Parse English name (format: "Title#FirstName#MiddleName#LastName")
      final engName = (data['englishName'] as String? ?? '').trim();
      final engParts = engName
          .split('#')
          .where((s) => s.trim().isNotEmpty)
          .toList();
      String? parsedPrefixEn;
      String firstNameEn = '';
      String lastNameEn = '';
      if (engParts.isNotEmpty) {
        for (final prefix in _prefixesEn) {
          if (engParts[0].trim().toLowerCase() == prefix.toLowerCase()) {
            parsedPrefixEn = prefix;
            break;
          }
        }
        if (engParts.length >= 3) {
          firstNameEn = engParts[1].trim();
          lastNameEn = engParts.last.trim();
        } else if (engParts.length == 2) {
          firstNameEn = engParts[1].trim();
        }
      }

      // Parse CID from hex
      final cidHex = data['cid'] as String? ?? '';
      String cid = '';
      if (cidHex.isNotEmpty) {
        // CID is ASCII digits in hex
        final buffer = StringBuffer();
        for (int i = 0; i < cidHex.length; i += 2) {
          if (i + 1 < cidHex.length) {
            final byte = int.parse(cidHex.substring(i, i + 2), radix: 16);
            if (byte >= 0x30 && byte <= 0x39) {
              buffer.writeCharCode(byte);
            }
          }
        }
        cid = buffer.toString();
      }

      // Parse gender from hex (31 = '1' = male, 32 = '2' = female)
      String? parsedGender;
      final genderHex = data['gender'] as String? ?? '';
      if (genderHex.isNotEmpty) {
        try {
          final genderByte = int.parse(genderHex.substring(0, 2), radix: 16);
          if (genderByte == 0x31) {
            parsedGender = 'ชาย';
          } else if (genderByte == 0x32) {
            parsedGender = 'หญิง';
          }
        } catch (_) {}
      }

      // Parse birthdate from formatted string (DD/MM/YYYY) — year is Buddhist Era, subtract 543
      DateTime? parsedBirthDate;
      final birthStr = data['birthDate'] as String? ?? '';
      if (birthStr.contains('/')) {
        try {
          final parts = birthStr.split('/');
          if (parts.length == 3) {
            int year = int.parse(parts[2]);
            if (year > 2400) year -= 543; // Convert BE to CE
            parsedBirthDate = DateTime(
              year,
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } catch (_) {}
      }

      // Parse address — format: "37/18#หมู่ที่ 4####ตำบลวัดแค#อำเภอนครชัยศรี#จังหวัดนครปฐม"
      final rawAddress = (data['address'] as String? ?? '').trim();
      final addrParts = rawAddress.split('#');
      String addressLine = '';
      String subdistrict = '';
      String district = '';
      String province = '';
      final addressPieces = <String>[];
      for (final part in addrParts) {
        final p = part.trim();
        if (p.isEmpty) continue;
        if (p.startsWith('ตำบล') || p.startsWith('แขวง')) {
          subdistrict = p.replaceFirst(RegExp(r'^(ตำบล|แขวง)'), '').trim();
          if (subdistrict.isEmpty) subdistrict = p;
        } else if (p.startsWith('อำเภอ') || p.startsWith('เขต')) {
          district = p.replaceFirst(RegExp(r'^(อำเภอ|เขต)'), '').trim();
          if (district.isEmpty) district = p;
        } else if (p.startsWith('จังหวัด')) {
          province = p.replaceFirst('จังหวัด', '').trim();
          if (province.isEmpty) province = p;
        } else {
          addressPieces.add(p);
        }
      }
      addressLine = addressPieces.join(' ');

      // Photo
      final photoData = data['photo'];
      Uint8List? parsedPhoto;
      if (photoData is Uint8List && photoData.isNotEmpty) {
        parsedPhoto = photoData;
      }

      setState(() {
        if (parsedPrefixTh != null) _prefixTh = parsedPrefixTh;
        _firstNameThController.text = firstNameTh;
        _lastNameThController.text = lastNameTh;

        if (parsedPrefixEn != null) _prefixEn = parsedPrefixEn;
        _firstNameEnController.text = firstNameEn;
        _lastNameEnController.text = lastNameEn;

        _nationalIdController.text = cid;
        if (parsedBirthDate != null) _birthDate = parsedBirthDate;
        if (parsedGender != null) _gender = parsedGender;

        _addressController.text = addressLine;
        _subdistrictController.text = subdistrict;
        _districtController.text = district;
        _provinceController.text = province;

        if (parsedPhoto != null) _photoBytes = parsedPhoto;

        _isScanning = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('อ่านข้อมูลจากบัตรประชาชนสำเร็จ'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isScanning = false);

      final errStr = e.toString();
      debugPrint('Card read error: $errStr');
      String errorMsg;
      if (errStr.contains('No Permission') || errStr.contains('PERMISSION')) {
        errorMsg = 'ไม่ได้รับสิทธิ์เข้าถึงเครื่องอ่านบัตร ลองถอดแล้วเสียบใหม่';
      } else if (errStr.contains('NO_READER')) {
        errorMsg = 'ไม่พบเครื่องอ่านบัตร';
      } else if (errStr.contains('Reader not initialized')) {
        errorMsg = 'เครื่องอ่านบัตรไม่พร้อม ลองถอดเครื่องอ่านแล้วเสียบใหม่';
      } else {
        errorMsg = 'ไม่สามารถอ่านบัตรได้: $errStr';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      // Resume polling after read completes
      _statusTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _pollCardStatus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.assignment, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              'ลงทะเบียนคนไข้',
              style: AppTheme.generalText(
                20,
                fonWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(),
                        const SizedBox(height: 20),

                        // Upload photo
                        _buildPhotoUpload(),
                        const SizedBox(height: 24),

                        // Thai name row
                        _buildLabel('ชื่อ-นามสกุล (ภาษาไทย)'),
                        const SizedBox(height: 8),
                        _buildNameRow(
                          prefixValue: _prefixTh,
                          prefixes: _prefixesTh,
                          onPrefixChanged: (v) => setState(() => _prefixTh = v),
                          firstNameController: _firstNameThController,
                          middleNameController: _middleNameThController,
                          lastNameController: _lastNameThController,
                          firstHint: 'ชื่อ',
                          middleHint: 'ชื่อกลาง',
                          lastHint: 'นามสกุล',
                        ),
                        const SizedBox(height: 16),

                        // English name row
                        _buildLabel('ชื่อ-นามสกุล (English)'),
                        const SizedBox(height: 8),
                        _buildNameRow(
                          prefixValue: _prefixEn,
                          prefixes: _prefixesEn,
                          onPrefixChanged: (v) => setState(() => _prefixEn = v),
                          firstNameController: _firstNameEnController,
                          middleNameController: _middleNameEnController,
                          lastNameController: _lastNameEnController,
                          firstHint: 'Name',
                          middleHint: 'Midname',
                          lastHint: 'Lastname',
                        ),
                        const SizedBox(height: 20),

                        // National ID + Passport
                        _buildTwoColumns(
                          left: _buildTextField(
                            label: 'เลขประจำตัวประชาชน',
                            controller: _nationalIdController,
                            hint: 'เลขประชาชน 13 หลัก',
                            keyboardType: TextInputType.number,
                          ),
                          right: _buildTextField(
                            label: 'Passport',
                            controller: _passportController,
                            hint: 'Passport Number',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Birth date + Blood type + Gender
                        _buildThreeColumns(
                          first: _buildDateField(
                            label: 'วันเกิด',
                            value: _birthDate,
                            hint: 'เช่น 1900-01-01',
                            onPicked: (d) => setState(() => _birthDate = d),
                          ),
                          second: _buildDropdownField(
                            label: 'หมู่เลือด',
                            value: _bloodType,
                            items: _bloodTypes,
                            onChanged: (v) => setState(() => _bloodType = v),
                          ),
                          third: _buildDropdownField(
                            label: 'เพศ',
                            value: _gender,
                            items: _genders,
                            onChanged: (v) => setState(() => _gender = v),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Phone + Contact person
                        _buildTwoColumns(
                          left: _buildTextField(
                            label: 'เบอร์ติดต่อ',
                            controller: _phoneController,
                            hint: 'เบอร์ติดต่อ 10 หลัก',
                            keyboardType: TextInputType.phone,
                          ),
                          right: _buildTextField(
                            label: 'ผู้ติดต่อ',
                            controller: _contactPersonController,
                            hint: 'ถ้าเป็นเบอร์คนอื่น',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email + Office phone
                        _buildTwoColumns(
                          left: _buildTextField(
                            label: 'อีเมลล์(Email)',
                            controller: _emailController,
                            hint: 'กรอกอีเมลล์',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          right: _buildTextField(
                            label: 'เบอร์สำนักงาน (ถ้ามี)',
                            controller: _officePhoneController,
                            hint: 'กรอกตัวเลข',
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Address
                        _buildTextField(
                          label: 'ที่อยู่',
                          controller: _addressController,
                          hint: 'ที่อยู่ปัจจุบันของคุณ',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // Subdistrict + District
                        _buildTwoColumns(
                          left: _buildTextField(
                            label: 'ตำบล/แขวง',
                            controller: _subdistrictController,
                            hint: 'กรอกตำบล/แขวง',
                          ),
                          right: _buildTextField(
                            label: 'อำเภอ/เขต',
                            controller: _districtController,
                            hint: 'กรอกอำเภอ/เขต',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Province + Postal code
                        _buildTwoColumns(
                          left: _buildTextField(
                            label: 'จังหวัด',
                            controller: _provinceController,
                            hint: 'กรอกจังหวัด',
                          ),
                          right: _buildTextField(
                            label: 'รหัสไปรษณีย์',
                            controller: _postalCodeController,
                            hint: 'กรอกรหัสไปรษณีย์',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Emergency contact
                        _buildThreeColumns(
                          first: _buildTextField(
                            label: 'เบอร์ผู้ติดต่อฉุกเฉิน',
                            controller: _emergencyPhoneController,
                            hint: '',
                            keyboardType: TextInputType.phone,
                          ),
                          second: _buildTextField(
                            label: 'ชื่อผู้ติดต่อ',
                            controller: _emergencyNameController,
                            hint: '',
                          ),
                          third: _buildDropdownField(
                            label: 'ความสัมพันธ์',
                            value: _emergencyRelation,
                            items: _relations,
                            onChanged: (v) =>
                                setState(() => _emergencyRelation = v),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom buttons
              _buildBottomButtons(),
            ],
          ),

          // Scanning overlay
          if (_isScanning)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.primaryThemeApp,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'กำลังอ่านข้อมูลจากเครื่องอ่านบัตร...',
                        style: AppTheme.generalText(
                          15,
                          fonWeight: FontWeight.w500,
                          color: AppTheme.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Section header
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader() {
    final statusColor = _readerConnected
        ? (_cardInserted ? Colors.green : Colors.orange)
        : AppTheme.secondaryText62;
    final statusText = _readerConnected
        ? (_cardInserted ? 'พร้อมอ่านบัตร' : 'รอเสียบบัตร...')
        : 'ไม่พบเครื่องอ่านบัตร';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ข้อมูลส่วนตัว',
              style: AppTheme.generalText(
                18,
                fonWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
            OutlinedButton.icon(
              onPressed: _isScanning
                  ? null
                  : (_cardInserted ? _readFromCardReader : null),
              icon: Icon(Icons.credit_card, size: 18),
              label: Text(
                'ดึงข้อมูลจากบัตรประชาชน',
                style: AppTheme.generalText(
                  13,
                  fonWeight: FontWeight.w500,
                  color: _cardInserted
                      ? AppTheme.primaryThemeApp
                      : AppTheme.secondaryText62,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _cardInserted
                    ? AppTheme.primaryThemeApp
                    : AppTheme.secondaryText62,
                side: BorderSide(
                  color: _cardInserted
                      ? AppTheme.primaryThemeApp
                      : AppTheme.lineColorD9,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.circle, size: 8, color: statusColor),
            const SizedBox(width: 6),
            Text(
              statusText,
              style: AppTheme.generalText(12, color: statusColor),
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Photo upload
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildPhotoUpload() {
    return Center(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.lineColorD9, width: 2),
            color: AppTheme.bgColor,
          ),
          child: _photoBytes != null
              ? ClipOval(
                  child: Image.memory(
                    _photoBytes!,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image,
                        size: 32, color: AppTheme.secondaryText62),
                    const SizedBox(height: 4),
                    Text(
                      'อัพโหลดภาพ',
                      style: AppTheme.generalText(
                        13,
                        color: AppTheme.secondaryText62,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Name row (prefix dropdown + 3 text fields)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildNameRow({
    required String? prefixValue,
    required List<String> prefixes,
    required ValueChanged<String?> onPrefixChanged,
    required TextEditingController firstNameController,
    required TextEditingController middleNameController,
    required TextEditingController lastNameController,
    required String firstHint,
    required String middleHint,
    required String lastHint,
  }) {
    return Row(
      children: [
        // Prefix dropdown
        SizedBox(
          width: 100,
          child: _buildSmallDropdown(
            value: prefixValue,
            items: prefixes,
            onChanged: onPrefixChanged,
            hint: 'เลือก',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSmallTextField(
            controller: firstNameController,
            hint: firstHint,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSmallTextField(
            controller: middleNameController,
            hint: middleHint,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSmallTextField(
            controller: lastNameController,
            hint: lastHint,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Layout helpers
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTwoColumns({required Widget left, required Widget right}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildThreeColumns({
    required Widget first,
    required Widget second,
    required Widget third,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
        const SizedBox(width: 12),
        Expanded(child: third),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Form field builders
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTheme.generalText(
        14,
        fonWeight: FontWeight.w600,
        color: AppTheme.primaryText,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTheme.generalText(14, color: AppTheme.primaryText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.generalText(
              14,
              color: AppTheme.secondaryText62,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.lineColorD9),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.lineColorD9),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primaryThemeApp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: AppTheme.generalText(14, color: AppTheme.primaryText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTheme.generalText(14, color: AppTheme.secondaryText62),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.lineColorD9),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.lineColorD9),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.primaryThemeApp),
        ),
      ),
    );
  }

  Widget _buildSmallDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lineColorD9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: AppTheme.generalText(14, color: AppTheme.secondaryText62),
          ),
          style: AppTheme.generalText(14, color: AppTheme.primaryText),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        _buildSmallDropdown(
          value: value,
          items: items,
          onChanged: onChanged,
          hint: 'เลือก',
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required String hint,
    required ValueChanged<DateTime> onPicked,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime(2000, 1, 1),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onPicked(picked);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lineColorD9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'
                        : hint,
                    style: AppTheme.generalText(
                      14,
                      color: value != null
                          ? AppTheme.primaryText
                          : AppTheme.secondaryText62,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppTheme.secondaryText62,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Bottom buttons
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.lineColorD9)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryThemeApp,
                side: BorderSide(color: AppTheme.primaryThemeApp),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'ย้อนกลับ',
                style: AppTheme.generalText(
                  15,
                  fonWeight: FontWeight.w600,
                  color: AppTheme.primaryThemeApp,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryThemeApp,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'บันทึก',
                style: AppTheme.generalText(
                  15,
                  fonWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
