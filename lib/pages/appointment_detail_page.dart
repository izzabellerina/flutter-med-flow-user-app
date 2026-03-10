import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/appointment.dart';
import '../widgets/diagnosis_tab.dart';
import '../widgets/measurement_tab.dart';

class AppointmentDetailPage extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailPage({super.key, required this.appointment});

  @override
  State<AppointmentDetailPage> createState() =>
      _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isTelemedActive = false;

  final List<String> _tabLabels = const [
    'ข้อมูลนัด',
    'การวัด',
    'วินิจฉัย',
    'สั่งการรักษา',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleTelemed() {
    setState(() => _isTelemedActive = !_isTelemedActive);
  }

  void _endCall() {
    setState(() => _isTelemedActive = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(
          'รายละเอียดนัดหมาย',
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
                    child: Column(
                      children: [
                        _buildPatientCard(),
                        if (_isTelemedActive) Expanded(child: _buildTelemedPanel()),
                      ],
                    ),
                  ),
                  VerticalDivider(width: 1, color: AppTheme.lineColorD9),
                  Expanded(child: _buildTabSection()),
                ],
              );
            }

            return Column(
              children: [
                _buildPatientCard(),
                if (_isTelemedActive) _buildTelemedPanel(height: 250),
                Expanded(child: _buildTabSection()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPatientCard() {
    final appt = widget.appointment;

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Patient info header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient avatar
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppTheme.bgColor,
                  backgroundImage: appt.patientAvatarUrl != null
                      ? NetworkImage(appt.patientAvatarUrl!)
                      : null,
                  child: appt.patientAvatarUrl == null
                      ? Icon(Icons.person,
                          size: 40, color: AppTheme.secondaryText62)
                      : null,
                ),
                const SizedBox(width: 14),

                // Patient name + info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appt.patientName,
                        style: AppTheme.generalText(
                          17,
                          fonWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      if (appt.patientNameEn != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          appt.patientNameEn!,
                          style: AppTheme.generalText(
                            14,
                            color: AppTheme.secondaryText62,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      if (appt.birthDate != null)
                        Text(
                          'วันเดือนปีเกิด : ${appt.birthDate}',
                          style: AppTheme.generalText(
                            13,
                            color: AppTheme.secondaryText62,
                          ),
                        ),
                      // HN Badge
                      if (appt.isRegistered && appt.patientHn != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.hnBadgeBgColor,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: AppTheme.hnBadgeBorderColor),
                          ),
                          child: Text(
                            'HN : ${appt.patientHn}',
                            style: AppTheme.generalText(
                              13,
                              fonWeight: FontWeight.w600,
                              color: AppTheme.hnBadgeBorderColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Action buttons
                Column(
                  children: [
                    _ActionIconButton(
                      icon: Icons.info_outline,
                      label: 'รายละเอียด',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _ActionIconButton(
                      icon: Icons.phone,
                      label: 'Telemed',
                      isActive: _isTelemedActive,
                      onTap: _toggleTelemed,
                    ),
                  ],
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
  // Telemed Panel
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTelemedPanel({double? height}) {
    return Container(
      width: double.infinity,
      height: height,
      color: const Color(0xFF1a1a2e),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Patient avatar in call
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 48, color: Colors.white70),
          ),
          const SizedBox(height: 16),

          Text(
            widget.appointment.patientName,
            style: AppTheme.generalText(
              16,
              fonWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            'กำลังรอการเชื่อมต่อ...',
            style: AppTheme.generalText(
              14,
              color: Colors.white60,
            ),
          ),

          const Spacer(),

          // End call button
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: GestureDetector(
              onTap: _endCall,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Column(
      children: [
        // Tab bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppTheme.primaryThemeApp,
            unselectedLabelColor: AppTheme.secondaryText62,
            labelStyle: AppTheme.generalText(
              15,
              fonWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: AppTheme.generalText(14),
            indicatorColor: AppTheme.primaryThemeApp,
            indicatorWeight: 3,
            tabAlignment: TabAlignment.start,
            tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
          ),
        ),
        Divider(height: 1, color: AppTheme.lineColorD9),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAppointmentInfoTab(),
              const MeasurementTab(),
              const DiagnosisTab(),
              _buildPlaceholderTab('สั่งการรักษา'),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1 : ข้อมูลนัด
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildAppointmentInfoTab() {
    final appt = widget.appointment;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รายละเอียดการนัด section
          _buildSectionHeader('รายละเอียดการนัด'),
          const SizedBox(height: 12),

          _buildInfoCard([
            _InfoRow(
              label: 'วันที่นัด',
              child: _buildDateBadge(appt.appointmentDate ?? '-'),
            ),
            _InfoRow(
              label: 'สถานะ',
              child: Text(
                appt.status,
                style: AppTheme.generalText(
                  14,
                  fonWeight: FontWeight.w600,
                  color: _statusColor(appt.status),
                ),
              ),
            ),
            _InfoRow(
              label: 'เวลามา',
              child: Text(
                appt.arrivalTime ?? 'ยังไม่มาโรงพยาบาล',
                style: AppTheme.generalText(
                  14,
                  color: appt.arrivalTime != null
                      ? AppTheme.primaryText
                      : AppTheme.secondaryText62,
                ),
              ),
            ),
          ]),

          const SizedBox(height: 20),

          // แพทย์ section
          _buildSectionHeader('แพทย์'),
          const SizedBox(height: 12),

          ...appt.doctorVisits.map((visit) => _buildDoctorCard(visit)),

          // โน้ต section
          const SizedBox(height: 20),
          _buildSectionHeader('โน้ต'),
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
              appt.note?.isNotEmpty == true ? appt.note! : '-',
              style: AppTheme.generalText(
                14,
                color: AppTheme.secondaryText62,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          style: AppTheme.generalText(
            16,
            fonWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row.label,
                      style: AppTheme.generalText(
                        14,
                        color: AppTheme.secondaryText62,
                      ),
                    ),
                    row.child,
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

  Widget _buildDateBadge(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.dateBadgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today,
              size: 14, color: AppTheme.primaryThemeApp),
          const SizedBox(width: 6),
          Text(
            'วันที่นัด $date',
            style: AppTheme.generalText(
              13,
              fonWeight: FontWeight.w500,
              color: AppTheme.primaryThemeApp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(DoctorVisit visit) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lineColorD9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor avatar
          CircleAvatar(
            radius: 24,
            backgroundColor:
                AppTheme.primaryThemeApp.withValues(alpha: 0.1),
            backgroundImage: visit.doctorAvatarUrl != null
                ? NetworkImage(visit.doctorAvatarUrl!)
                : null,
            child: visit.doctorAvatarUrl == null
                ? Icon(Icons.person,
                    size: 26, color: AppTheme.primaryThemeApp)
                : null,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.doctorName,
                  style: AppTheme.generalText(
                    15,
                    fonWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),

                // Time badge
                if (visit.appointmentTime != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.timeBadgeColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: AppTheme.timeBadgeTextColor),
                        const SizedBox(width: 4),
                        Text(
                          'เวลานัด ${visit.appointmentTime} น.',
                          style: AppTheme.generalText(
                            12,
                            fonWeight: FontWeight.w500,
                            color: AppTheme.timeBadgeTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                Text(
                  'จุดประสงค์ : ${visit.purpose}',
                  style: AppTheme.generalText(
                    13,
                    color: AppTheme.secondaryText62,
                  ),
                ),
                if (visit.forDepartment != null &&
                    visit.forDepartment!.isNotEmpty)
                  Text(
                    'สำหรับ : ${visit.forDepartment}',
                    style: AppTheme.generalText(
                      13,
                      color: AppTheme.secondaryText62,
                    ),
                  ),
                if (visit.department != null)
                  Text(
                    'แผนก : ${visit.department}',
                    style: AppTheme.generalText(
                      13,
                      color: AppTheme.secondaryText62,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Booked':
        return AppTheme.primaryThemeApp;
      case 'Checked-In':
        return AppTheme.statusGreen;
      case 'Completed':
        return AppTheme.successColor;
      case 'Cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.secondaryText62;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Placeholder tabs
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction,
              size: 48,
              color: AppTheme.secondaryText62.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            'หน้า $title',
            style: AppTheme.generalText(
              16,
              fonWeight: FontWeight.w500,
              color: AppTheme.secondaryText62,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'พบกันเร็ว ๆ นี้',
            style: AppTheme.generalText(
              14,
              color: AppTheme.secondaryText9A,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Helper Widgets
// ══════════════════════════════════════════════════════════════════════════

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 18,
              color: isActive ? AppTheme.statusGreen : AppTheme.primaryThemeApp),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.generalText(
              13,
              fonWeight: FontWeight.w500,
              color: isActive ? AppTheme.statusGreen : AppTheme.primaryThemeApp,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final Widget child;

  _InfoRow({required this.label, required this.child});
}
