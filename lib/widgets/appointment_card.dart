import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/appointment.dart';
import '../pages/appointment_detail_page.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
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
                  child: Icon(Icons.person,
                      color: AppTheme.secondaryText62, size: 28),
                ),
                const SizedBox(width: 12),

                // Patient details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName,
                        style: AppTheme.generalText(
                          15,
                          fonWeight: FontWeight.w600,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            appointment.patientAge != null
                                ? 'อายุ : ${appointment.patientAge} ปี'
                                : 'อายุ : ไม่ระบุ',
                            style: AppTheme.generalText(
                              12,
                              color: AppTheme.secondaryText62,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // HN badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: appointment.isRegistered
                                  ? AppTheme.hnBadgeBgColor
                                  : AppTheme.noHnBadgeBgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: appointment.isRegistered
                                    ? AppTheme.hnBadgeBorderColor
                                    : Colors.grey[400]!,
                              ),
                            ),
                            child: Text(
                              appointment.isRegistered
                                  ? 'HN : ${appointment.patientHn}'
                                  : 'HN : ยังไม่ได้ลงทะเบียน',
                              style: AppTheme.generalText(
                                11,
                                fonWeight: FontWeight.w500,
                                color: appointment.isRegistered
                                    ? AppTheme.hnBadgeBorderColor
                                    : Colors.grey[600]!,
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

            // Doctor visits section
            if (appointment.doctorVisits.isNotEmpty) ...[
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
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: appointment.doctorVisits.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final visit = appointment.doctorVisits[index];
                    return _DoctorVisitChip(visit: visit);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }
}

class _DoctorVisitChip extends StatelessWidget {
  final DoctorVisit visit;

  const _DoctorVisitChip({required this.visit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryThemeApp.withValues(alpha: 0.1),
            child: Icon(Icons.person,
                size: 20, color: AppTheme.primaryThemeApp),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  visit.doctorName,
                  style: AppTheme.generalText(
                    11,
                    fonWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'จุดประสงค์ : ${visit.purpose}',
                  style: AppTheme.generalText(
                    10,
                    color: AppTheme.secondaryText62,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (visit.forDepartment != null &&
                    visit.forDepartment!.isNotEmpty)
                  Text(
                    'สำหรับ : ${visit.forDepartment}',
                    style: AppTheme.generalText(
                      10,
                      color: AppTheme.secondaryText62,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
