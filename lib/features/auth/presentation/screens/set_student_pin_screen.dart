import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';

class SetStudentPinScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const SetStudentPinScreen({super.key, required this.student});

  @override
  State<SetStudentPinScreen> createState() => _SetStudentPinScreenState();
}

class _SetStudentPinScreenState extends State<SetStudentPinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;

  Future<void> _setPin() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (pin.isEmpty || confirmPin.isEmpty) {
      _showError('Please enter and confirm your PIN');
      return;
    }

    if (pin.length != 4) {
      _showError('PIN must be exactly 4 digits');
      return;
    }

    if (pin != confirmPin) {
      _showError('PINs do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepository();
      await authRepo.setStudentPin(widget.student['serial_id'], pin);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('PIN Set Successfully! ✅'),
            content: const Text('Your 4-digit PIN has been set. You can now use it for quick login.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/student');
                },
                child: const Text('Continue to Dashboard'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showError('Failed to set PIN: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: AppTheme.bgLight,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Center(child: Text('🔐', style: TextStyle(fontSize: 60))),
                const SizedBox(height: 24),
                Text(
                  'Set Your PIN',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                Card(
                  elevation: 0,
                  color: AppTheme.primary.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppTheme.primary.withOpacity(0.1)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          widget.student['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${widget.student['serial_id']}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                const Text(
                  'Create a 4-digit PIN for quick login',
                  style: TextStyle(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                const Text('PIN', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _pinController,
                  obscureText: true,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, letterSpacing: 12),
                  decoration: const InputDecoration(
                    labelText: 'Enter 4-digit PIN',
                    counterText: '',
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),
                const Text('Confirm PIN', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmPinController,
                  obscureText: true,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, letterSpacing: 12),
                  decoration: const InputDecoration(
                    labelText: 'Re-enter PIN',
                    counterText: '',
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _setPin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Set PIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pushReplacementNamed('/student'),
                  child: const Text('Skip for now', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
