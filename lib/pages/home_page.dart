import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../data/mock_data.dart';
import 'vital_sign_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              _buildProfileCard(),
              const SizedBox(height: 24),
              _buildMenuSection(context),
              const SizedBox(height: 24),
              _buildQueueSection(),
              const SizedBox(height: 24),
              _buildAnnouncementSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Top bar — Logo + Med-Flow
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Logo placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryThemeApp.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_hospital,
              color: AppTheme.primaryThemeApp,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Med-Flow',
            style: AppTheme.generalText(
              20,
              fonWeight: FontWeight.w700,
              color: AppTheme.primaryThemeApp,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Profile card — Blue gradient
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildProfileCard() {
    final user = MockData.currentUser;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary2,
            AppTheme.primaryThemeApp,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: Icon(
              Icons.person,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? '',
                  style: AppTheme.generalText(
                    20,
                    fonWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user['role'] ?? '',
                  style: AppTheme.generalText(
                    14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // เมนูแนะนำ
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('เมนูแนะนำ'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMenuItem(
                icon: Icons.monitor_heart_outlined,
                label: 'Vital Sign',
                color: const Color(0xFF3B82F6),
                bgColor: const Color(0xFFDBEAFE),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const VitalSignListPage()),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.medication_outlined,
                label: 'รายการสั่งยา',
                color: const Color(0xFF16A34A),
                bgColor: const Color(0xFFDCFCE7),
              ),
              _buildMenuItem(
                icon: Icons.assignment_outlined,
                label: 'ผลวินิจฉัย',
                color: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFEDE9FE),
              ),
              _buildMenuItem(
                icon: Icons.description_outlined,
                label: 'รายงาน',
                color: const Color(0xFFEA580C),
                bgColor: const Color(0xFFFFF7ED),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTheme.generalText(
                11,
                fonWeight: FontWeight.w500,
                color: AppTheme.primaryText,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // คิวรอตรวจวันนี้ — Queue cards
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildQueueSection() {
    final queueItems = [
      _QueueData(
        name: 'ภานุเดช ภานะมาส',
        hn: 'HN-000123',
        hospital: 'โรงพยาบาลกรุงเทพ',
        room: 'ห้องธุระการ',
        date: '16 มี.ค. 2569',
        time: 'อีก 5 นาที',
        isUrgent: true,
      ),
      _QueueData(
        name: 'สมชาย ใจดี',
        hn: 'HN-000456',
        hospital: 'โรงพยาบาลกรุงเทพ',
        room: 'ห้องธุระการ',
        date: '16 มี.ค. 2569',
        time: '10:30',
        isUrgent: false,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('ส่งต่อโรงพยาบาล', showMore: true),
          const SizedBox(height: 12),
          SizedBox(
            height: 155,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: queueItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) =>
                  _buildQueueCard(queueItems[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueCard(_QueueData data) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
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
          // Name + urgency badge
          Row(
            children: [
              Expanded(
                child: Text(
                  data.name,
                  style: AppTheme.generalText(
                    15,
                    fonWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (data.isUrgent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    'เร่งด่วน',
                    style: AppTheme.generalText(
                      10,
                      fonWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          // HN
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.hnBadgeBgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.hnBadgeBorderColor),
            ),
            child: Text(
              data.hn,
              style: AppTheme.generalText(
                11,
                fonWeight: FontWeight.w500,
                color: AppTheme.hnBadgeBorderColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Hospital
          Row(
            children: [
              Icon(Icons.local_hospital,
                  size: 14, color: AppTheme.secondaryText62),
              const SizedBox(width: 4),
              Text(
                data.hospital,
                style: AppTheme.generalText(
                  12,
                  color: AppTheme.secondaryText62,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Room
          Row(
            children: [
              Icon(Icons.location_on,
                  size: 14, color: AppTheme.secondaryText62),
              const SizedBox(width: 4),
              Text(
                data.room,
                style: AppTheme.generalText(
                  12,
                  color: AppTheme.secondaryText62,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Date + Time + Status button
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryThemeApp.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  data.date,
                  style: AppTheme.generalText(
                    10,
                    fonWeight: FontWeight.w500,
                    color: AppTheme.primaryThemeApp,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: data.isUrgent
                      ? Colors.orange.shade50
                      : AppTheme.timeBadgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  data.time,
                  style: AppTheme.generalText(
                    10,
                    fonWeight: FontWeight.w500,
                    color: data.isUrgent
                        ? Colors.orange.shade700
                        : AppTheme.timeBadgeTextColor,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryThemeApp,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'เข้าดู',
                  style: AppTheme.generalText(
                    11,
                    fonWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ประกาศ — Announcements
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildAnnouncementSection() {
    final announcements = [
      _AnnouncementData(
        title: 'หยุดงานวันแรงงาน',
        date: '12 กรกฎาคม 2566',
      ),
      _AnnouncementData(
        title: 'หยุดงานวันแรงงาน',
        date: '12 กรกฎาคม 2566',
      ),
      _AnnouncementData(
        title: 'หยุดงานวันแรงงาน',
        date: '12 กรกฎาคม 2566',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('ประกาศ', showMore: true),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: announcements.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) =>
                  _buildAnnouncementCard(announcements[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(_AnnouncementData data) {
    return Container(
      width: 200,
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
          // Image placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.bgColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Icon(
                Icons.image,
                size: 40,
                color: AppTheme.secondaryText9A,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.date,
                  style: AppTheme.generalText(
                    11,
                    color: AppTheme.secondaryText62,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.title,
                  style: AppTheme.generalText(
                    13,
                    fonWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Shared section header
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(String title, {bool showMore = false}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.primaryThemeApp,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTheme.generalText(
            18,
            fonWeight: FontWeight.w700,
            color: AppTheme.primaryText,
          ),
        ),
        const Spacer(),
        if (showMore)
          Row(
            children: [
              Text(
                'เพิ่มเติม',
                style: AppTheme.generalText(
                  13,
                  fonWeight: FontWeight.w500,
                  color: AppTheme.secondaryText62,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: AppTheme.secondaryText62,
              ),
            ],
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Data classes
// ══════════════════════════════════════════════════════════════════════════

class _QueueData {
  final String name;
  final String hn;
  final String hospital;
  final String room;
  final String date;
  final String time;
  final bool isUrgent;

  const _QueueData({
    required this.name,
    required this.hn,
    required this.hospital,
    required this.room,
    required this.date,
    required this.time,
    required this.isUrgent,
  });
}

class _AnnouncementData {
  final String title;
  final String date;

  const _AnnouncementData({
    required this.title,
    required this.date,
  });
}
