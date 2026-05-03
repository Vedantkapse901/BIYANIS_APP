import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import 'super_admin_dashboard.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
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
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SuperAdminDashboard()),
            (route) => false,
          );
          return;
        }

        final route = widget.role == 'teacher' ? '/teacher' : '/student';
        // For parent, they also see the student dashboard but read-only (handled in dashboard)
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

  @override
  Widget build(BuildContext context) {
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
              // Logo
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: widget.role == 'student' 
                      ? AppTheme.primaryGradient 
                      : widget.role == 'teacher' 
                        ? AppTheme.redGradient 
                        : widget.role == 'super_admin'
                          ? AppTheme.primaryGradient
                          : AppTheme.mixGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      widget.role == 'student' 
                        ? '👨‍🎓' 
                        : widget.role == 'teacher' 
                          ? '👩‍🏫' 
                          : widget.role == 'super_admin'
                            ? '🛡️'
                            : '👨‍👩‍👦', 
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

              if (widget.role != 'teacher' && widget.role != 'super_admin') ...[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen(role: widget.role),
                      ),
                    );
                  },
                  child: const Text('Forgot Credentials?', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ),
              ],
              
              if (widget.role != 'teacher' && widget.role != 'super_admin') ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('First time here?'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RegistrationScreen(role: widget.role),
                          ),
                        );
                      },
                      child: Text('Register now', style: TextStyle(color: widget.role == 'parent' ? Colors.orange : AppTheme.primary)),
                    ),
                  ],
                ),
              ],
              
              if (widget.role == 'super_admin') ...[
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Use "superadmin" and "admin123"',
                    style: TextStyle(color: AppTheme.textLight, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
