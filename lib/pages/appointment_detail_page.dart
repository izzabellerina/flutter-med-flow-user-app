import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app/theme.dart';
import '../models/appointment_model.dart';
import '../models/response_model.dart';
import '../services/telemed_service.dart';
import '../widgets/diagnosis_tab.dart';
import '../widgets/measurement_tab.dart';
import '../widgets/patient_detail_bottom_sheet.dart';
import '../widgets/screening_tab.dart';
import '../widgets/treatment_order_tab.dart';

class AppointmentDetailPage extends StatefulWidget {
  final AppointmentModel appointment;

  const AppointmentDetailPage({super.key, required this.appointment});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AppointmentModel _appointment;
  bool _isLoadingDetail = false;

  // Telemed state
  bool _isTelemedActive = false;
  bool _isTelemedFullScreen = false;

  final List<String> _tabLabels = const [
    'ข้อมูลนัด',
    'คัดกรอง',
    'การวัด',
    'วินิจฉัย',
    'สั่งการรักษา',
  ];

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    if (_appointment.id.isEmpty) return;

    setState(() => _isLoadingDetail = true);

    try {
      final result = await TelemedService.findOneAppointment(
        context,
        id: _appointment.id,
      );

      if (!mounted) return;

      if (result.responseEnum == ResponseEnum.success) {
        setState(() {
          _appointment = result.data;
          _isLoadingDetail = false;
        });
        log('findOneAppointment success: ${_appointment.id}');
      } else {
        setState(() => _isLoadingDetail = false);
        log('findOneAppointment failed');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingDetail = false);
      log('findOneAppointment error: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _startTelemed() async {
    if (_appointment.sessionToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบ session token สำหรับ Telemed')),
      );
      return;
    }

    // ถ้าเปิดอยู่แล้ว toggle full screen
    if (_isTelemedActive) {
      setState(() => _isTelemedFullScreen = !_isTelemedFullScreen);
      return;
    }

    // ขอ permission
    final statuses = await [Permission.camera, Permission.microphone].request();

    final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    final micGranted = statuses[Permission.microphone]?.isGranted ?? false;

    if (!mounted) return;

    if (!cameraGranted || !micGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาอนุญาตการใช้กล้องและไมโครโฟน')),
      );
      return;
    }

    setState(() {
      _isTelemedActive = true;
      _isTelemedFullScreen = true;
    });
  }

  void _endCall() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('วางสาย'),
        content: const Text('ต้องการวางสายวิดีโอคอลหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isTelemedActive = false;
                _isTelemedFullScreen = false;
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('วางสาย'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: _isTelemedFullScreen
          ? null
          : AppBar(
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
              actions: [
                if (_isLoadingDetail)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
      body: SafeArea(
        child: _isTelemedFullScreen
            ? _buildFullScreenTelemed()
            : _buildNormalLayout(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Full-screen Telemed
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildFullScreenTelemed() {
    return Column(
      children: [
        // Top bar
        Container(
          color: AppTheme.primaryThemeApp,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.picture_in_picture_alt,
                  color: Colors.white,
                ),
                tooltip: 'ย่อหน้าต่าง',
                onPressed: () => setState(() => _isTelemedFullScreen = false),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _patientFullName(),
                  style: AppTheme.generalText(
                    16,
                    fonWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.call_end, color: Colors.red),
                tooltip: 'วางสาย',
                onPressed: _endCall,
              ),
            ],
          ),
        ),
        // WebView
        Expanded(child: _buildWebView()),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Normal Layout (with inline mini telemed)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildNormalLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final showMiniTelemed = _isTelemedActive && !_isTelemedFullScreen;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ฝั่งซ้าย: patient card + video call (แนวนอน)
              SizedBox(
                width: 380,
                child: Column(
                  children: [
                    _buildPatientCard(),
                    if (showMiniTelemed)
                      Expanded(child: _buildMiniTelemed(expandToFill: true)),
                  ],
                ),
              ),
              VerticalDivider(width: 1, color: AppTheme.lineColorD9),
              // ฝั่งขวา: tabs
              Expanded(child: _buildTabSection(showMiniInline: false)),
            ],
          );
        }

        // แนวตั้ง: video อยู่ระหว่าง tab bar กับ content
        return Column(
          children: [
            _buildPatientCard(),
            Expanded(child: _buildTabSection(showMiniInline: showMiniTelemed)),
          ],
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WebView (ใช้ร่วมกันทั้ง full screen และ mini)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildWebView() {
    final url =
        'https://med3.medflow.in.th/teleconsult/join/${_appointment.sessionToken}';

    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        javaScriptEnabled: true,
        domStorageEnabled: true,
        useWideViewPort: true,
        supportMultipleWindows: false,
        useShouldOverrideUrlLoading: false,
      ),
      onPermissionRequest: (controller, request) async {
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Mini Telemed strip (ระหว่าง tab bar กับ tab content)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildMiniTelemed({bool expandToFill = false}) {
    return Container(
      height: expandToFill ? null : MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Mini top bar
          Container(
            color: AppTheme.primaryThemeApp,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.videocam, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Telemed - ${_patientFullName()}',
                    style: AppTheme.generalText(
                      12,
                      fonWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isTelemedFullScreen = true),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _endCall,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.call_end, color: Colors.red, size: 18),
                  ),
                ),
              ],
            ),
          ),
          // WebView (mini)
          Expanded(child: _buildWebView()),
        ],
      ),
    );
  }

  String _patientFullName() {
    final patient = _appointment.patient;
    return '${patient.prefix}${patient.firstName} ${patient.lastName}';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Patient Card
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildPatientCard() {
    final appt = _appointment;
    final patient = appt.patient;
    final patientName = _patientFullName();
    final patientNameEn = patient.firstNameEn.isNotEmpty
        ? '${patient.firstNameEn} ${patient.lastNameEn}'
        : null;
    final photoUrl = patient.photoUrl;

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
                  backgroundImage: photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.secondaryText62,
                        )
                      : null,
                ),
                const SizedBox(width: 14),

                // Patient name + info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: AppTheme.generalText(
                          17,
                          fonWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      if (patientNameEn != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          patientNameEn,
                          style: AppTheme.generalText(
                            14,
                            color: AppTheme.secondaryText62,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        'วันเดือนปีเกิด : ${patient.birthDate != null ? _formatBirthDate(patient.birthDate!) : '-'}',
                        style: AppTheme.generalText(
                          13,
                          color: AppTheme.secondaryText62,
                        ),
                      ),
                      // HN Badge
                      if (patient.hn.isNotEmpty) ...[
                        const SizedBox(height: 6),
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
                            'HN : ${patient.hn}',
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _ActionIconButton(
                      icon: Icons.info_outline,
                      label: 'รายละเอียด',
                      onTap: () {
                        PatientDetailBottomSheet.show(
                          context,
                          patientHn: patient.hn.isNotEmpty ? patient.hn : null,
                          patientName: patientName,
                          patientNameEn: patientNameEn,
                          avatarUrl: photoUrl.isNotEmpty ? photoUrl : null,
                        );
                      },
                    ),
                    _ActionIconButton(
                      icon: Icons.phone,
                      label: 'Telemed',
                      onTap: _startTelemed,
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
  // Tab Section (tab bar + mini telemed + tab content)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTabSection({bool showMiniInline = false}) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // Tab bar
          SliverToBoxAdapter(
            child: Container(
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
          ),
          SliverToBoxAdapter(
            child: Divider(height: 1, color: AppTheme.lineColorD9),
          ),

          // Mini telemed (scroll ไปพร้อมเนื้อหา ทุกแท็ป)
          if (showMiniInline)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildMiniTelemed(),
              ),
            ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentInfoTab(),
          const ScreeningTab(),
          MeasurementTab(sessionToken: _appointment.sessionToken),
          const DiagnosisTab(),
          TreatmentOrderTab(
            patientHn: _appointment.patient.hn.isNotEmpty
                ? _appointment.patient.hn
                : null,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1 : ข้อมูลนัด
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildAppointmentInfoTab() {
    final appt = _appointment;
    final doctor = appt.doctor;
    final scheduledDate = appt.scheduledAt != null
        ? _formatDate(appt.scheduledAt!)
        : '-';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รายละเอียดการนัด section
          _buildSectionHeader('รายละเอียดการนัด'),
          const SizedBox(height: 12),

          _buildInfoCard([
            _InfoRow(label: 'วันที่นัด', child: _buildDateBadge(scheduledDate)),
            _InfoRow(
              label: 'สถานะ',
              child: Text(
                _statusLabel(appt.status),
                style: AppTheme.generalText(
                  14,
                  fonWeight: FontWeight.w600,
                  color: _statusColor(appt.status),
                ),
              ),
            ),
            if (appt.roomName.isNotEmpty)
              _InfoRow(
                label: 'ห้อง',
                child: Text(
                  appt.roomName,
                  style: AppTheme.generalText(14, color: AppTheme.primaryText),
                ),
              ),
          ]),

          const SizedBox(height: 20),

          // แพทย์ section
          if (doctor.fullName.isNotEmpty) ...[
            _buildSectionHeader('แพทย์'),
            const SizedBox(height: 12),
            _buildDoctorCardFromModel(doctor),
          ],

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
              appt.notes.isNotEmpty ? appt.notes : '-',
              style: AppTheme.generalText(14, color: AppTheme.secondaryText62),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
          Icon(Icons.calendar_today, size: 14, color: AppTheme.primaryThemeApp),
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

  Widget _buildDoctorCardFromModel(dynamic doctor) {
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
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryThemeApp.withValues(alpha: 0.1),
            child: Icon(
              Icons.person,
              size: 26,
              color: AppTheme.primaryThemeApp,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.fullName,
                  style: AppTheme.generalText(
                    15,
                    fonWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                if (_appointment.chiefComplaint.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'อาการ : ${_appointment.chiefComplaint}',
                    style: AppTheme.generalText(
                      13,
                      color: AppTheme.secondaryText62,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'นัดหมาย';
      case 'waiting':
        return 'รอตรวจ';
      case 'in_progress':
        return 'กำลังตรวจ';
      case 'completed':
        return 'เสร็จสิ้น';
      case 'cancelled':
        return 'ยกเลิก';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppTheme.primaryThemeApp;
      case 'waiting':
        return Colors.orange;
      case 'in_progress':
        return AppTheme.statusGreen;
      case 'completed':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.secondaryText62;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  String _formatBirthDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year + 543}';
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Helper Widgets
// ══════════════════════════════════════════════════════════════════════════

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.primaryThemeApp;

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: AppTheme.generalText(
          13,
          fonWeight: FontWeight.w500,
          color: color,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final Widget child;

  _InfoRow({required this.label, required this.child});
}
