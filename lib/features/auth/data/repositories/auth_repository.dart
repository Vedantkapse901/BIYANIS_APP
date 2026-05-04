import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../features/logbook/data/datasources/local_datasource.dart';
import '../../domain/registration_status.dart';

class AuthRepository {
  late final SupabaseClient _supabase = Supabase.instance.client;
  final LocalDataSource localDataSource = LocalDataSource();

  // ===== REGISTRATION - READ FROM STUDENTS TABLE =====
  Future<RegistrationStatus> validateStudent(String phone) async {
    try {
      final response = await _supabase
          .from('students')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      if (response == null) {
        return RegistrationStatus.notAuthorized;
      }

      if (response['is_registered'] == true) {
        return RegistrationStatus.alreadyRegistered;
      }

      return RegistrationStatus.success;
    } catch (e) {
      return RegistrationStatus.notAuthorized;
    }
  }

  // Search student by phone from STUDENTS table
  Future<Map<String, dynamic>?> searchStudentByPhone(String phone) async {
    try {
      final response = await _supabase
          .from('students')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      return response != null ? Map<String, dynamic>.from(response) : null;
    } catch (e) {
      print('Error searching student: $e');
      return null;
    }
  }

  // Activate student account - Use Supabase Auth
  Future<void> activateStudentAccount({
    required String studentId,
    required String email,
    required String password,
    String? studentName,
  }) async {
    try {
      // Create Supabase Auth user
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        // Create profile in profiles table (using Supabase Auth user ID)
        await _supabase.from('profiles').upsert({
          'id': authResponse.user!.id,
          'name': studentName ?? studentId,
          'email': email,
          'role': 'student',
          'is_active': true,
        });

        // Link profile to student (update profile_id in students table)
        await _supabase
            .from('students')
            .update({'profile_id': authResponse.user!.id})
            .eq('id', studentId);
      } else {
        throw Exception('Failed to create auth user');
      }
    } catch (e) {
      throw Exception('Failed to activate account: $e');
    }
  }

  Future<void> registerUser({
    required String name,
    required String username,
    required String password,
    required String role,
    String? phone,
    String? branch,
    String? batch,
    String? wardName,
  }) async {
    try {
      await _supabase.from('profiles').upsert({
        'username': username,
        'password': password,
        'name': name,
        'email': username.contains('@') ? username : '$username@student.logbook',
        'role': role,
        'phone': phone,
        'branch': branch,
        'batch': batch,
        'ward_name': wardName,
        'is_registered': true,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // ===== LOGIN - USE SUPABASE AUTH =====
  Future<Map<String, dynamic>?> login(String username, String password, String role) async {
    try {
      // For STUDENT login - use serial_id (001, 002, etc.)
      if (role == 'student') {
        // Get student by serial_id
        final student = await _supabase
            .from('students')
            .select()
            .eq('serial_id', username)
            .maybeSingle();

        if (student == null) {
          return null;
        }

        final email = student['email'] ?? '${student['serial_id']}@student.logbook';

        // Authenticate with Supabase Auth
        final authResponse = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (authResponse.user != null) {
          // Get profile data
          final profile = await _supabase
              .from('profiles')
              .select()
              .eq('id', authResponse.user!.id)
              .maybeSingle();

          if (profile != null) {
            final userData = Map<String, dynamic>.from(profile);

            // Save session
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userRole', role);
            await prefs.setString('studentId', student['serial_id'] ?? username);
            await prefs.setString('email', email);
            await prefs.setString('userId', authResponse.user!.id);

            // Save student details
            await prefs.setString('name', student['name'] ?? '');
            await prefs.setString('batch', student['batch'] ?? '');
            if (student['branch'] != null) {
              await prefs.setString('branch', student['branch']);
            }

            return userData;
          }
        }
        return null;
      }

      // For OTHER ROLES - use email/username with Supabase Auth
      final authResponse = await _supabase.auth.signInWithPassword(
        email: username,
        password: password,
      );

      if (authResponse.user != null) {
        // Get profile data
        final response = await _supabase
            .from('profiles')
            .select()
            .eq('id', authResponse.user!.id)
            .eq('role', role)
            .maybeSingle();

        if (response != null) {
          final userData = Map<String, dynamic>.from(response);

          // Save session
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userRole', role);
          await prefs.setString('username', username);
          await prefs.setString('name', response['name'] ?? '');
          await prefs.setString('userId', authResponse.user!.id);
          if (response['branch'] != null) await prefs.setString('branch', response['branch']);
          if (response['batch'] != null) await prefs.setString('batch', response['batch']);

          return userData;
        }
      }

      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> recoverAccount({
    required String name,
    required String role,
    String? wardName,
  }) async {
    try {
      var query = _supabase
          .from('profiles')
          .select()
          .eq('name', name)
          .eq('role', role);

      if (role == 'parent' && wardName != null) {
        query = query.eq('ward_name', wardName);
      }

      final response = await query.maybeSingle();
      return response != null ? Map<String, dynamic>.from(response) : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> setUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role);
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  Future<bool> isLoggedIn() async {
    final role = await getUserRole();
    return role != null;
  }

  Future<void> logout() async {
    try {
      // Sign out from Supabase Auth
      await _supabase.auth.signOut();
    } catch (e) {
      print('Supabase logout error: $e');
    }

    // Clear local session
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
