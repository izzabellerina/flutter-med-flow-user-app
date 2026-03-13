import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../data/mock_data.dart';
import '../models/patient.dart';

class CreateAppointmentPage extends StatefulWidget {
  const CreateAppointmentPage({super.key});

  @override
  State<CreateAppointmentPage> createState() => _CreateAppointmentPageState();
}

class _CreateAppointmentPageState extends State<CreateAppointmentPage> {
  int _currentStep = 0;
  Patient? _selectedPatient;
  final _searchController = TextEditingController();
  List<Patient> _filteredPatients = MockData.patients;

  final _stepLabels = const [
    'เลือกคนไข้',
    'รายละเอียดนัด',
    'ยืนยัน',
  ];

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

  @override
  void dispose() {
    _searchController.dispose();
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
        child: Column(
          children: [
            // Step indicator
            _buildStepIndicator(),
            Divider(height: 1, color: AppTheme.lineColorD9),

            // Step content
            Expanded(
              child: _buildStepContent(),
            ),

            // Bottom navigation
            _buildBottomNav(),
          ],
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

  // ══════════════════════════════════════════════════════════════════════════
  // Step Content
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1PatientSelection();
      case 1:
        return _buildStep2Placeholder();
      case 2:
        return _buildStep3Placeholder();
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

  // ── Step 2 & 3: Placeholder ─────────────────────────────────────────

  Widget _buildStep2Placeholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 48, color: AppTheme.secondaryText62),
          const SizedBox(height: 12),
          Text(
            'รายละเอียดนัดหมาย',
            style: AppTheme.generalText(16, color: AppTheme.secondaryText62),
          ),
          const SizedBox(height: 4),
          Text(
            'พบกันในเร็วๆ นี้',
            style: AppTheme.generalText(14, color: AppTheme.secondaryText62),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Placeholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline,
              size: 48, color: AppTheme.secondaryText62),
          const SizedBox(height: 12),
          Text(
            'ยืนยันการนัดหมาย',
            style: AppTheme.generalText(16, color: AppTheme.secondaryText62),
          ),
          const SizedBox(height: 4),
          Text(
            'พบกันในเร็วๆ นี้',
            style: AppTheme.generalText(14, color: AppTheme.secondaryText62),
          ),
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
    final canProceed = _currentStep == 0 ? _selectedPatient != null : true;

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
