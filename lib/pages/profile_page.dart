import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../data/mock_data.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 70,
                  backgroundColor: AppTheme.bgColor,
                  child: Icon(
                    Icons.person,
                    size: 70,
                    color: AppTheme.primaryThemeApp.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),

                // Name
                Text(
                  user['name'] ?? '',
                  style: AppTheme.generalText(
                    22,
                    fonWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 32),

                // Logout Button
                OutlinedButton(
                  onPressed: () => _logout(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryThemeApp,
                    side: BorderSide(color: AppTheme.primary2),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ออกจากระบบ',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
