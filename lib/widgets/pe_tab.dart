import 'dart:developer';

import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/request_models/physical_exam_request_model.dart';
import '../models/response_model.dart';
import '../services/clinical_service.dart';

class PeTab extends StatefulWidget {
  final String visitId;
  final String patientId;

  const PeTab({super.key, required this.visitId, required this.patientId});

  @override
  State<PeTab> createState() => _PeTabState();
}

class _PeTabState extends State<PeTab> {
  final _gaController = TextEditingController();
  final _peSummaryController = TextEditingController();

  final List<_PeSystem> _systems = [
    _PeSystem(name: 'HEENT', key: 'heent'),
    _PeSystem(name: 'Neck', key: 'neck'),
    _PeSystem(name: 'Cardiovascular', key: 'cardiovascular'),
    _PeSystem(name: 'Respiratory', key: 'respiratory'),
    _PeSystem(name: 'Abdomen', key: 'abdomen'),
    _PeSystem(name: 'Extremities', key: 'extremities'),
    _PeSystem(name: 'Neurological', key: 'neurological'),
    _PeSystem(name: 'Skin', key: 'skin'),
    _PeSystem(name: 'Psychiatric', key: 'psychiatric'),
  ];

  String _physicalExamId = '';
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchPhysicalExam();
  }

  Future<void> _fetchPhysicalExam() async {
    if (widget.visitId.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final result = await ClinicalService.getPhysicalExam(
        context,
        visitId: widget.visitId,
      );

      if (!mounted) return;

      if (result.responseEnum == ResponseEnum.success) {
        final pe = result.data;
        _physicalExamId = pe.id;
        _gaController.text = pe.generalAppearance;
        _peSummaryController.text = pe.summary;

        // Map API data to systems
        final systemMap = {
          'heent': pe.heent,
          'neck': pe.neck,
          'cardiovascular': pe.cardiovascular,
          'respiratory': pe.respiratory,
          'abdomen': pe.abdomen,
          'extremities': pe.extremities,
          'neurological': pe.neurological,
          'skin': pe.skin,
          'psychiatric': pe.psychiatric,
        };

        for (final sys in _systems) {
          final note = systemMap[sys.key];
          if (note != null) {
            sys.isNormal = note.normal;
            sys.noteController.text = note.notes;
          }
        }
      }
    } catch (e) {
      log('getPhysicalExam error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePe() async {
    if (_physicalExamId.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      PhysicalExamNoteItem noteItem(String key) {
        final sys = _systems.firstWhere((s) => s.key == key);
        return PhysicalExamNoteItem(
          normal: sys.isNormal,
          notes: sys.isNormal ? '' : sys.noteController.text,
        );
      }

      final body = PhysicalExamRequestModel(
        visitId: widget.visitId,
        patientId: widget.patientId,
        generalAppearance: _gaController.text,
        summary: _peSummaryController.text,
        heent: noteItem('heent'),
        neck: noteItem('neck'),
        cardiovascular: noteItem('cardiovascular'),
        respiratory: noteItem('respiratory'),
        abdomen: noteItem('abdomen'),
        extremities: noteItem('extremities'),
        neurological: noteItem('neurological'),
        skin: noteItem('skin'),
        psychiatric: noteItem('psychiatric'),
      );

      final result = await ClinicalService.savePhysicalExam(
        context,
        physicalExamId: _physicalExamId,
        body: body,
      );

      if (!mounted) return;

      if (result.responseEnum == ResponseEnum.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึก PE สำเร็จ')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึก PE ไม่สำเร็จ')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      log('savePhysicalExam error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาด')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _gaController.dispose();
    _peSummaryController.dispose();
    for (final s in _systems) {
      s.noteController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General Appearance
          Text(
            'General Appearance',
            style: AppTheme.generalText(
              15,
              fonWeight: FontWeight.w600,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _gaController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Well-groomed, no acute distress...',
              hintStyle: AppTheme.generalText(14, color: AppTheme.secondaryText62),
              contentPadding: const EdgeInsets.all(12),
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
          const SizedBox(height: 20),

          // System examination rows
          ...List.generate(_systems.length, (i) {
            return _buildSystemRow(_systems[i]);
          }),

          const SizedBox(height: 20),

          // PE Summary
          Text(
            'PE Summary',
            style: AppTheme.generalText(
              15,
              fonWeight: FontWeight.w600,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _peSummaryController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'สรุปผลตรวจร่างกาย...',
              hintStyle: AppTheme.generalText(14, color: AppTheme.secondaryText62),
              contentPadding: const EdgeInsets.all(12),
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
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _savePe,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, size: 20),
              label: Text(
                'บันทึก PE',
                style: AppTheme.generalText(
                  16,
                  fonWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryThemeApp,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSystemRow(_PeSystem sys) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  sys.name,
                  style: AppTheme.generalText(
                    15,
                    fonWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    sys.isNormal = !sys.isNormal;
                    if (sys.isNormal) {
                      sys.noteController.clear();
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: sys.isNormal
                        ? AppTheme.primaryThemeApp.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sys.isNormal
                          ? AppTheme.primaryThemeApp
                          : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    sys.isNormal ? 'Normal' : 'Abnormal',
                    style: AppTheme.generalText(
                      13,
                      fonWeight: FontWeight.w600,
                      color: sys.isNormal
                          ? AppTheme.primaryThemeApp
                          : Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!sys.isNormal) ...[
            const SizedBox(height: 8),
            TextField(
              controller: sys.noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'ระบุความผิดปกติ...',
                hintStyle: AppTheme.generalText(
                  14,
                  color: AppTheme.secondaryText62,
                ),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PeSystem {
  final String name;
  final String key;
  bool isNormal;
  final TextEditingController noteController;

  _PeSystem({
    required this.name,
    required this.key,
    this.isNormal = true,
  }) : noteController = TextEditingController();
}
