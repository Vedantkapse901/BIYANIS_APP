import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import 'registration_screen.dart';

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
    _generateCaptcha();
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
        // Login successful - user will stay logged in until logout
        if (mounted) Navigator.pushReplacementNamed(context, '/student');
      }
    } catch (e) {
      _showError('Login failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role != 'student') return _buildStandardLogin();

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


  Future<void> _handleStandardLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter both email and password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepository();
      final user = await authRepo.login(email, password, widget.role);

      if (user != null) {
        if (mounted) {
          final nextRoute = widget.role == 'super_admin' ? '/super-admin' : '/teacher';
          Navigator.pushReplacementNamed(context, nextRoute);
        }
      } else {
        _showError('Invalid credentials');
      }
    } catch (e) {
      _showError('Login failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildStandardLogin() {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('${widget.role.replaceAll('_', ' ').toUpperCase()} Login'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  widget.role == 'super_admin' ? '🔒' : '👨‍🏫',
                  style: const TextStyle(fontSize: 60),
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleStandardLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
