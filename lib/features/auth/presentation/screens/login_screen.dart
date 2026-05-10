import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import 'registration_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _studentPasswordController = TextEditingController();
  final _captchaController = TextEditingController();

  bool _isLoading = false;

  int _captchaA = 0;
  int _captchaB = 0;

  @override
  void initState() {
    super.initState();
    if (widget.role == 'student') {
      _generateCaptcha();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _studentIdController.dispose();
    _studentPasswordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  void _generateCaptcha() {
    final random = Random();
    setState(() {
      _captchaA = random.nextInt(10);
      _captchaB = random.nextInt(10);
      _captchaController.clear();
    });
  }

  Future<void> _handleLogin() async {
    if (widget.role == 'student') {
      await _handleStudentLogin();
    } else {
      await _handleStandardLogin();
    }
  }

  Future<void> _handleStudentLogin() async {
    final studentId = _studentIdController.text.trim();
    final password = _studentPasswordController.text.trim();
    final captchaAnswer = int.tryParse(_captchaController.text.trim());

    if (studentId.isEmpty) {
      _showError('Please enter your Student ID');
      return;
    }

    if (password.isEmpty) {
      _showError('Please enter your password');
      return;
    }

    if (captchaAnswer != (_captchaA + _captchaB)) {
      _showError('Invalid Captcha. Please try again.');
      _generateCaptcha();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepository();
      final user = await authRepo.login(studentId, password, 'student');

      if (user == null) {
        _showError('Invalid Student ID or password. Please try again.');
        _generateCaptcha();
      } else {
        if (mounted) Navigator.pushReplacementNamed(context, '/student');
      }
    } catch (e) {
      _showError('Login failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleStandardLogin() async {
    final username = _emailController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepository();
      final user = await authRepo.login(username, password, widget.role);

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid credentials. If it\'s your first time, please register.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      if (mounted) {
        if (widget.role == 'super_admin') {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/super-admin',
            (route) => false,
          );
          return;
        }

        if (widget.role == 'parent' && user['child_id'] != null) {
          // Special flow for parent - fetch student data first
          final supabase = Supabase.instance.client;
          final studentData = await supabase
              .from('students')
              .select()
              .eq('serial_id', user['child_id'])
              .maybeSingle();

          if (studentData != null) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/teacher',
              (route) => false,
              arguments: {'student': studentData, 'isParent': true},
            );
            return;
          }
        }

        final route = widget.role == 'teacher' ? '/teacher' : '/student';
        Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role == 'student') {
      return _buildStudentLoginScreen();
    } else {
      return _buildStandardLoginScreen();
    }
  }

  Widget _buildStudentLoginScreen() {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Center(child: Text('👨‍🎓', style: TextStyle(fontSize: 60))),
              const SizedBox(height: 24),
              Text('Student Login', style: Theme.of(context).textTheme.displayMedium, textAlign: TextAlign.center),
              const SizedBox(height: 48),
              _buildStudentLoginForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _studentIdController,
          decoration: const InputDecoration(
            labelText: 'Student ID',
            prefixIcon: Icon(Icons.badge_outlined),
            hintText: 'e.g. 001',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _studentPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
            hintText: 'Enter your password',
          ),
        ),
        const SizedBox(height: 24),
        const Text('CAPTCHA Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
              child: Text('$_captchaA + $_captchaB = ?', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(width: 16),
            Expanded(child: TextField(controller: _captchaController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Answer'))),
            IconButton(onPressed: _generateCaptcha, icon: const Icon(Icons.refresh)),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegistrationScreen(role: 'student')),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStandardLoginScreen() {
    final roleName = widget.role[0].toUpperCase() + widget.role.substring(1);

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('$roleName Login'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: widget.role == 'teacher' ? AppTheme.secondary : AppTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      widget.role == 'teacher' ? '👩‍🏫' : '🛡️',
                      style: const TextStyle(fontSize: 40)
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please sign in as $roleName to continue',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.role == 'teacher' ? AppTheme.secondary : AppTheme.primary,
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
