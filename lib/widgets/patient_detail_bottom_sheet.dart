import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../data/mock_data.dart';
import '../models/patient_registration.dart';

class PatientDetailBottomSheet extends StatefulWidget {
  final String? patientHn;
  final String patientName;
  final String? patientNameEn;
  final String? avatarUrl;

  const PatientDetailBottomSheet({
    super.key,
    this.patientHn,
    required this.patientName,
    this.patientNameEn,
    this.avatarUrl,
  });

  static Future<void> show(
    BuildContext context, {
    String? patientHn,
    required String patientName,
    String? patientNameEn,
    String? avatarUrl,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PatientDetailBottomSheet(
        patientHn: patientHn,
        patientName: patientName,
        patientNameEn: patientNameEn,
        avatarUrl: avatarUrl,
      ),
    );
  }

  @override
  State<PatientDetailBottomSheet> createState() =>
      _PatientDetailBottomSheetState();
}

class _PatientDetailBottomSheetState extends State<PatientDetailBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PatientRegistration? _data;

  final _tabLabels = const ['สำคัญ', 'ส่วนตัว', 'สุขภาพ', 'แพ้ยา'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    if (widget.patientHn != null) {
      _data = MockData.patientRegistrations[widget.patientHn];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.lineColorD9,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                Text(
                  'ข้อมูลลงทะเบียน',
                  style: AppTheme.generalText(18,
                      fonWeight: FontWeight.bold, color: AppTheme.primaryText),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text('ปิด',
                      style: AppTheme.generalText(15,
                          fonWeight: FontWeight.w600,
                          color: AppTheme.errorColor)),
                ),
              ],
            ),
          ),

          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryThemeApp,
            unselectedLabelColor: AppTheme.secondaryText62,
            labelStyle: AppTheme.generalText(15, fonWeight: FontWeight.w600),
            unselectedLabelStyle: AppTheme.generalText(14),
            indicatorColor: AppTheme.primaryThemeApp,
            indicatorWeight: 3,
            tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
          ),
          Divider(height: 1, color: AppTheme.lineColorD9),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildImportantTab(),
                _buildPersonalTab(),
                _buildHealthTab(),
                _buildAllergyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // Tab 1: สำคัญ
  // ════════════════════════════════════════════════════════════════════

  Widget _buildImportantTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('ข้อมูลสำคัญตามบัตรประชาชน'),
          const SizedBox(height: 12),

          // Avatar + Name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.bgColor,
                backgroundImage: widget.avatarUrl != null
                    ? NetworkImage(widget.avatarUrl!)
                    : null,
                child: widget.avatarUrl == null
                    ? Icon(Icons.person,
                        size: 40, color: AppTheme.secondaryText62)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _data?.fullName ?? widget.patientName,
                      style: AppTheme.generalText(16,
                          fonWeight: FontWeight.bold,
                          color: AppTheme.primaryText),
                    ),
                    if ((_data?.fullNameEn ?? widget.patientNameEn) !=
                        null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _data?.fullNameEn ?? widget.patientNameEn!,
                        style: AppTheme.generalText(14,
                            color: AppTheme.secondaryText62),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildInfoCard([
            _InfoRow('HN', _data?.hn ?? widget.patientHn ?? '-'),
            _InfoRow(
                'เลขประจำตัวประชาชน', _data?.nationalId ?? '-'),
            _InfoRow('เลขพาสปอร์ต', _data?.passportNo ?? '-'),
            _InfoRow('เพศ', _data?.gender ?? '-'),
            _InfoRow('กรุ๊ปเลือด', _data?.bloodType ?? '-'),
            _InfoRow('วันเกิด', _data?.birthDate ?? '-'),
            _InfoRow(
                'อายุ',
                _data?.age != null
                    ? '${_data!.age} ปี'
                    : '-'),
            _InfoRow('ศาสนา', _data?.religion ?? '-'),
            _InfoRow('สัญชาติ', _data?.nationality ?? '-'),
            _InfoRow('แหล่งที่มาคนไข้', _data?.patientSource ?? '-'),
          ]),

          const SizedBox(height: 20),
          _buildSectionHeader('ช่องทางการติดต่อหลัก'),
          const SizedBox(height: 12),

          _buildInfoCard([
            _InfoRow('โทรศัพท์', _data?.phone ?? '-'),
            _InfoRow('โทรสำนักงาน', _data?.officePhone ?? '-'),
            _InfoRow('อีเมล', _data?.email ?? '-'),
          ]),

          const SizedBox(height: 20),
          _buildSectionHeader('ช่องทางการติดต่อที่อยู่ปัจจุบัน'),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.lineColorD9),
            ),
            child: Text(
              _data?.currentAddress ?? '-',
              style: AppTheme.generalText(14, color: AppTheme.primaryText),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // Tab 2: ส่วนตัว
  // ════════════════════════════════════════════════════════════════════

  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('ข้อมูลส่วนตัว'),
          const SizedBox(height: 12),
          _buildInfoCard([
            _InfoRow('สถานภาพ', _data?.maritalStatus ?? '-'),
            _InfoRow('อาชีพ', _data?.occupation ?? '-'),
            _InfoRow('สถานที่ทำงาน', _data?.workplace ?? '-'),
          ]),
          const SizedBox(height: 20),
          _buildSectionHeader('ผู้ติดต่อฉุกเฉิน'),
          const SizedBox(height: 12),
          _buildInfoCard([
            _InfoRow('ชื่อ', _data?.emergencyContact ?? '-'),
            _InfoRow('โทรศัพท์', _data?.emergencyPhone ?? '-'),
            _InfoRow('ความสัมพันธ์', _data?.emergencyRelation ?? '-'),
          ]),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // Tab 3: สุขภาพ
  // ════════════════════════════════════════════════════════════════════

  Widget _buildHealthTab() {
    final diseases = _splitToList(_data?.underlyingDisease);
    final surgeries = _splitToList(_data?.surgeryHistory);
    final familyHistories = _splitToList(_data?.familyHistory);
    final otherAllergies = _splitToList(_data?.otherAllergy);
    final foodAllergies = _splitToList(_data?.foodAllergy);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('โรคประจำตัว'),
          const SizedBox(height: 12),
          if (diseases.isEmpty)
            _buildHealthCard('ไม่มีโรคประจำตัว', Icons.check_circle_outline, AppTheme.statusGreen)
          else
            ...diseases.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildHealthCard(d, Icons.medical_services_outlined, AppTheme.primaryThemeApp),
            )),

          const SizedBox(height: 16),
          _buildSectionHeader('ประวัติการผ่าตัด'),
          const SizedBox(height: 12),
          if (surgeries.isEmpty)
            _buildHealthCard('ไม่มีประวัติการผ่าตัด', Icons.check_circle_outline, AppTheme.statusGreen)
          else
            ...surgeries.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildHealthCard(s, Icons.content_cut, Colors.orange),
            )),

          const SizedBox(height: 16),
          _buildSectionHeader('ประวัติครอบครัว'),
          const SizedBox(height: 12),
          if (familyHistories.isEmpty)
            _buildHealthCard('ไม่มีประวัติครอบครัว', Icons.check_circle_outline, AppTheme.statusGreen)
          else
            ...familyHistories.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildHealthCard(f, Icons.family_restroom, AppTheme.secondaryText62),
            )),

          const SizedBox(height: 16),
          _buildSectionHeader('แพ้อื่นๆ'),
          const SizedBox(height: 12),
          if (otherAllergies.isEmpty)
            _buildHealthCard('ไม่มีประวัติแพ้อื่นๆ', Icons.check_circle_outline, AppTheme.statusGreen)
          else
            ...otherAllergies.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildHealthCard(a, Icons.warning_amber_rounded, Colors.orange),
            )),

          const SizedBox(height: 16),
          _buildSectionHeader('แพ้อาหาร'),
          const SizedBox(height: 12),
          if (foodAllergies.isEmpty)
            _buildHealthCard('ไม่มีประวัติแพ้อาหาร', Icons.check_circle_outline, AppTheme.statusGreen)
          else
            ...foodAllergies.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildHealthCard(f, Icons.restaurant, AppTheme.errorColor),
            )),

          const SizedBox(height: 20),
          _buildSectionHeader('พฤติกรรม'),
          const SizedBox(height: 12),
          _buildInfoCard([
            _InfoRow('การสูบบุหรี่', _data?.smokingStatus ?? '-'),
            _InfoRow('การดื่มแอลกอฮอล์', _data?.drinkingStatus ?? '-'),
          ]),
        ],
      ),
    );
  }

  List<String> _splitToList(String? value) {
    if (value == null || value == '-' || value.trim().isEmpty) return [];
    return value.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  Widget _buildHealthCard(String text, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lineColorD9),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTheme.generalText(14, color: AppTheme.primaryText),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // Tab 4: แพ้ยา
  // ════════════════════════════════════════════════════════════════════

  Widget _buildAllergyTab() {
    final allergies = _data?.drugAllergies ?? [];

    if (allergies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 48, color: AppTheme.statusGreen),
            const SizedBox(height: 12),
            Text(
              'ไม่พบประวัติการแพ้ยา',
              style: AppTheme.generalText(16, color: AppTheme.secondaryText62),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: allergies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final allergy = allergies[index];
        return _buildAllergyCard(allergy);
      },
    );
  }

  Widget _buildAllergyCard(DrugAllergy allergy) {
    Color severityColor;
    String severityLabel;
    switch (allergy.severity) {
      case 'severe':
        severityColor = AppTheme.errorColor;
        severityLabel = 'รุนแรง';
      case 'moderate':
        severityColor = Colors.orange;
        severityLabel = 'ปานกลาง';
      default:
        severityColor = AppTheme.statusGreen;
        severityLabel = 'เล็กน้อย';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lineColorD9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: severityColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        allergy.drugName,
                        style: AppTheme.generalText(15,
                            fonWeight: FontWeight.bold,
                            color: AppTheme.primaryText),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: severityColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        severityLabel,
                        style: AppTheme.generalText(12,
                            fonWeight: FontWeight.w600, color: severityColor),
                      ),
                    ),
                  ],
                ),
                if (allergy.reaction != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'อาการ: ${allergy.reaction}',
                    style:
                        AppTheme.generalText(14, color: AppTheme.secondaryText62),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // Shared widgets
  // ════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.primaryThemeApp,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTheme.generalText(16,
              fonWeight: FontWeight.bold, color: AppTheme.primaryThemeApp),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<_InfoRow> rows) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lineColorD9),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final isLast = entry.key == rows.length - 1;
          final row = entry.value;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        row.label,
                        style: AppTheme.generalText(14,
                            fonWeight: FontWeight.w600,
                            color: AppTheme.primaryText),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.value,
                        style: AppTheme.generalText(14,
                            color: AppTheme.secondaryText62),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) Divider(height: 1, color: AppTheme.lineColorD9),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;

  _InfoRow(this.label, this.value);
}
