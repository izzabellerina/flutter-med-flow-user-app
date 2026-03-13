import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/patient.dart';
import '../pages/patient_detail_page.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;

  const PatientCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final isMale = patient.gender == 'male';
    final initials = _getInitials(patient.firstName, patient.lastName);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientDetailPage(patient: patient),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: isMale
                  ? AppTheme.primaryThemeApp.withValues(alpha: 0.1)
                  : AppTheme.femaleColor.withValues(alpha: 0.1),
              child: Text(
                initials,
                style: AppTheme.generalText(
                  16,
                  fonWeight: FontWeight.bold,
                  color:
                      isMale ? AppTheme.primaryThemeApp : AppTheme.femaleColor,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: AppTheme.generalText(
                      16,
                      fonWeight: FontWeight.w600,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // HN Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.hnBadgeBgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.hnBadgeBorderColor),
                    ),
                    child: Text(
                      'HN : ${patient.hn}',
                      style: AppTheme.generalText(
                        12,
                        fonWeight: FontWeight.w600,
                        color: AppTheme.hnBadgeBorderColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Phone
                  Row(
                    children: [
                      Icon(Icons.phone,
                          size: 16, color: AppTheme.primaryThemeApp),
                      const SizedBox(width: 6),
                      Text(
                        patient.phone,
                        style: AppTheme.generalText(
                          13,
                          color: AppTheme.primaryThemeApp,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'อายุ : ${patient.age} ปี',
                    style: AppTheme.generalText(
                      13,
                      color: AppTheme.secondaryText62,
                    ),
                  ),
                ],
              ),
            ),

            // Gender icon
            Icon(
              isMale ? Icons.male : Icons.female,
              size: 28,
              color: isMale ? AppTheme.maleColor : AppTheme.femaleColor,
            ),
          ],
        ),
        ),
      ),
    );
  }

  String _getInitials(String firstName, String lastName) {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }
}
