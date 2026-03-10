import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/diagnosis.dart';

class DiagnosisTab extends StatefulWidget {
  const DiagnosisTab({super.key});

  @override
  State<DiagnosisTab> createState() => _DiagnosisTabState();
}

class _DiagnosisTabState extends State<DiagnosisTab> {
  final _recordNoteController = TextEditingController();
  final _diagnosisNoteController = TextEditingController();
  final _icd10Controller = TextEditingController();

  final List<Diagnosis> _diagnoses = [
    // Mock history data (past days)
    Diagnosis(
      id: '1',
      recordNote: 'บันทึกผลตรวจ',
      diagnosisType: 'Exam',
      icd10: 'A00.0',
      icdDesc:
          'Cholera due to Vibrio cholerae 01,biovar cholerae',
      snTerm:
          'Cholera due to Vibrio cholerae O1 Classical biotype (disorder)',
      diagnosisNote: 'ให้คำวินิจฉัย',
      recorderName: 'ธนวัฒน์ แก้วพรหม',
      recordedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Diagnosis(
      id: '2',
      recordNote: 'บันทึกผลตรวจ',
      diagnosisType: 'Exam',
      icd10: 'A00.0',
      icdDesc:
          'Cholera due to Vibrio cholerae 01,biovar cholerae',
      snTerm:
          'Cholera due to Vibrio cholerae O1 Classical biotype (disorder)',
      diagnosisNote: 'ให้คำวินิจฉัย',
      recorderName: 'ธนวัฒน์ แก้วพรหม',
      recordedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Diagnosis(
      id: '3',
      recordNote: 'บันทึกผลตรวจ',
      diagnosisType: 'Exam',
      icd10: 'A00.0',
      icdDesc:
          'Cholera due to Vibrio cholerae 01,biovar cholerae',
      snTerm:
          'Cholera due to Vibrio cholerae O1 Classical biotype (disorder)',
      diagnosisNote: 'ให้คำวินิจฉัย',
      recorderName: 'ธนวัฒน์ แก้วพรหม',
      recordedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Diagnosis(
      id: '4',
      recordNote: 'บันทึกผลตรวจ',
      diagnosisType: 'Exam',
      icd10: 'A00.0',
      icdDesc:
          'Cholera due to Vibrio cholerae 01,biovar cholerae',
      snTerm:
          'Cholera due to Vibrio cholerae O1 Classical biotype (disorder)',
      diagnosisNote: 'ให้คำวินิจฉัย',
      recorderName: 'ธนวัฒน์ แก้วพรหม',
      recordedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  List<Diagnosis> get _currentDiagnoses =>
      _diagnoses.where((d) => d.isToday).toList();

  List<Diagnosis> get _historyDiagnoses =>
      _diagnoses.where((d) => !d.isToday).toList();

  void _addDiagnosis() {
    if (_icd10Controller.text.isEmpty) return;

    setState(() {
      _diagnoses.insert(
        0,
        Diagnosis(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          recordNote: _recordNoteController.text,
          diagnosisType: 'Exam',
          icd10: _icd10Controller.text,
          icdDesc:
              'Cholera due to Vibrio cholerae 01,biovar cholerae',
          snTerm:
              'Cholera due to Vibrio cholerae O1 Classical biotype (disorder)',
          diagnosisNote: _diagnosisNoteController.text,
          recorderName: 'ธนวัฒน์ แก้วพรหม',
          recordedAt: DateTime.now(),
        ),
      );
      _recordNoteController.clear();
      _diagnosisNoteController.clear();
      _icd10Controller.clear();
    });
  }

  @override
  void dispose() {
    _recordNoteController.dispose();
    _diagnosisNoteController.dispose();
    _icd10Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentDiagnoses;
    final history = _historyDiagnoses;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ══════════════════════════════════════════════════════
          // Title
          // ══════════════════════════════════════════════════════
          Text(
            'วินิจฉัย',
            style: AppTheme.generalText(
              20,
              fonWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 16),

          // ══════════════════════════════════════════════════════
          // Form
          // ══════════════════════════════════════════════════════
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFormField(
                  label: 'บันทึกผลตรวจ',
                  controller: _recordNoteController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFormField(
                  label: 'คำวินิจฉัย',
                  controller: _diagnosisNoteController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildFormField(
            label: 'เลือก ICD10',
            controller: _icd10Controller,
            width: MediaQuery.of(context).size.width * 0.45,
          ),
          const SizedBox(height: 16),

          // Add button
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            child: ElevatedButton(
              onPressed: _addDiagnosis,
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
                'เพิ่ม',
                style: AppTheme.generalText(
                  16,
                  fonWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          Divider(color: AppTheme.lineColorD9),
          const SizedBox(height: 16),

          // ══════════════════════════════════════════════════════
          // วินิจฉัยปัจจุบัน (Today)
          // ══════════════════════════════════════════════════════
          Text(
            'วินิจฉัยปัจจุบัน',
            style: AppTheme.generalText(
              18,
              fonWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),

          if (current.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'ยังไม่มีข้อมูลวินิจฉัยวันนี้',
                style: AppTheme.generalText(
                  14,
                  color: AppTheme.secondaryText62,
                ),
              ),
            )
          else
            ...current.map((d) => _buildDiagnosisCard(d)),

          const SizedBox(height: 24),

          // ══════════════════════════════════════════════════════
          // ย้อนหลัง (History)
          // ══════════════════════════════════════════════════════
          Text(
            'ย้อนหลัง',
            style: AppTheme.generalText(
              18,
              fonWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),

          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'ยังไม่มีข้อมูลย้อนหลัง',
                style: AppTheme.generalText(
                  14,
                  color: AppTheme.secondaryText62,
                ),
              ),
            )
          else
            ...history.map((d) => _buildDiagnosisCard(d)),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    double? width,
  }) {
    final field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.generalText(
            15,
            fonWeight: FontWeight.w600,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
      ],
    );

    if (width != null) {
      return SizedBox(width: width, child: field);
    }
    return field;
  }

  Widget _buildDiagnosisCard(Diagnosis diagnosis) {
    final dateStr =
        '${diagnosis.recordedAt.day} ${_thaiMonth(diagnosis.recordedAt.month)} ${diagnosis.recordedAt.year + 543}, '
        '${diagnosis.recordedAt.hour.toString().padLeft(2, '0')}:${diagnosis.recordedAt.minute.toString().padLeft(2, '0')} น.';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lineColorD9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(
                'บันทึกผลตรวจ',
                style: AppTheme.generalText(
                  14,
                  fonWeight: FontWeight.w600,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.hnBadgeBgColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.hnBadgeBorderColor),
                ),
                child: Text(
                  diagnosis.diagnosisType,
                  style: AppTheme.generalText(
                    12,
                    fonWeight: FontWeight.w500,
                    color: AppTheme.hnBadgeBorderColor,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {},
                child: Icon(Icons.edit_outlined,
                    size: 20, color: AppTheme.secondaryText62),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  setState(() {
                    _diagnoses.removeWhere((d) => d.id == diagnosis.id);
                  });
                },
                child: Icon(Icons.delete_outline,
                    size: 20, color: AppTheme.secondaryText62),
              ),
            ],
          ),
          const SizedBox(height: 10),

          _buildInfoLine('ICD 10 :', diagnosis.icd10),
          _buildInfoLine('ICD_DESC :', diagnosis.icdDesc),
          _buildInfoLine('SN_TERM :', diagnosis.snTerm),
          _buildInfoLine('คำวินิจฉัย :', diagnosis.diagnosisNote),

          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'ผู้บันทึก: ${diagnosis.recorderName}',
                style: AppTheme.generalText(
                  12,
                  color: AppTheme.secondaryText62,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.access_time,
                  size: 14, color: AppTheme.secondaryText62),
              const SizedBox(width: 4),
              Text(
                dateStr,
                style: AppTheme.generalText(
                  12,
                  color: AppTheme.secondaryText62,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTheme.generalText(
                13,
                fonWeight: FontWeight.w600,
                color: AppTheme.primaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.generalText(
                13,
                color: AppTheme.secondaryText62,
              ),
            ),
          ),
        ],
      ),
    );
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
