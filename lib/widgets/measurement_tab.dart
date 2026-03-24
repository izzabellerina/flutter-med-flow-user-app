import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/theme.dart';
import '../models/request_models/create_vital_sign_model.dart';
import '../models/response_model.dart';
import '../models/vital_sign.dart';
import '../services/telemed_service.dart';
import 'ble_measurement_bottom_sheet.dart';

class MeasurementTab extends StatefulWidget {
  final String sessionToken;

  const MeasurementTab({super.key, required this.sessionToken});

  @override
  State<MeasurementTab> createState() => _MeasurementTabState();
}

class _MeasurementTabState extends State<MeasurementTab> {
  final _bwController = TextEditingController();
  final _htController = TextEditingController();
  final _sBpController = TextEditingController();
  final _dBpController = TextEditingController();
  final _prController = TextEditingController();
  final _o2Controller = TextEditingController();
  final _tempController = TextEditingController();

  List<VitalSign> _vitalSigns = [];
  bool _isLoadingVitalSigns = false;
  bool _isSubmitting = false;

  List<VitalSign> get _currentVitalSigns =>
      _vitalSigns.where((v) => v.isToday).toList();

  List<VitalSign> get _historyVitalSigns =>
      _vitalSigns.where((v) => !v.isToday).toList();

  @override
  void initState() {
    super.initState();
    _fetchVitalSigns();
  }

  Future<void> _fetchVitalSigns() async {
    if (widget.sessionToken.isEmpty) return;

    setState(() => _isLoadingVitalSigns = true);

    try {
      final result = await TelemedService.vitalSigns(
        context,
        token: widget.sessionToken,
      );

      if (!mounted) return;

      if (result.responseEnum == ResponseEnum.success) {
        setState(() {
          _vitalSigns = result.data;
          _isLoadingVitalSigns = false;
        });
      } else {
        setState(() => _isLoadingVitalSigns = false);
        log('vitalSigns API failed');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingVitalSigns = false);
      log('vitalSigns error: $e');
    }
  }

  void _openBleBottomSheet() async {
    final result = await BleMeasurementBottomSheet.show(context);
    if (result == null) return;

    setState(() {
      if (result.bw != null) _bwController.text = result.bw!.toStringAsFixed(1);
      if (result.sBp != null)
        _sBpController.text = result.sBp!.round().toString();
      if (result.dBp != null)
        _dBpController.text = result.dBp!.round().toString();
      if (result.pr != null) _prController.text = result.pr!.round().toString();
      if (result.o2 != null) _o2Controller.text = result.o2!.round().toString();
      if (result.temp != null)
        _tempController.text = result.temp!.toStringAsFixed(1);
    });
  }

  Future<void> _addVitalSign() async {
    if (_bwController.text.isEmpty &&
        _htController.text.isEmpty &&
        _sBpController.text.isEmpty &&
        _dBpController.text.isEmpty &&
        _prController.text.isEmpty &&
        _o2Controller.text.isEmpty &&
        _tempController.text.isEmpty) {
      return;
    }

    if (_isSubmitting || widget.sessionToken.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final model = CreateVitalSignModel(
        sessionToken: widget.sessionToken,
        bodyWeight: double.tryParse(_bwController.text) ?? 0,
        height: double.tryParse(_htController.text) ?? 0,
        systolicBp: double.tryParse(_sBpController.text) ?? 0,
        diastolicBp: double.tryParse(_dBpController.text) ?? 0,
        temperature: double.tryParse(_tempController.text) ?? 0,
        oxygenSaturation: double.tryParse(_o2Controller.text) ?? 0,
        pulseRate: double.tryParse(_prController.text) ?? 0,
        respiratoryRate: 0,
        bloodGlucose: 0,
        painScore: 0,
      );

      final result = await TelemedService.createVitalSign(
        context,
        token: widget.sessionToken,
        createVitalSignModel: model,
      );

      if (!mounted) return;

      if (result.responseEnum == ResponseEnum.success) {
        _bwController.clear();
        _htController.clear();
        _sBpController.clear();
        _dBpController.clear();
        _prController.clear();
        _o2Controller.clear();
        _tempController.clear();

        // เรียก vitalSigns อีกรอบ
        await _fetchVitalSigns();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('เพิ่มสัญญาณชีพสำเร็จ')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เพิ่มสัญญาณชีพไม่สำเร็จ')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      log('createVitalSign error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('เกิดข้อผิดพลาด')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _bwController.dispose();
    _htController.dispose();
    _sBpController.dispose();
    _dBpController.dispose();
    _prController.dispose();
    _o2Controller.dispose();
    _tempController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentVitalSigns;
    final history = _historyVitalSigns;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + loading
          Row(
            children: [
              Text(
                'สัญญาณชีพ',
                style: AppTheme.generalText(
                  20,
                  fonWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              if (_isLoadingVitalSigns) ...[
                const SizedBox(width: 12),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Form fields
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildField('Bw (kg)', _bwController)),
              const SizedBox(width: 12),
              Expanded(child: _buildField('Ht (cm)', _htController)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildField('sBp', _sBpController)),
              const SizedBox(width: 12),
              Expanded(child: _buildField('dBp', _dBpController)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildField('Pr', _prController)),
              const SizedBox(width: 12),
              Expanded(child: _buildField('O2 (%)', _o2Controller)),
            ],
          ),
          const SizedBox(height: 12),
          _buildField(
            'Temp (°C)',
            _tempController,
            width: MediaQuery.of(context).size.width * 0.45,
          ),
          const SizedBox(height: 16),

          // Buttons row: เพิ่ม + อ่านค่าจากเครื่อง
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _addVitalSign,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    backgroundColor: AppTheme.primaryThemeApp,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'เพิ่ม',
                          style: AppTheme.generalText(
                            16,
                            fonWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openBleBottomSheet,
                  icon: const Icon(Icons.bluetooth, size: 18),
                  label: Text(
                    'อ่านค่าจากเครื่อง',
                    style: AppTheme.generalText(
                      14,
                      fonWeight: FontWeight.w600,
                      color: AppTheme.primaryThemeApp,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Divider(color: AppTheme.lineColorD9),
          const SizedBox(height: 16),

          // ปัจจุบัน
          Text(
            'สัญญาณชีพปัจจุบัน',
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
                'ยังไม่มีข้อมูลสัญญาณชีพวันนี้',
                style: AppTheme.generalText(
                  14,
                  color: AppTheme.secondaryText62,
                ),
              ),
            )
          else
            ...current.map((v) => _buildVitalSignCard(v)),

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
            ...history.map((v) => _buildVitalSignCard(v)),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
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

    if (width != null) return SizedBox(width: width, child: field);
    return field;
  }

  Widget _buildVitalSignCard(VitalSign vs) {
    final dateStr =
        '${vs.recordedAt.day} ${_thaiMonth(vs.recordedAt.month)} ${vs.recordedAt.year + 543}, '
        '${vs.recordedAt.hour.toString().padLeft(2, '0')}:${vs.recordedAt.minute.toString().padLeft(2, '0')} น.';

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
          Text(
            'สัญญาณชีพ',
            style: AppTheme.generalText(
              14,
              fonWeight: FontWeight.w600,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoLine('Bw :', _fmtVal(vs.bw, 'kg')),
          _buildInfoLine('Ht :', _fmtVal(vs.ht, 'cm')),
          _buildInfoLine('BMI :', _fmtVal(vs.bmi, '')),
          _buildInfoLine('sBp :', _fmtVal(vs.sBp, '')),
          _buildInfoLine('dBp :', _fmtVal(vs.dBp, '')),
          _buildInfoLine('Pr :', _fmtVal(vs.pr, '')),
          _buildInfoLine('O2 :', _fmtVal(vs.o2, '%')),
          _buildInfoLine('Temp :', _fmtVal(vs.temp, '°C')),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'ผู้บันทึก: ${vs.recorderName}',
                style: AppTheme.generalText(
                  12,
                  color: AppTheme.secondaryText62,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.access_time,
                size: 14,
                color: AppTheme.secondaryText62,
              ),
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
            width: 60,
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
              style: AppTheme.generalText(13, color: AppTheme.secondaryText62),
            ),
          ),
        ],
      ),
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
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม',
    ];
    return months[month - 1];
  }
}
