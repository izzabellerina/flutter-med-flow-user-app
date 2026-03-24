import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
import '../models/response_model.dart';
import '../provider/common_provider.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import 'main_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await LocalStorageService.getSavedCredentials();
    if (credentials.isNotEmpty) {
      _usernameController.text = credentials['username'] ?? '';
      _passwordController.text = credentials['password'] ?? '';
      setState(() => _rememberMe = true);
    }
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError('กรุณากรอกชื่อเข้าใช้งานและรหัสผ่าน');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.login(
        username: username,
        password: password,
      );

      if (!mounted) return;

      if (result.responseEnum == ResponseEnum.success) {
        // Save to provider
        ref.read(loginProvider.notifier).state = result.data;
        ref.read(userProvider.notifier).state = result.data.user;

        // Fetch user info via /me
        final meResult = await AuthService.me(context);
        if (!mounted) return;
        if (meResult.responseEnum == ResponseEnum.success) {
          ref.read(userProvider.notifier).state = meResult.data;
        }

        // Save or clear credentials
        if (_rememberMe) {
          await LocalStorageService.saveCredentials(
            username: username,
            password: password,
          );
        } else {
          await LocalStorageService.clearCredentials();
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      } else {
        _showError('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
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
                        enabled: !_isLoading,
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
                        enabled: !_isLoading,
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
                      const SizedBox(height: 12),

                      // Remember me checkbox
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: _isLoading
                                  ? null
                                  : (v) {
                                      setState(
                                          () => _rememberMe = v ?? false);
                                    },
                              activeColor: AppTheme.primaryThemeApp,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'จดจำบัญชีผู้ใช้',
                            style: AppTheme.generalText(
                              14,
                              color: AppTheme.primaryText,
                            ),
                          ),
                        ],
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
                        onPressed: _isLoading ? null : () {},
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
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('ล็อคอิน'),
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
