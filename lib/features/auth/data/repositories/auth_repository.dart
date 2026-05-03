import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../features/logbook/data/datasources/local_datasource.dart';
import '../../domain/registration_status.dart';

class AuthRepository {
  final LocalDataSource localDataSource = LocalDataSource();
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all students for the "Search/Select Student" screen
  Future<List<Map<String, dynamic>>> fetchAllStudents() async {
    final response = await _supabase
        .from('students')
        .select('id, serial_id, name, email, phone, school_name, board, class_branch')
        .order('serial_id');
    return List<Map<String, dynamic>>.from(response);
  }

  // Search student by phone for pre-fetching during registration
  Future<Map<String, dynamic>?> searchStudentByPhone(String phone) async {
    final response = await _supabase
        .from('students')
        .select('id, serial_id, name, email, phone, school_name, board, class_branch')
        .eq('phone', phone)
        .maybeSingle();
    return response;
  }

  // Verify PIN for quick login
  Future<Map<String, dynamic>?> loginWithPin(String serialId, String pin) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('serial_id', serialId)
        .eq('pin', pin)
        .eq('role', 'student')
        .maybeSingle();

    if (response != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', response['id']);
      await prefs.setString('userRole', 'student');
      await prefs.setString('name', response['name']);
      return response;
    }
    return null;
  }

  // Activate student account: Create auth user and profile from student data
  Future<void> activateStudentAccount({
    required String studentId,
    required String email,
    required String password,
    String? pin,
  }) async {
    // 1. Get student data from students table
    final student = await _supabase
        .from('students')
        .select()
        .eq('id', studentId)
        .single();

    // 2. Sign up with Supabase Auth
    final authResponse = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (authResponse.user == null) throw Exception('Activation failed: Could not create auth user');

    // 3. Create profile for the student with data from students table
    final profileId = authResponse.user!.id;
    await _supabase.from('profiles').insert({
      'id': profileId,
      'name': student['name'],
      'email': email,
      'phone': student['phone'],
      'role': 'student',
      'school_name': student['school_name'],
      'board': student['board'],
      'class_branch': student['class_branch'],
      'is_active': true,
    });

    // 4. Link profile to student
    await _supabase.from('students').update({
      'profile_id': profileId,
    }).eq('id', studentId);

    // 5. Local sync
    final updatedStudent = await _supabase.from('students').select().eq('id', studentId).single();
    await localDataSource.initialize();
    await localDataSource.saveUser(Map<String, dynamic>.from(updatedStudent));
  }

  Future<void> registerUser({
    required String name,
    required String username, // Using email for Supabase Auth
    required String password,
    required String role,
    String? phone,
    String? branch,
    String? batch,
    String? wardName,
  }) async {
    // 1. Sign up with Supabase Auth
    final authResponse = await _supabase.auth.signUp(
      email: username.contains('@') ? username : '$username@student.logbook',
      password: password,
      data: {
        'name': name,
        'role': role,
      },
    );

    if (authResponse.user == null) throw Exception('Registration failed');

    // 2. Create profile in public.profiles
    await _supabase.from('profiles').upsert({
      'id': authResponse.user!.id,
      'name': name,
      'email': authResponse.user!.email,
      'role': role,
      'phone': phone,
    });

    // 3. Local sync
    await localDataSource.initialize();
    final user = {
      'id': authResponse.user!.id,
      'name': name,
      'username': username,
      'role': role,
      'phone': phone,
      'batch': batch,
    };
    await localDataSource.saveUser(user);
  }

  Future<Map<String, dynamic>?> login(String username, String password, String role) async {
    try {
      String email = username;

      // For student login with serial_id, look up the email from students table
      if (role == 'student' && !username.contains('@')) {
        final student = await _supabase
            .from('students')
            .select('email')
            .eq('serial_id', username)
            .maybeSingle();

        if (student != null && student['email'] != null) {
          email = student['email'];
        } else {
          return null; // Student not found
        }
      } else if (!username.contains('@')) {
        email = '$username@student.logbook';
      }

      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', authResponse.user!.id)
            .single();

        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', role);
        await prefs.setString('userId', authResponse.user!.id);
        await prefs.setString('name', profile['name']);

        return Map<String, dynamic>.from(profile);
      }
      return null;
    } catch (e) {
      // Fallback for hardcoded admin during migration
      if (role == 'super_admin' && username == 'superadmin' && password == 'admin123') {
        return {'role': 'super_admin', 'name': 'Super Administrator'};
      }
      return null;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
