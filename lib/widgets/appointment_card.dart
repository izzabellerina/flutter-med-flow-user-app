import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/appointment_model.dart';
import '../pages/appointment_detail_page.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final patient = appointment.patient;
    final doctor = appointment.doctor;
    final patientName =
        '${patient.prefix}${patient.firstName} ${patient.lastName}';
    final hn = patient.hn;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AppointmentDetailPage(appointment: appointment),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient info row
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.bgColor,
                    backgroundImage: patient.photoUrl.isNotEmpty
                        ? NetworkImage(patient.photoUrl)
                        : null,
                    child: patient.photoUrl.isEmpty
                        ? Icon(Icons.person,
                            color: AppTheme.secondaryText62, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Patient details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patientName,
                          style: AppTheme.generalText(
                            15,
                            fonWeight: FontWeight.w600,
                            color: AppTheme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (hn.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.hnBadgeBgColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.hnBadgeBorderColor,
                                  ),
                                ),
                                child: Text(
                                  'HN : $hn',
                                  style: AppTheme.generalText(
                                    11,
                                    fonWeight: FontWeight.w500,
                                    color: AppTheme.hnBadgeBorderColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Doctor section
              if (doctor.fullName.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  'แพทย์ผู้ตรวจ',
                  style: AppTheme.generalText(
                    13,
                    fonWeight: FontWeight.w500,
                    color: AppTheme.secondaryText62,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            AppTheme.primaryThemeApp.withValues(alpha: 0.1),
                        child: Icon(Icons.person,
                            size: 20, color: AppTheme.primaryThemeApp),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.fullName,
                              style: AppTheme.generalText(
                                11,
                                fonWeight: FontWeight.w600,
                                color: AppTheme.primaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (appointment.chiefComplaint.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'อาการ : ${appointment.chiefComplaint}',
                                style: AppTheme.generalText(
                                  10,
                                  color: AppTheme.secondaryText62,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Status badge
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusBgColor(appointment.status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _statusLabel(appointment.status),
                      style: AppTheme.generalText(
                        11,
                        fonWeight: FontWeight.w500,
                        color: _statusTextColor(appointment.status),
                      ),
                    ),
                  ),
                  if (appointment.roomName.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.location_on,
                        size: 14, color: AppTheme.secondaryText62),
                    const SizedBox(width: 2),
                    Text(
                      appointment.roomName,
                      style: AppTheme.generalText(
                          11, color: AppTheme.secondaryText62),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
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

  Color _statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFFDBEAFE);
      case 'waiting':
        return const Color(0xFFFFF7ED);
      case 'in_progress':
        return const Color(0xFFDCFCE7);
      case 'completed':
        return const Color(0xFFE0E7FF);
      case 'cancelled':
        return const Color(0xFFFEE2E2);
      default:
        return AppTheme.bgColor;
    }
  }

  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFF3B82F6);
      case 'waiting':
        return const Color(0xFFEA580C);
      case 'in_progress':
        return const Color(0xFF16A34A);
      case 'completed':
        return const Color(0xFF6366F1);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return AppTheme.primaryText;
    }
  }
}
