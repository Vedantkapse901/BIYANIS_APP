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

  // ===== LOGIN - USE SUPABASE AUTH + APPROVED LIST =====
  Future<Map<String, dynamic>?> login(String username, String password, String role) async {
    try {
      // 1. FOR STUDENT LOGIN - Check "Approved List" (students table)
      if (role == 'student') {
        final student = await _supabase
            .from('students')
            .select()
            .eq('serial_id', username)
            .eq('password', password) // Direct password check for approved list
            .maybeSingle();

        if (student == null) {
          print('❌ Student not in approved list or wrong password');
          return null;
        }

        // Save session locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', 'student');
        await prefs.setString('studentId', student['serial_id']);
        await prefs.setString('name', student['name'] ?? '');
        await prefs.setString('batch', student['batch'] ?? '');
        await prefs.setString('userId', student['id']); // Using students table ID as session ID

        return Map<String, dynamic>.from(student);
      }

      // 2. FOR PARENT LOGIN - Check Approved Parent List
      if (role == 'parent') {
        final parent = await _supabase
            .from('parents')
            .select()
            .eq('parent_id', username)
            .eq('password', password)
            .maybeSingle();

        if (parent == null) {
          print('❌ Parent not in approved list or wrong password');
          return null;
        }

        final childId = parent['child_id'];

        // Verify child is in approved list
        final student = await _supabase
            .from('students')
            .select()
            .eq('serial_id', childId)
            .maybeSingle();

        if (student == null) {
          print('❌ Ward ($childId) not in approved student list');
          return null;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', 'parent');
        await prefs.setString('childId', childId);
        await prefs.setString('name', parent['name'] ?? '');
        await prefs.setString('userId', parent['id']);

        return Map<String, dynamic>.from(parent);
      }

      // 3. FOR TEACHER LOGIN - Check Approved Profile List
      if (role == 'teacher') {
        final teacher = await _supabase
            .from('profiles')
            .select()
            .eq('username', username)
            .eq('pin', password) // Matches the 'pin' column we just updated via SQL
            .eq('role', 'teacher')
            .maybeSingle();

        if (teacher == null) {
          print('❌ Teacher not found or wrong password');
          return null;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', 'teacher');
        await prefs.setString('username', username);
        await prefs.setString('name', teacher['name'] ?? '');
        await prefs.setString('userId', teacher['id']);
        await prefs.setString('batch', teacher['batch'] ?? '');
        await prefs.setString('branch', teacher['branch'] ?? '');

        return Map<String, dynamic>.from(teacher);
      }

      // 4. FOR SUPER ADMIN - Hardcoded or special check
      if (role == 'super_admin') {
        if (username == 'superadmin' && password == 'admin123') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userRole', 'super_admin');
          return {'role': 'super_admin', 'name': 'Super Admin'};
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
