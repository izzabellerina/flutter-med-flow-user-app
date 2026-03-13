import 'package:flutter/material.dart';
import '../app/theme.dart';

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
  void dispose() {
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
      body: Column(
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
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Section header
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'ข้อมูลส่วนตัว',
          style: AppTheme.generalText(18,
              fonWeight: FontWeight.bold, color: AppTheme.primaryText),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.photo_camera, size: 18),
          label: Text(
            'ดึงข้อมูลจากบัตรประชา...',
            style: AppTheme.generalText(13,
                fonWeight: FontWeight.w500,
                color: AppTheme.primaryThemeApp),
            overflow: TextOverflow.ellipsis,
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryThemeApp,
            side: BorderSide(color: AppTheme.primaryThemeApp),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 32, color: AppTheme.secondaryText62),
              const SizedBox(height: 4),
              Text(
                'อัพโหลดภาพ',
                style: AppTheme.generalText(13,
                    color: AppTheme.secondaryText62),
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
      style: AppTheme.generalText(14,
          fonWeight: FontWeight.w600, color: AppTheme.primaryText),
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
            hintStyle:
                AppTheme.generalText(14, color: AppTheme.secondaryText62),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        hintStyle:
            AppTheme.generalText(14, color: AppTheme.secondaryText62),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                Icon(Icons.calendar_today,
                    size: 18, color: AppTheme.secondaryText62),
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
