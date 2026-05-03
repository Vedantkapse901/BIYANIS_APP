import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/registration_status.dart';
import '../widgets/credential_display_dialog.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  final String role; // 'student' or 'parent'

  const RegistrationScreen({super.key, required this.role});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _wardNameController = TextEditingController();
  
  String _selectedBranch = 'Mira Road';
  String _selectedBatch = 'ICSE 9';

  final List<String> _branches = ['Mira Road', 'Bhayander', 'Kandivali'];
  final List<String> _batches = ['ICSE 9', 'ICSE 10', 'CBSE 9', 'CBSE 10'];

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _wardNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final wardName = widget.role == 'parent' ? _wardNameController.text.trim() : null;
      
      final authRepo = AuthRepository();

      // NEW: Validation Logic before registration
      if (widget.role == 'student') {
        final status = await authRepo.validateStudent(phone);
        
        if (status == RegistrationStatus.notAuthorized) {
          if (mounted) {
            _showErrorSnackBar("You are not authorized to register. Contact your class admin.");
          }
          return;
        } else if (status == RegistrationStatus.alreadyRegistered) {
          if (mounted) {
            _showErrorSnackBar("You are already registered. Please login.");
          }
          return;
        }
      }

      // Generate credentials: name_random number
      final randomNum1 = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
      final randomNum2 = (1000 + ((DateTime.now().millisecondsSinceEpoch + 7) % 9000)).toString();
      final namePrefix = name.toLowerCase().split(' ')[0];
      final username = "${namePrefix}_$randomNum1";
      final password = "pass_$randomNum2"; // Different from username

      // Save user to "database" (mocked in repository)
      await authRepo.registerUser(
        name: name,
        username: username,
        password: password,
        role: widget.role,
        phone: phone,
        branch: _selectedBranch,
        batch: _selectedBatch,
        wardName: wardName,
      );

      if (mounted) {
        // Show credentials to user
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => CredentialDisplayDialog(
            username: username,
            password: password,
            role: widget.role,
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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.role == 'student' ? 'Student Registration' : 'Parent Registration';
    
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Complete your profile',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: widget.role == 'student' ? 'Full Name' : 'Parent Name',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: 'e.g. 1234567890',
                ),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter phone number';
                  if (v.length < 10) return 'Enter a valid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              if (widget.role == 'parent') ...[
                TextFormField(
                  controller: _wardNameController,
                  decoration: const InputDecoration(
                    labelText: 'Ward\'s Full Name',
                    prefixIcon: const Icon(Icons.child_care),
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter ward\'s name' : null,
                ),
                const SizedBox(height: 16),
              ],

              DropdownButtonFormField<String>(
                value: _selectedBranch,
                decoration: const InputDecoration(
                  labelText: 'Branch',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => setState(() => _selectedBranch = v!),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedBatch,
                decoration: const InputDecoration(
                  labelText: 'Batch',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: _batches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => setState(() => _selectedBatch = v!),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.role == 'student' ? AppTheme.primary : AppTheme.secondary,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Register & Generate Credentials'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
