import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
<<<<<<< HEAD

class RegistrationScreen extends ConsumerStatefulWidget {
  final String role;
=======
import '../../domain/registration_status.dart';
import '../widgets/credential_display_dialog.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  final String role; // 'student' or 'parent'
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1

  const RegistrationScreen({super.key, required this.role});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
<<<<<<< HEAD
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _searchController = TextEditingController();

  int _currentStep = 0; // 0: Search/Select, 1: OTP, 2: Set Password & PIN
  Map<String, dynamic>? _foundStudent;
  bool _isLoading = false;

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _filteredStudents = [];

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _searchController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndShowStudentList() async {
    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepository();
      final students = await authRepo.fetchAllStudents();
      setState(() {
        _allStudents = students;
        _filteredStudents = students;
        _isLoading = false;
      });
      _showStudentSelectionDialog();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Failed to fetch students: $e");
    }
  }

  void _showStudentSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Your Name'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search by name or ID...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) {
                    setDialogState(() {
                      _filteredStudents = _allStudents.where((s) {
                        final name = s['name'].toString().toLowerCase();
                        final id = s['serial_id']?.toString().toLowerCase() ?? '';
                        return name.contains(val.toLowerCase()) || id.contains(val.toLowerCase());
                      }).toList();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _filteredStudents.isEmpty
                      ? const Center(child: Text('No students found'))
                      : ListView.separated(
                          itemCount: _filteredStudents.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];
                            return ListTile(
                              title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('ID: ${student['serial_id'] ?? "N/A"} • Batch: ${student['batch'] ?? "N/A"}'),
                              trailing: const Icon(Icons.chevron_right, color: AppTheme.primary),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _foundStudent = student;
                                  _currentStep = 1;
                                });
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      ),
    );
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

      print('📱 Search result: $student');

      if (student != null) {
        print('✅ Student found: ${student['name']}');
        setState(() {
          _foundStudent = student;
          _currentStep = 1; // Move to OTP step
        });
      } else {
        print('❌ No student found');
        _showErrorSnackBar("No student found with this phone number. Please contact your center.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('⚠️ Error searching student: $e');
      _showErrorSnackBar("Error: $e");
    }
  }

  void _verifyOtp() {
    // For now, demo OTP is 1234
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

      // Activate account with password (PIN not required)
      await authRepo.activateStudentAccount(
        studentId: _foundStudent!['id'],
        email: _foundStudent!['email'] ?? "${_foundStudent!['serial_id']}@student.logbook",
        password: password,
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
                const Text('Use this Student ID and your password to login. You will remain logged in until you logout.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Go to Login'),
              ),
            ],
=======
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
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
          ),
        );
      }
    } catch (e) {
<<<<<<< HEAD
      _showErrorSnackBar("Registration failed: $e");
=======
      if (mounted) {
        _showErrorSnackBar('Registration failed: $e');
      }
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
<<<<<<< HEAD
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary))),
        ],
=======
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
            if (_currentStep == 2) _buildSetPinStep(),
          ],
=======
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
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
        ),
      ),
    );
  }
<<<<<<< HEAD

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
          'Enter your registered phone number to find your student record.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Registered Phone Number',
            prefixIcon: Icon(Icons.phone),
            hintText: 'Enter your 10-digit number',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withOpacity(0.1))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Student Found! ✓', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(_foundStudent?['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('Student Login ID: ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(_foundStudent?['serial_id'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Phone', _foundStudent?['phone'] ?? 'N/A'),
                _buildDetailRow('Email', _foundStudent?['email'] ?? 'N/A'),
                _buildDetailRow('School', _foundStudent?['school_name'] ?? 'N/A'),
                _buildDetailRow('Board', _foundStudent?['board'] ?? 'N/A'),
                _buildDetailRow('Class', _foundStudent?['class_branch'] ?? 'N/A'),
                _buildDetailRow('Batch', _foundStudent?['batch'] ?? 'N/A'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP sent to your registered phone number'), backgroundColor: Colors.green)
            );
          },
          icon: const Icon(Icons.sms_outlined),
          label: const Text('Send OTP'),
        ),
        const SizedBox(height: 24),
        const Text('Enter OTP Code', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            hintText: '000000',
            helperText: 'Demo OTP: 1234',
            counterText: '',
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _verifyOtp, child: const Text('Verify OTP')),
        const SizedBox(height: 12),
        TextButton(onPressed: () => setState(() => _currentStep = 0), child: const Text('Different Phone? Go Back')),
      ],
    );
  }

  Widget _buildSetPinStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Create Your Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
        const SizedBox(height: 24),

        const Text('Enter a strong password (minimum 8 characters)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
            hintText: 'At least 8 characters',
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
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Complete Registration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }
=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
}
