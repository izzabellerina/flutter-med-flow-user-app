import 'package:flutter/material.dart';
import '../app/theme.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _login() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void _loginWithGoogle() {
    // Mock Google login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary1,
              AppTheme.primaryThemeApp,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'MedFlow',
                        style: AppTheme.generalText(
                          28,
                          fonWeight: FontWeight.bold,
                          color: AppTheme.primaryThemeApp,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ลงทะเบียนคนไข้',
                        style: AppTheme.generalText(
                          16,
                          color: AppTheme.secondaryText62,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Username
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ชื่อเข้าใช้งาน',
                          style: AppTheme.generalText(
                            14,
                            color: AppTheme.primaryText,
                            fonWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person,
                              color: AppTheme.secondaryText62),
                          hintText: 'ชื่อเข้าใช้งาน',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'รหัสผ่าน',
                          style: AppTheme.generalText(
                            14,
                            color: AppTheme.primaryText,
                            fonWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock,
                              color: AppTheme.secondaryText62),
                          hintText: 'รหัสผ่าน',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppTheme.secondaryText62,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider with "หรือ"
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: AppTheme.lineColorD9),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'หรือ',
                              style: AppTheme.generalText(
                                14,
                                fonWeight: FontWeight.w500,
                                color: AppTheme.primaryText,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: AppTheme.lineColorD9),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Google Sign-In Button
                      OutlinedButton.icon(
                        onPressed: _loginWithGoogle,
                        icon: Image.network(
                          'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                          height: 20,
                          width: 20,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.g_mobiledata,
                            size: 24,
                            color: Colors.red,
                          ),
                        ),
                        label: const Text('เข้าสู่ระบบด้วย Google'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryText,
                          side: BorderSide(color: AppTheme.lineColorD9),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Login Button
                      ElevatedButton(
                        onPressed: _login,
                        child: const Text('ล็อคอิน'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
