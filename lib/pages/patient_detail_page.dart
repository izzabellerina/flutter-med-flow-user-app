import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../data/mock_data.dart';
import '../models/patient.dart';
import '../models/patient_registration.dart';

class PatientDetailPage extends StatefulWidget {
  final Patient patient;

  const PatientDetailPage({super.key, required this.patient});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PatientRegistration? _data;

  final _tabLabels = const ['สำคัญ', 'ส่วนตัว', 'สุขภาพ', 'แพ้ยา'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _data = MockData.patientRegistrations[widget.patient.hn];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(
          'รายละเอียดคนไข้',
          style: AppTheme.generalText(
            20,
            fonWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 380,
                    child: SingleChildScrollView(child: _buildPatientCard()),
                  ),
                  VerticalDivider(width: 1, color: AppTheme.lineColorD9),
                  Expanded(child: _buildTabSection()),
                ],
              );
            }

            return Column(
              children: [
                _buildPatientCard(),
                Expanded(child: _buildTabSection()),
              ],
            );
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Patient Card (header)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildPatientCard() {
    final p = widget.patient;
    final isMale = p.gender == 'male';
    final initials = _getInitials(p.firstName, p.lastName);

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 36,
                  backgroundColor: isMale
                      ? AppTheme.primaryThemeApp.withValues(alpha: 0.1)
                      : AppTheme.femaleColor.withValues(alpha: 0.1),
                  backgroundImage: p.avatarUrl != null
                      ? NetworkImage(p.avatarUrl!)
                      : null,
                  child: p.avatarUrl == null
                      ? Text(
                          initials,
                          style: AppTheme.generalText(
                            20,
                            fonWeight: FontWeight.bold,
                            color: isMale
                                ? AppTheme.primaryThemeApp
                                : AppTheme.femaleColor,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.fullName,
                        style: AppTheme.generalText(
                          17,
                          fonWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      if (_data?.fullNameEn != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _data!.fullNameEn!,
                          style: AppTheme.generalText(
                            14,
                            color: AppTheme.secondaryText62,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      // HN Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.hnBadgeBgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.hnBadgeBorderColor,
                          ),
                        ),
                        child: Text(
                          'HN : ${p.hn}',
                          style: AppTheme.generalText(
                            13,
                            fonWeight: FontWeight.w600,
                            color: AppTheme.hnBadgeBorderColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Phone
                      Row(
                        children: [
                          Icon(Icons.phone,
                              size: 16, color: AppTheme.primaryThemeApp),
                          const SizedBox(width: 6),
                          Text(
                            p.phone,
                            style: AppTheme.generalText(
                              13,
                              color: AppTheme.primaryThemeApp,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'อายุ : ${p.age} ปี',
                        style: AppTheme.generalText(
                          13,
                          color: AppTheme.secondaryText62,
                        ),
                      ),
                    ],
                  ),
                ),

                // Gender icon
                Icon(
                  isMale ? Icons.male : Icons.female,
                  size: 28,
                  color: isMale ? AppTheme.maleColor : AppTheme.femaleColor,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.lineColorD9),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Tab Section
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTabSection() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppTheme.primaryThemeApp,
            unselectedLabelColor: AppTheme.secondaryText62,
            labelStyle: AppTheme.generalText(15, fonWeight: FontWeight.w600),
            unselectedLabelStyle: AppTheme.generalText(14),
            indicatorColor: AppTheme.primaryThemeApp,
            indicatorWeight: 3,
            tabAlignment: TabAlignment.start,
            tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
          ),
        ),
        Divider(height: 1, color: AppTheme.lineColorD9),
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
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Tab 1: สำคัญ
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildImportantTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('ข้อมูลสำคัญตามบัตรประชาชน'),
          const SizedBox(height: 12),
          _buildInfoCard([
            _InfoRow('HN', _data?.hn ?? widget.patient.hn),
            _InfoRow('เลขประจำตัวประชาชน', _data?.nationalId ?? '-'),
            _InfoRow('เลขพาสปอร์ต', _data?.passportNo ?? '-'),
            _InfoRow('เพศ', _data?.gender ?? '-'),
            _InfoRow('กรุ๊ปเลือด', _data?.bloodType ?? '-'),
            _InfoRow('วันเกิด', _data?.birthDate ?? '-'),
            _InfoRow('อายุ',
                _data?.age != null ? '${_data!.age} ปี' : '${widget.patient.age} ปี'),
            _InfoRow('ศาสนา', _data?.religion ?? '-'),
            _InfoRow('สัญชาติ', _data?.nationality ?? '-'),
            _InfoRow('แหล่งที่มาคนไข้', _data?.patientSource ?? '-'),
          ]),

          const SizedBox(height: 20),
          _buildSectionHeader('ช่องทางการติดต่อหลัก'),
          const SizedBox(height: 12),
          _buildInfoCard([
            _InfoRow('โทรศัพท์', _data?.phone ?? widget.patient.phone),
            _InfoRow('โทรสำนักงาน', _data?.officePhone ?? '-'),
            _InfoRow('อีเมล', _data?.email ?? '-'),
          ]),

          const SizedBox(height: 20),
          _buildSectionHeader('ที่อยู่ปัจจุบัน'),
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

  // ══════════════════════════════════════════════════════════════════════════
  // Tab 2: ส่วนตัว
  // ══════════════════════════════════════════════════════════════════════════

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

  // ══════════════════════════════════════════════════════════════════════════
  // Tab 3: สุขภาพ
  // ══════════════════════════════════════════════════════════════════════════

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
            _buildHealthCard(
                'ไม่มีโรคประจำตัว', Icons.check_circle_outline, AppTheme.statusGreen)
          else
            ...diseases.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildHealthCard(
                      d, Icons.medical_services_outlined, AppTheme.primaryThemeApp),
                )),

          const SizedBox(height: 16),
          _buildSectionHeader('ประวัติการผ่าตัด'),
          const SizedBox(height: 12),
          if (surgeries.isEmpty)
            _buildHealthCard('ไม่มีประวัติการผ่าตัด',
                Icons.check_circle_outline, AppTheme.statusGreen)
          else
            ...surgeries.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildHealthCard(s, Icons.content_cut, Colors.orange),
                )),

          const SizedBox(height: 16),
          _buildSectionHeader('ประวัติครอบครัว'),
          const SizedBox(height: 12),
          if (familyHistories.isEmpty)
            _buildHealthCard('ไม่มีประวัติครอบครัว',
                Icons.check_circle_outline, AppTheme.statusGreen)
          else
            ...familyHistories.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildHealthCard(
                      f, Icons.family_restroom, AppTheme.secondaryText62),
                )),

          const SizedBox(height: 16),
          _buildSectionHeader('แพ้อื่นๆ'),
          const SizedBox(height: 12),
          if (otherAllergies.isEmpty)
            _buildHealthCard('ไม่มีประวัติแพ้อื่นๆ',
                Icons.check_circle_outline, AppTheme.statusGreen)
          else
            ...otherAllergies.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildHealthCard(
                      a, Icons.warning_amber_rounded, Colors.orange),
                )),

          const SizedBox(height: 16),
          _buildSectionHeader('แพ้อาหาร'),
          const SizedBox(height: 12),
          if (foodAllergies.isEmpty)
            _buildHealthCard('ไม่มีประวัติแพ้อาหาร',
                Icons.check_circle_outline, AppTheme.statusGreen)
          else
            ...foodAllergies.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child:
                      _buildHealthCard(f, Icons.restaurant, AppTheme.errorColor),
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

  // ══════════════════════════════════════════════════════════════════════════
  // Tab 4: แพ้ยา
  // ══════════════════════════════════════════════════════════════════════════

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
              style:
                  AppTheme.generalText(16, color: AppTheme.secondaryText62),
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

  // ══════════════════════════════════════════════════════════════════════════
  // Shared widgets
  // ══════════════════════════════════════════════════════════════════════════

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
                    style: AppTheme.generalText(14,
                        color: AppTheme.secondaryText62),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _splitToList(String? value) {
    if (value == null || value == '-' || value.trim().isEmpty) return [];
    return value
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  String _getInitials(String firstName, String lastName) {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }
}

class _InfoRow {
  final String label;
  final String value;

  _InfoRow(this.label, this.value);
}
