import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../data/mock_data.dart';
import '../models/vital_sign.dart';

class VitalSignListPage extends StatefulWidget {
  const VitalSignListPage({super.key});

  @override
  State<VitalSignListPage> createState() => _VitalSignListPageState();
}

class _VitalSignListPageState extends State<VitalSignListPage> {
  final _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';

  List<_PatientVitalData> get _filteredData {
    var data = _patientVitalSigns;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      data = data
          .where((d) =>
              d.patientName.toLowerCase().contains(q) ||
              d.hn.toLowerCase().contains(q))
          .toList();
    }

    return data;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String get _formattedDate {
    return '${_selectedDate.day.toString().padLeft(2, '0')}-'
        '${_selectedDate.month.toString().padLeft(2, '0')}-'
        '${_selectedDate.year}';
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
          'Vital Sign',
          style: AppTheme.generalText(
            20,
            fonWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchPanel(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildSearchPanel() {
    final filtered = _filteredData;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'ค้นหาชื่อ, นามสกุล หรือ HN',
              hintStyle: TextStyle(color: AppTheme.secondaryText62),
              prefixIcon:
                  Icon(Icons.search, color: AppTheme.secondaryText62),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.lineColorD9),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.lineColorD9),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Date picker
          InkWell(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lineColorD9),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _formattedDate,
                      style: AppTheme.generalText(
                        15,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ),
                  Icon(Icons.calendar_today,
                      color: AppTheme.secondaryText62, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Count
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'ทั้งหมด ${filtered.length}',
              style: AppTheme.generalText(
                14,
                fonWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final filtered = _filteredData;

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'ไม่พบข้อมูล',
          style: AppTheme.generalText(16, color: AppTheme.secondaryText62),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildPatientVitalCard(filtered[index]);
      },
    );
  }

  Widget _buildPatientVitalCard(_PatientVitalData data) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lineColorD9),
        boxShadow: [
          BoxShadow(
            color: AppTheme.inputShadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryThemeApp.withValues(alpha: 0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      AppTheme.primaryThemeApp.withValues(alpha: 0.1),
                  child: Icon(Icons.person,
                      size: 22, color: AppTheme.primaryThemeApp),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.patientName,
                        style: AppTheme.generalText(
                          15,
                          fonWeight: FontWeight.w600,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.hnBadgeBgColor,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: AppTheme.hnBadgeBorderColor),
                        ),
                        child: Text(
                          'HN : ${data.hn}',
                          style: AppTheme.generalText(
                            11,
                            fonWeight: FontWeight.w500,
                            color: AppTheme.hnBadgeBorderColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Vital signs
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: data.vitalSigns
                  .map((vs) => _buildVitalSignEntry(vs))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignEntry(VitalSign vs) {
    final dateStr =
        '${vs.recordedAt.day} ${_thaiMonth(vs.recordedAt.month)} ${vs.recordedAt.year + 543}, '
        '${vs.recordedAt.hour.toString().padLeft(2, '0')}:${vs.recordedAt.minute.toString().padLeft(2, '0')} น.';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.lineColorD9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Row(
            children: [
              Icon(Icons.access_time,
                  size: 14, color: AppTheme.secondaryText62),
              const SizedBox(width: 4),
              Text(
                dateStr,
                style:
                    AppTheme.generalText(12, color: AppTheme.secondaryText62),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Vital sign grid
          Row(
            children: [
              Expanded(child: _buildVitalItem('Bw', _fmtVal(vs.bw, 'kg'))),
              Expanded(child: _buildVitalItem('Ht', _fmtVal(vs.ht, 'cm'))),
              Expanded(child: _buildVitalItem('BMI', _fmtVal(vs.bmi, ''))),
              Expanded(
                  child: _buildVitalItem('Temp', _fmtVal(vs.temp, '°C'))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildVitalItem('sBp', _fmtVal(vs.sBp, ''))),
              Expanded(child: _buildVitalItem('dBp', _fmtVal(vs.dBp, ''))),
              Expanded(child: _buildVitalItem('Pr', _fmtVal(vs.pr, ''))),
              Expanded(child: _buildVitalItem('O2', _fmtVal(vs.o2, '%'))),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ผู้บันทึก: ${vs.recorderName}',
            style: AppTheme.generalText(11, color: AppTheme.secondaryText62),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.generalText(
            11,
            fonWeight: FontWeight.w600,
            color: AppTheme.secondaryText62,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.generalText(
            14,
            fonWeight: FontWeight.w600,
            color: AppTheme.primaryText,
          ),
        ),
      ],
    );
  }

  String _fmtVal(double? value, String unit) {
    if (value == null) return '-';
    final v = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    return unit.isNotEmpty ? '$v $unit' : v;
  }

  String _thaiMonth(int month) {
    const months = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน',
      'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม',
      'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
    ];
    return months[month - 1];
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Data class
// ══════════════════════════════════════════════════════════════════════════

class _PatientVitalData {
  final String patientName;
  final String hn;
  final List<VitalSign> vitalSigns;

  const _PatientVitalData({
    required this.patientName,
    required this.hn,
    required this.vitalSigns,
  });
}

final _patientVitalSigns = [
  _PatientVitalData(
    patientName:
        '${MockData.patients[0].prefix}${MockData.patients[0].firstName} ${MockData.patients[0].lastName}',
    hn: MockData.patients[0].hn,
    vitalSigns: [
      VitalSign(
        id: 'vs1',
        bw: 72.0,
        ht: 175.0,
        bmi: 23.5,
        sBp: 120,
        dBp: 80,
        pr: 72,
        o2: 98,
        temp: 36.5,
        recorderName: 'ธนวัฒน์ แก้วพรหม',
        recordedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ],
  ),
  _PatientVitalData(
    patientName:
        '${MockData.patients[1].prefix}${MockData.patients[1].firstName} ${MockData.patients[1].lastName}',
    hn: MockData.patients[1].hn,
    vitalSigns: [
      VitalSign(
        id: 'vs2',
        bw: 68.0,
        ht: 170.0,
        bmi: 23.5,
        sBp: 130,
        dBp: 85,
        pr: 78,
        o2: 97,
        temp: 36.8,
        recorderName: 'ธนวัฒน์ แก้วพรหม',
        recordedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      VitalSign(
        id: 'vs3',
        bw: 67.5,
        ht: 170.0,
        bmi: 23.4,
        sBp: 125,
        dBp: 82,
        pr: 75,
        o2: 98,
        temp: 36.6,
        recorderName: 'ธนวัฒน์ แก้วพรหม',
        recordedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ],
  ),
  _PatientVitalData(
    patientName:
        '${MockData.patients[4].prefix}${MockData.patients[4].firstName} ${MockData.patients[4].lastName}',
    hn: MockData.patients[4].hn,
    vitalSigns: [
      VitalSign(
        id: 'vs4',
        bw: 55.0,
        ht: 160.0,
        bmi: 21.5,
        sBp: 110,
        dBp: 70,
        pr: 68,
        o2: 99,
        temp: 36.3,
        recorderName: 'ธนวัฒน์ แก้วพรหม',
        recordedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ],
  ),
];
