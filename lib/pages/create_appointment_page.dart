import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../data/mock_data.dart';
import '../models/patient.dart';

class CreateAppointmentPage extends StatefulWidget {
  const CreateAppointmentPage({super.key});

  @override
  State<CreateAppointmentPage> createState() => _CreateAppointmentPageState();
}

class _CreateAppointmentPageState extends State<CreateAppointmentPage>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  Patient? _selectedPatient;
  final _searchController = TextEditingController();
  List<Patient> _filteredPatients = MockData.patients;

  // ── Step 2 state ──
  DateTime _appointmentDate = DateTime.now();
  late TabController _doctorTabController;
  String? _selectedDepartmentId;
  String _selectedPurpose = MockData.appointmentPurposes.first;
  String? _selectedDoctorId;
  String? _selectedShift;
  // Step 2 tab "แพทย์นอกตาราง"
  String? _offScheduleDepartmentId;
  String? _offSchedulePurpose;
  String? _offScheduleDoctorId;
  TimeOfDay? _offScheduleTime;
  final _doctorSearchController = TextEditingController();
  String _doctorSearchQuery = '';

  // ── Step 3 state ──
  final Set<String> _selectedExams = {};
  final _ccController = TextEditingController();
  final _noteController = TextEditingController();

  final _stepLabels = const [
    'เลือกคนไข้',
    'เลือกแพทย์',
    'ข้อมูลทั่วไป',
  ];

  static const _examItems = [
    'BP, Tem', 'VA', 'RK(Tn)', 'RK(ARK)', 'Slit lamp exam', 'Dilate',
    "Schirmer's test", 'Refraction', 'Ishihara test', 'Pachymeter',
    'เช็ดตา', 'Pentacam', 'Corvis', 'OPDScan', 'Topolyser',
    'Specular Micro', 'CTVF', 'Fundus Photo', 'Cirrus OCT',
    'Spectral OCT', 'IOL Master', 'A-Scan', 'B-Scan', 'I&C',
    'irrigate sac', 'Epilation', 'Remove Concretion', 'Remove FB',
    'Remove FB w RustR Removal', 'Stitch Off',
    'lid spa 1 ครั้ง', 'lid spa pack 5', 'lid spa pack 10',
    'lid spa pack 20', 'YAG Cap', 'YAG PI', 'Argon', 'PRP',
    'YagSutureLysis', 'YagVitreolysis', 'FFA', 'ICG', 'FFA+ICG',
    'ECCE + Mono IOL', 'Phaco + Mono IOL',
    'Phaco + Mono Toric IOL', 'Phaco + Bifocal IOL (EDOF)',
    'Phaco + Bifocal Toric IOL (EDOF)', 'Phaco + Trifocal IOL',
    'Phaco + Trifocal Toric IOL', 'FLAC', 'Pterygium Ex w graft',
    'Pterygium Ex', 'PKP', 'DMEK', 'DSAEK',
    'Trabeculectomy', 'Glaucoma Drainage Device', 'Xen Implantation',
    'Combine PE + Trab', 'Combine PE + GDD',
    'Goniosynechialysis', 'CD Drainage', 'Bleb Revision',
    'Blepharoplasty', 'Blepharoplasty w lavator resection',
    'Lavator Resection', 'PPV with Endolaser',
    'Avastin Intravitreous', 'Vabysmo Intravitreous',
    'Muscle surgery', 'NanoRelex', 'NanoLASIK', 'LASIK', 'PRK',
    'ICL', 'Toric ICL',
  ];

  @override
  void initState() {
    super.initState();
    _doctorTabController = TabController(length: 2, vsync: this);
    _doctorTabController.addListener(() {
      if (!_doctorTabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = MockData.patients;
      } else {
        final q = query.toLowerCase();
        _filteredPatients = MockData.patients.where((p) {
          return p.fullName.toLowerCase().contains(q) ||
              p.hn.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  void _selectPatient(Patient patient) {
    setState(() {
      _selectedPatient = patient;
    });
  }

  void _nextStep() {
    if (_currentStep < _stepLabels.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  bool get _canProceedStep2 {
    if (_doctorTabController.index == 0) {
      return _selectedDoctorId != null;
    } else {
      return _offScheduleDoctorId != null && _offScheduleTime != null;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _doctorSearchController.dispose();
    _ccController.dispose();
    _noteController.dispose();
    _doctorTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(
          'สร้างนัดหมายใหม่',
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
                  // Vertical step indicator on the left
                  Container(
                    width: 160,
                    color: Colors.white,
                    child: _buildVerticalStepIndicator(),
                  ),
                  VerticalDivider(width: 1, color: AppTheme.lineColorD9),
                  // Content + bottom nav on the right
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: _buildStepContent()),
                        _buildBottomNav(),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildStepIndicator(),
                Divider(height: 1, color: AppTheme.lineColorD9),
                Expanded(child: _buildStepContent()),
                _buildBottomNav(),
              ],
            );
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Step Indicator
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStepIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(_stepLabels.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            final stepBefore = index ~/ 2;
            final isCompleted = stepBefore < _currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: isCompleted
                    ? AppTheme.primaryThemeApp
                    : AppTheme.lineColorD9,
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isActive = stepIndex == _currentStep;
          final isCompleted = stepIndex < _currentStep;

          return _buildStepCircle(
            stepIndex: stepIndex,
            label: _stepLabels[stepIndex],
            isActive: isActive,
            isCompleted: isCompleted,
          );
        }),
      ),
    );
  }

  Widget _buildStepCircle({
    required int stepIndex,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    final Color bgColor;
    final Widget child;

    if (isCompleted) {
      bgColor = AppTheme.primaryThemeApp;
      child = const Icon(Icons.check, size: 18, color: Colors.white);
    } else if (isActive) {
      bgColor = AppTheme.primaryThemeApp;
      child = Text(
        '${stepIndex + 1}',
        style: AppTheme.generalText(13,
            fonWeight: FontWeight.bold, color: Colors.white),
      );
    } else {
      bgColor = AppTheme.lineColorD9;
      child = Text(
        '${stepIndex + 1}',
        style: AppTheme.generalText(13,
            fonWeight: FontWeight.bold, color: AppTheme.secondaryText62),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: child,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTheme.generalText(
            11,
            fonWeight: isActive || isCompleted
                ? FontWeight.w600
                : FontWeight.normal,
            color: isActive || isCompleted
                ? AppTheme.primaryThemeApp
                : AppTheme.secondaryText62,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_stepLabels.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepBefore = index ~/ 2;
            final isCompleted = stepBefore < _currentStep;
            return Container(
              width: 2,
              height: 32,
              color: isCompleted
                  ? AppTheme.primaryThemeApp
                  : AppTheme.lineColorD9,
            );
          }

          final stepIndex = index ~/ 2;
          final isActive = stepIndex == _currentStep;
          final isCompleted = stepIndex < _currentStep;

          return _buildVerticalStepRow(
            stepIndex: stepIndex,
            label: _stepLabels[stepIndex],
            isActive: isActive,
            isCompleted: isCompleted,
          );
        }),
      ),
    );
  }

  Widget _buildVerticalStepRow({
    required int stepIndex,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    final Color circleBg;
    final Widget circleChild;

    if (isCompleted) {
      circleBg = AppTheme.primaryThemeApp;
      circleChild = const Icon(Icons.check, size: 18, color: Colors.white);
    } else if (isActive) {
      circleBg = AppTheme.primaryThemeApp;
      circleChild = Text(
        '${stepIndex + 1}',
        style: AppTheme.generalText(13,
            fonWeight: FontWeight.bold, color: Colors.white),
      );
    } else {
      circleBg = AppTheme.lineColorD9;
      circleChild = Text(
        '${stepIndex + 1}',
        style: AppTheme.generalText(13,
            fonWeight: FontWeight.bold, color: AppTheme.secondaryText62),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: circleChild,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            style: AppTheme.generalText(
              13,
              fonWeight: isActive || isCompleted
                  ? FontWeight.w600
                  : FontWeight.normal,
              color: isActive || isCompleted
                  ? AppTheme.primaryThemeApp
                  : AppTheme.secondaryText62,
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Step Content
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1PatientSelection();
      case 1:
        return _buildStep2DoctorSelection();
      case 2:
        return _buildStep3GeneralInfo();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 1: เลือกคนไข้ ──────────────────────────────────────────────

  Widget _buildStep1PatientSelection() {
    return Column(
      children: [
        // Search bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'ค้นหาชื่อ-สกุล หรือ HN',
              hintStyle: AppTheme.generalText(14,
                  color: AppTheme.secondaryText62),
              prefixIcon:
                  Icon(Icons.search, color: AppTheme.secondaryText62),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12),
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
        ),

        // Result count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ทั้งหมด ${_filteredPatients.length} คน',
              style: AppTheme.generalText(13,
                  color: AppTheme.secondaryText62),
            ),
          ),
        ),

        // Patient list
        Expanded(
          child: _filteredPatients.isEmpty
              ? Center(
                  child: Text(
                    'ไม่พบคนไข้',
                    style: AppTheme.generalText(15,
                        color: AppTheme.secondaryText62),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredPatients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final patient = _filteredPatients[index];
                    return _buildPatientSelectionCard(patient);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPatientSelectionCard(Patient patient) {
    final isSelected = _selectedPatient?.id == patient.id;
    final isMale = patient.gender == 'male';
    final initials = _getInitials(patient.firstName, patient.lastName);

    return GestureDetector(
      onTap: () => _selectPatient(patient),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryThemeApp
                : AppTheme.lineColorD9,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: isMale
                  ? AppTheme.primaryThemeApp.withValues(alpha: 0.1)
                  : AppTheme.femaleColor.withValues(alpha: 0.1),
              backgroundImage: patient.avatarUrl != null
                  ? NetworkImage(patient.avatarUrl!)
                  : null,
              child: patient.avatarUrl == null
                  ? Text(
                      initials,
                      style: AppTheme.generalText(
                        14,
                        fonWeight: FontWeight.bold,
                        color: isMale
                            ? AppTheme.primaryThemeApp
                            : AppTheme.femaleColor,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: AppTheme.generalText(
                      15,
                      fonWeight: FontWeight.w600,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // HN Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.hnBadgeBgColor,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppTheme.hnBadgeBorderColor),
                        ),
                        child: Text(
                          'HN : ${patient.hn}',
                          style: AppTheme.generalText(
                            11,
                            fonWeight: FontWeight.w600,
                            color: AppTheme.hnBadgeBorderColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'อายุ ${patient.age} ปี',
                        style: AppTheme.generalText(
                          12,
                          color: AppTheme.secondaryText62,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(Icons.check_circle,
                  color: AppTheme.primaryThemeApp, size: 24)
            else
              Icon(Icons.radio_button_unchecked,
                  color: AppTheme.lineColorD9, size: 24),
          ],
        ),
      ),
    );
  }

  // ── Step 2: เลือกแพทย์ ──────────────────────────────────────────────

  Widget _buildStep2DoctorSelection() {
    return Column(
      children: [
        // Calendar date picker
        _buildCalendarSection(),
        Divider(height: 1, color: AppTheme.lineColorD9),

        // Tab bar: แพทย์ในตาราง / แพทย์นอกตาราง
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _doctorTabController,
            labelColor: AppTheme.primaryThemeApp,
            unselectedLabelColor: AppTheme.secondaryText62,
            indicatorColor: AppTheme.primaryThemeApp,
            labelStyle: AppTheme.generalText(14, fonWeight: FontWeight.w600),
            unselectedLabelStyle: AppTheme.generalText(14),
            tabs: const [
              Tab(text: 'แพทย์ในตาราง'),
              Tab(text: 'แพทย์นอกตาราง'),
            ],
          ),
        ),
        Divider(height: 1, color: AppTheme.lineColorD9),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _doctorTabController,
            children: [
              _buildInScheduleTab(),
              _buildOffScheduleTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _appointmentDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) {
            setState(() {
              _appointmentDate = picked;
              // Reset doctor selection when date changes
              _selectedDoctorId = null;
              _selectedShift = null;
              _offScheduleDoctorId = null;
            });
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.lineColorD9),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today,
                  color: AppTheme.primaryThemeApp, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _formatDate(_appointmentDate),
                  style: AppTheme.generalText(
                    15,
                    fonWeight: FontWeight.w500,
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down,
                  color: AppTheme.secondaryText62, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน',
      'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม',
      'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
    ];
    const days = [
      'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี',
      'ศุกร์', 'เสาร์', 'อาทิตย์',
    ];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    final buddhistYear = date.year + 543;
    return 'วัน$dayName ที่ ${date.day} $monthName $buddhistYear';
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ── Tab 1: แพทย์ในตาราง ──────────────────────────────────────────

  Widget _buildInScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Department selector
          _buildDropdown(
            label: 'แผนก',
            value: _selectedDepartmentId,
            items: MockData.departments.map((d) {
              return DropdownMenuItem<String>(
                value: d['id'],
                child: Text(d['name']!),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                _selectedDepartmentId = v;
                _selectedDoctorId = null;
              _selectedShift = null;
              });
            },
            hint: 'เลือกแผนก',
          ),
          const SizedBox(height: 16),

          // Purpose segment buttons
          Text(
            'วัตถุประสงค์',
            style: AppTheme.generalText(14,
                fonWeight: FontWeight.w600, color: AppTheme.primaryText),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MockData.appointmentPurposes.map((purpose) {
                final isActive = _selectedPurpose == purpose;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPurpose = purpose;
                        _selectedDoctorId = null;
              _selectedShift = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.primaryThemeApp
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? AppTheme.primaryThemeApp
                              : AppTheme.lineColorD9,
                        ),
                      ),
                      child: Text(
                        purpose,
                        style: AppTheme.generalText(
                          13,
                          fonWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                          color: isActive
                              ? Colors.white
                              : AppTheme.primaryText,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Doctor list grouped by shift
          _buildScheduledDoctorList(),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getScheduledDoctors() {
    final dateKey = _formatDateKey(_appointmentDate);

    // Find schedules matching date + purpose
    final matchingSchedules = MockData.doctorSchedules.where((s) {
      final matchesDate = s['date'] == dateKey;
      final matchesPurpose =
          (s['purposes'] as List<String>).contains(_selectedPurpose);
      return matchesDate && matchesPurpose;
    }).toList();

    // Filter by department if selected
    final result = <Map<String, dynamic>>[];
    for (final schedule in matchingSchedules) {
      final doctor = MockData.doctors.firstWhere(
        (d) => d['id'] == schedule['doctorId'],
        orElse: () => <String, dynamic>{},
      );
      if (doctor.isEmpty) {
        continue;
      }
      if (_selectedDepartmentId != null &&
          doctor['departmentId'] != _selectedDepartmentId) {
        continue;
      }

      result.add({
        ...doctor,
        'shifts': schedule['shifts'],
      });
    }
    return result;
  }

  Widget _buildScheduledDoctorList() {
    final doctors = _getScheduledDoctors();

    if (doctors.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.person_off, size: 48, color: AppTheme.secondaryText62),
            const SizedBox(height: 8),
            Text(
              'ไม่พบแพทย์ในตาราง',
              style:
                  AppTheme.generalText(14, color: AppTheme.secondaryText62),
            ),
          ],
        ),
      );
    }

    // Group doctors by shift
    final morningDoctors =
        doctors.where((d) => (d['shifts'] as List).contains('morning')).toList();
    final afternoonDoctors = doctors
        .where((d) => (d['shifts'] as List).contains('afternoon'))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (morningDoctors.isNotEmpty) ...[
          _buildShiftHeader('กะเช้า', '09:00 - 12:00'),
          const SizedBox(height: 8),
          ...morningDoctors.map((d) => _buildDoctorCard(
                d,
                shift: 'morning',
              )),
          const SizedBox(height: 16),
        ],
        if (afternoonDoctors.isNotEmpty) ...[
          _buildShiftHeader('กะบ่าย', '13:00 - 16:00'),
          const SizedBox(height: 8),
          ...afternoonDoctors.map((d) => _buildDoctorCard(
                d,
                shift: 'afternoon',
              )),
        ],
      ],
    );
  }

  Widget _buildShiftHeader(String shiftName, String timeRange) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryThemeApp.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time,
              size: 16, color: AppTheme.primaryThemeApp),
          const SizedBox(width: 8),
          Text(
            shiftName,
            style: AppTheme.generalText(14,
                fonWeight: FontWeight.w600,
                color: AppTheme.primaryThemeApp),
          ),
          const SizedBox(width: 8),
          Text(
            timeRange,
            style: AppTheme.generalText(13,
                color: AppTheme.primaryThemeApp),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, {String? shift}) {
    final doctorId = doctor['id'] as String;
    final isSelected = _selectedDoctorId == doctorId && _selectedShift == shift;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDoctorId = doctorId;
          _selectedShift = shift;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryThemeApp
                : AppTheme.lineColorD9,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor:
                  AppTheme.primaryThemeApp.withValues(alpha: 0.1),
              child: Icon(Icons.person, color: AppTheme.primaryThemeApp),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'] as String,
                    style: AppTheme.generalText(15,
                        fonWeight: FontWeight.w600,
                        color: AppTheme.primaryText),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor['specialty'] as String,
                    style: AppTheme.generalText(12,
                        color: AppTheme.secondaryText62),
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(Icons.check_circle,
                  color: AppTheme.primaryThemeApp, size: 24)
            else
              Icon(Icons.radio_button_unchecked,
                  color: AppTheme.lineColorD9, size: 24),
          ],
        ),
      ),
    );
  }

  // ── Tab 2: แพทย์นอกตาราง ──────────────────────────────────────────

  Widget _buildOffScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Department selector
          _buildDropdown(
            label: 'แผนก',
            value: _offScheduleDepartmentId,
            items: MockData.departments.map((d) {
              return DropdownMenuItem<String>(
                value: d['id'],
                child: Text(d['name']!),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                _offScheduleDepartmentId = v;
                _offScheduleDoctorId = null;
              });
            },
            hint: 'เลือกแผนก',
          ),
          const SizedBox(height: 16),

          // Purpose selector
          _buildDropdown(
            label: 'วัตถุประสงค์',
            value: _offSchedulePurpose,
            items: MockData.appointmentPurposes.map((p) {
              return DropdownMenuItem<String>(
                value: p,
                child: Text(p),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                _offSchedulePurpose = v;
              });
            },
            hint: 'เลือกวัตถุประสงค์',
          ),
          const SizedBox(height: 16),

          // Search doctor
          Text(
            'เลือกแพทย์',
            style: AppTheme.generalText(14,
                fonWeight: FontWeight.w600, color: AppTheme.primaryText),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _doctorSearchController,
            onChanged: (v) => setState(() => _doctorSearchQuery = v),
            decoration: InputDecoration(
              hintText: 'ค้นหาชื่อแพทย์',
              hintStyle: AppTheme.generalText(14,
                  color: AppTheme.secondaryText62),
              prefixIcon:
                  Icon(Icons.search, color: AppTheme.secondaryText62),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12),
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
          const SizedBox(height: 12),
          _buildOffScheduleDoctorList(),

          // Time picker (shown when doctor is selected)
          if (_offScheduleDoctorId != null) ...[
            const SizedBox(height: 20),
            _buildTimePicker(),
          ],
        ],
      ),
    );
  }

  Widget _buildOffScheduleDoctorList() {
    final doctors = MockData.doctors.where((d) {
      if (_offScheduleDepartmentId != null &&
          d['departmentId'] != _offScheduleDepartmentId) {
        return false;
      }
      if (_doctorSearchQuery.isNotEmpty) {
        final name = (d['name'] as String).toLowerCase();
        if (!name.contains(_doctorSearchQuery.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();

    if (doctors.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.person_off, size: 48, color: AppTheme.secondaryText62),
            const SizedBox(height: 8),
            Text(
              'ไม่พบแพทย์',
              style:
                  AppTheme.generalText(14, color: AppTheme.secondaryText62),
            ),
          ],
        ),
      );
    }

    return Column(
      children: doctors.map((doctor) {
        final doctorId = doctor['id'] as String;
        final isSelected = _offScheduleDoctorId == doctorId;

        return GestureDetector(
          onTap: () {
            setState(() {
              _offScheduleDoctorId = doctorId;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryThemeApp
                    : AppTheme.lineColorD9,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      AppTheme.primaryThemeApp.withValues(alpha: 0.1),
                  child:
                      Icon(Icons.person, color: AppTheme.primaryThemeApp),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor['name'] as String,
                        style: AppTheme.generalText(15,
                            fonWeight: FontWeight.w600,
                            color: AppTheme.primaryText),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doctor['specialty'] as String,
                        style: AppTheme.generalText(12,
                            color: AppTheme.secondaryText62),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle,
                      color: AppTheme.primaryThemeApp, size: 24)
                else
                  Icon(Icons.radio_button_unchecked,
                      color: AppTheme.lineColorD9, size: 24),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เวลานัดหมาย',
          style: AppTheme.generalText(14,
              fonWeight: FontWeight.w600, color: AppTheme.primaryText),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _offScheduleTime ?? const TimeOfDay(hour: 9, minute: 0),
            );
            if (picked != null) {
              setState(() {
                _offScheduleTime = picked;
              });
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lineColorD9),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(Icons.access_time,
                    color: AppTheme.primaryThemeApp, size: 20),
                const SizedBox(width: 12),
                Text(
                  _offScheduleTime != null
                      ? _offScheduleTime!.format(context)
                      : 'เลือกเวลา',
                  style: AppTheme.generalText(
                    15,
                    color: _offScheduleTime != null
                        ? AppTheme.primaryText
                        : AppTheme.secondaryText62,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.generalText(14,
              fonWeight: FontWeight.w600, color: AppTheme.primaryText),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.lineColorD9),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                hint,
                style: AppTheme.generalText(14,
                    color: AppTheme.secondaryText62),
              ),
              style: AppTheme.generalText(14, color: AppTheme.primaryText),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 3: Placeholder ───────────────────────────────────────────

  Widget _buildStep3GeneralInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exam checkboxes
          Text(
            'รายการตรวจ / หัตถการ',
            style: AppTheme.generalText(16,
                fonWeight: FontWeight.bold, color: AppTheme.primaryText),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _examItems.map((exam) {
              final isChecked = _selectedExams.contains(exam);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isChecked) {
                      _selectedExams.remove(exam);
                    } else {
                      _selectedExams.add(exam);
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isChecked
                        ? AppTheme.primaryThemeApp.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isChecked
                          ? AppTheme.primaryThemeApp
                          : AppTheme.lineColorD9,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isChecked
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 18,
                        color: isChecked
                            ? AppTheme.primaryThemeApp
                            : AppTheme.secondaryText62,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        exam,
                        style: AppTheme.generalText(
                          13,
                          color: isChecked
                              ? AppTheme.primaryThemeApp
                              : AppTheme.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          Divider(color: AppTheme.lineColorD9),
          const SizedBox(height: 16),

          // CC field
          Text(
            'CC (Chief Complaint)',
            style: AppTheme.generalText(16,
                fonWeight: FontWeight.bold, color: AppTheme.primaryText),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ccController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'ระบุอาการสำคัญ...',
              hintStyle:
                  AppTheme.generalText(14, color: AppTheme.secondaryText62),
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
          const SizedBox(height: 24),
          Divider(color: AppTheme.lineColorD9),
          const SizedBox(height: 16),

          // Note field
          Text(
            'โน๊ต',
            style: AppTheme.generalText(16,
                fonWeight: FontWeight.bold, color: AppTheme.primaryText),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'หมายเหตุเพิ่มเติม...',
              hintStyle:
                  AppTheme.generalText(14, color: AppTheme.secondaryText62),
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Bottom Navigation
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildBottomNav() {
    final isFirstStep = _currentStep == 0;
    final isLastStep = _currentStep == _stepLabels.length - 1;
    bool canProceed;
    switch (_currentStep) {
      case 0:
        canProceed = _selectedPatient != null;
        break;
      case 1:
        canProceed = _canProceedStep2;
        break;
      default:
        canProceed = true;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.lineColorD9)),
      ),
      child: Row(
        children: [
          // Back button
          if (!isFirstStep)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryText,
                  side: BorderSide(color: AppTheme.lineColorD9),
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
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
            ),

          if (!isFirstStep) const SizedBox(width: 12),

          // Next / Submit button
          Expanded(
            child: ElevatedButton(
              onPressed: canProceed
                  ? (isLastStep ? () => Navigator.pop(context) : _nextStep)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryThemeApp,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.lineColorD9,
                disabledForegroundColor: AppTheme.secondaryText62,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                isLastStep ? 'ยืนยัน' : 'ถัดไป',
                style: AppTheme.generalText(
                  15,
                  fonWeight: FontWeight.w600,
                  color: canProceed ? Colors.white : AppTheme.secondaryText62,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String firstName, String lastName) {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }
}
