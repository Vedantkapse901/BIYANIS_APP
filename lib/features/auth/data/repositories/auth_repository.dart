import 'package:shared_preferences/shared_preferences.dart';
import '../../../../features/logbook/data/datasources/local_datasource.dart';
import '../../domain/registration_status.dart';

class AuthRepository {
  final LocalDataSource localDataSource = LocalDataSource();

  Future<RegistrationStatus> validateStudent(String phone) async {
    await localDataSource.initialize();
    final student = await localDataSource.getApprovedStudent(phone);

    if (student == null) {
      return RegistrationStatus.notAuthorized;
    }

    if (student['is_registered'] == true) {
      return RegistrationStatus.alreadyRegistered;
    }

    return RegistrationStatus.success;
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
    await localDataSource.initialize();
    
    String? studentBatch = batch;

    // Mark as registered in approved_students if it's a student and phone is provided
    if (role == 'student' && phone != null) {
      final approved = await localDataSource.getApprovedStudent(phone);
      if (approved != null) {
        studentBatch = approved['batch'] ?? batch;
      }
      await localDataSource.markStudentAsRegistered(phone);
    }

    final user = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'username': username,
      'password': password,
      'role': role,
      'phone': phone,
      'branch': branch,
      'batch': studentBatch,
      'wardName': wardName,
    };

    await localDataSource.saveUser(user);
  }

  Future<Map<String, dynamic>?> login(String username, String password, String role) async {
    await localDataSource.initialize();
    final users = await localDataSource.getAllUsers();
    
    try {
      final user = users.firstWhere(
        (u) => u['username'] == username && u['password'] == password && u['role'] == role
      );
      
      // Convert Map to Map<String, dynamic>
      final userData = Map<String, dynamic>.from(user);
      
      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userRole', role);
      await prefs.setString('username', username);
      await prefs.setString('name', user['name']);
      if (user['branch'] != null) await prefs.setString('branch', user['branch']);
      if (user['batch'] != null) await prefs.setString('batch', user['batch']);
      if (user['wardName'] != null) await prefs.setString('wardName', user['wardName']);

      return userData;
    } catch (e) {
      // Hardcoded login for Super Admin and Teacher
      if (role == 'super_admin' && username == 'superadmin' && password == 'admin123') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', 'super_admin');
        await prefs.setString('username', 'superadmin');
        await prefs.setString('name', 'Super Administrator');
        return {'role': 'super_admin', 'name': 'Super Administrator'};
      }

      if (role == 'teacher' && username == 'teacher' && password == 'password123') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', 'teacher');
        await prefs.setString('username', 'teacher');
        await prefs.setString('name', 'Teacher');
        return {'role': 'teacher', 'name': 'Teacher'};
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> recoverAccount({
    required String name,
    required String role,
    String? wardName,
  }) async {
    await localDataSource.initialize();
    final users = await localDataSource.getAllUsers();
    
    try {
      final user = users.firstWhere(
        (u) {
          final matchesName = u['name'].toString().toLowerCase() == name.toLowerCase();
          final matchesRole = u['role'] == role;
          if (role == 'parent') {
            final matchesWard = u['wardName'].toString().toLowerCase() == wardName?.toLowerCase();
            return matchesName && matchesRole && matchesWard;
          }
          return matchesName && matchesRole;
        }
      );
      return Map<String, dynamic>.from(user);
    } catch (e) {
      return null;
    }
  }

  Future<void> setUserRole(String role) async {
    // Store in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role);

    // Also store in Hive for logbook
    await localDataSource.initialize();
    await localDataSource.saveUserRole(role);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
