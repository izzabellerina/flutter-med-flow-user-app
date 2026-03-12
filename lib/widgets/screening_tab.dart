import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/screening.dart';

class ScreeningTab extends StatefulWidget {
  const ScreeningTab({super.key});

  @override
  State<ScreeningTab> createState() => _ScreeningTabState();
}

class _ScreeningTabState extends State<ScreeningTab> {
  final _ccController = TextEditingController();
  final _piController = TextEditingController();
  final _phController = TextEditingController();
  final _peController = TextEditingController();

  final List<Screening> _screenings = [
    Screening(
      id: '1',
      cc: 'ปวดศีรษะมา 2 วัน',
      pi: 'เริ่มปวดศีรษะตั้งแต่เมื่อวาน ปวดบริเวณขมับทั้งสองข้าง',
      ph: 'ไม่มีโรคประจำตัว',
      pe: 'BP 120/80, PR 72, Temp 36.5°C',
      recorderName: 'ธนวัฒน์ แก้วพรหม',
      recordedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Screening(
      id: '2',
      cc: 'ไข้สูง ไอ',
      pi: 'มีไข้สูง 3 วัน ไอมีเสมหะ',
      ph: 'เคยเป็นหอบหืดตอนเด็ก',
      pe: 'Temp 38.5°C, Lung: wheezing both sides',
      recorderName: 'ธนวัฒน์ แก้วพรหม',
      recordedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  List<Screening> get _currentScreenings =>
      _screenings.where((s) => s.isToday).toList();

  List<Screening> get _historyScreenings =>
      _screenings.where((s) => !s.isToday).toList();

  void _addScreening() {
    if (_ccController.text.isEmpty &&
        _piController.text.isEmpty &&
        _phController.text.isEmpty &&
        _peController.text.isEmpty) {
      return;
    }

    setState(() {
      _screenings.insert(
        0,
        Screening(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          cc: _ccController.text,
          pi: _piController.text,
          ph: _phController.text,
          pe: _peController.text,
          recorderName: 'ธนวัฒน์ แก้วพรหม',
          recordedAt: DateTime.now(),
        ),
      );
      _ccController.clear();
      _piController.clear();
      _phController.clear();
      _peController.clear();
    });
  }

  @override
  void dispose() {
    _ccController.dispose();
    _piController.dispose();
    _phController.dispose();
    _peController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentScreenings;
    final history = _historyScreenings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'คัดกรอง',
            style: AppTheme.generalText(
              20,
              fonWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 16),

          // Form fields
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildField('CC', _ccController)),
              const SizedBox(width: 12),
              Expanded(child: _buildField('PI', _piController)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildField('PH', _phController)),
              const SizedBox(width: 12),
              Expanded(child: _buildField('PE', _peController)),
            ],
          ),
          const SizedBox(height: 16),

          // Add button
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            child: ElevatedButton(
              onPressed: _addScreening,
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

          // ปัจจุบัน
          Text(
            'คัดกรองปัจจุบัน',
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
                'ยังไม่มีข้อมูลคัดกรองวันนี้',
                style: AppTheme.generalText(
                  14,
                  color: AppTheme.secondaryText62,
                ),
              ),
            )
          else
            ...current.map((s) => _buildScreeningCard(s)),

          const SizedBox(height: 24),

          // ย้อนหลัง
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
            ...history.map((s) => _buildScreeningCard(s)),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
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
          maxLines: 2,
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
  }

  Widget _buildScreeningCard(Screening screening) {
    final dateStr =
        '${screening.recordedAt.day} ${_thaiMonth(screening.recordedAt.month)} ${screening.recordedAt.year + 543}, '
        '${screening.recordedAt.hour.toString().padLeft(2, '0')}:${screening.recordedAt.minute.toString().padLeft(2, '0')} น.';

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
          Row(
            children: [
              Text(
                'คัดกรอง',
                style: AppTheme.generalText(
                  14,
                  fonWeight: FontWeight.w600,
                  color: AppTheme.primaryText,
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
                    _screenings.removeWhere((s) => s.id == screening.id);
                  });
                },
                child: Icon(Icons.delete_outline,
                    size: 20, color: AppTheme.secondaryText62),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoLine('CC :', screening.cc),
          _buildInfoLine('PI :', screening.pi),
          _buildInfoLine('PH :', screening.ph),
          _buildInfoLine('PE :', screening.pe),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'ผู้บันทึก: ${screening.recorderName}',
                style:
                    AppTheme.generalText(12, color: AppTheme.secondaryText62),
              ),
              const SizedBox(width: 12),
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
            width: 50,
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
              style:
                  AppTheme.generalText(13, color: AppTheme.secondaryText62),
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
