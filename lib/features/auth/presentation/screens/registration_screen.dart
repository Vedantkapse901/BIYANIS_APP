import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  final String role;

  const RegistrationScreen({super.key, required this.role});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0; // 0: Search, 1: OTP, 2: Password
  Map<String, dynamic>? _foundStudent;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _searchStudent() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showErrorSnackBar("Please enter your phone number.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepository();
      print('🔍 Searching for student with phone: $phone');
      final student = await authRepo.searchStudentByPhone(phone);
      setState(() => _isLoading = false);

      if (student != null) {
        print('✅ Student found: ${student['name']}');

        // Check if student is already registered (profile_id is not null)
        if (student['profile_id'] != null) {
          print('⚠️ Student already registered');
          _showSuccessDialog(
            "Already Registered",
            "Your account is already active. Please login with your Student ID and password.",
            onConfirm: () {
              Navigator.of(context).pushReplacementNamed('/role-selection');
            },
          );
          return;
        }

        setState(() {
          _foundStudent = student;
          _currentStep = 1;
        });
      } else {
        print('❌ No student found');
        _showErrorSnackBar("No student found with this phone number.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('⚠️ Error: $e');
      _showErrorSnackBar("Error: $e");
    }
  }

  void _verifyOtp() {
    if (_otpController.text == '1234') {
      setState(() => _currentStep = 2);
    } else {
      _showErrorSnackBar("Invalid OTP. Try 1234 for demo.");
    }
  }

  Future<void> _completeRegistration() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showErrorSnackBar("Please enter and confirm your password.");
      return;
    }

    if (password.length < 8) {
      _showErrorSnackBar("Password must be at least 8 characters.");
      return;
    }

    if (password != confirmPassword) {
      _showErrorSnackBar("Passwords do not match.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepository();
      await authRepo.activateStudentAccount(
        studentId: _foundStudent!['id'],
        email: _foundStudent!['email'] ?? "${_foundStudent!['serial_id']}@student.logbook",
        password: password,
        studentName: _foundStudent!['name'],
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Registration Complete! ✅'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, ${_foundStudent!['name']}!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                const Text('Your Student Login ID:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    border: Border.all(color: AppTheme.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _foundStudent!['serial_id'] ?? '---',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 3),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Use this Student ID and your password to login.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Registration failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessDialog(String title, String message, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(title: const Text('Student Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildStepIndicator(),
            const SizedBox(height: 32),
            if (_currentStep == 0) _buildSearchStep(),
            if (_currentStep == 1) _buildOtpStep(),
            if (_currentStep == 2) _buildPasswordStep(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepCircle(0, 'Select'),
        _stepLine(0),
        _stepCircle(1, 'Verify'),
        _stepLine(1),
        _stepCircle(2, 'Password'),
      ],
    );
  }

  Widget _stepCircle(int step, String label) {
    bool isActive = _currentStep >= step;
    return Column(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: isActive ? AppTheme.primary : Colors.grey.shade300,
          child: Text('${step + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 12)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? AppTheme.primary : Colors.grey)),
      ],
    );
  }

  Widget _stepLine(int afterStep) {
    bool isActive = _currentStep > afterStep;
    return Expanded(child: Container(height: 2, color: isActive ? AppTheme.primary : Colors.grey.shade300));
  }

  Widget _buildSearchStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Enter your registered phone number',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone),
            hintText: '10-digit number',
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _searchStudent,
          child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Find My Record'),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 0,
          color: AppTheme.primary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Student Found! ✓', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(_foundStudent?['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('Student ID: ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      Text(_foundStudent?['serial_id'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Full Student Details
                if (_foundStudent?['school_name'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.school, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(child: Text('${_foundStudent?['school_name']}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
                      ],
                    ),
                  ),
                if (_foundStudent?['board'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.book, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Board: ${_foundStudent?['board']} Standard: ${_foundStudent?['standard'] ?? ""}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
                      ],
                    ),
                  ),
                if (_foundStudent?['class_branch'] != null)
                  Row(
                    children: [
                      const Icon(Icons.group, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Class: ${_foundStudent?['class_branch']}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text('Enter OTP Code (Demo: 1234)', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(hintText: '000000', counterText: ''),
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _verifyOtp, child: const Text('Verify OTP')),
        const SizedBox(height: 12),
        TextButton(onPressed: () => setState(() => _currentStep = 0), child: const Text('Go Back')),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Create Your Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        const Text('Minimum 8 characters', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _completeRegistration,
          child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Complete Registration'),
        ),
      ],
    );
  }
}
