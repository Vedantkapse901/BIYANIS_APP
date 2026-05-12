import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final supabase = Supabase.instance.client;
  int _currentIndex = 0;
  bool _isLoading = false;
  String _importType = 'Students'; // 'Students', 'Parents', or 'Teachers'
  List<Map<String, dynamic>> _previewData = [];

  // For Management
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _allParents = [];
  List<Map<String, dynamic>> _allTeachers = [];

  String _searchQuery = '';
  String _studentSearchQuery = '';
  String _parentSearchQuery = '';
  String _teacherSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadAllUsers(),
      _loadAllStudents(),
      _loadAllParents(),
      _loadAllTeachers(),
    ]);
  }

  Future<void> _loadAllUsers() async {
    try {
      print('📡 Fetching all profiles...');
      final response = await supabase.from('profiles').select().order('name');
      print('✅ Fetched ${(response as List).length} profiles');
      setState(() {
        _allUsers = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('❌ Error loading users: $e');
      try {
        final response = await supabase.from('profiles').select();
        setState(() {
          _allUsers = List<Map<String, dynamic>>.from(response);
        });
      } catch (_) {}
    }
  }

  Future<void> _loadAllStudents() async {
    try {
      print('📡 Fetching all students...');
      // Use * to fetch all available columns to avoid "column not found" errors
      final response = await supabase
          .from('students')
          .select('*')
          .order('name', ascending: true);

      print('✅ Fetched ${(response as List).length} students');
      setState(() {
        _allStudents = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('❌ Error loading students: $e');
      // Fallback for older schema if ordering by name fails
      try {
        final response = await supabase.from('students').select('*');
        setState(() {
          _allStudents = List<Map<String, dynamic>>.from(response);
        });
      } catch (e2) {
        print('❌ Final fallback failed: $e2');
      }
    }
  }

  Future<void> _loadAllParents() async {
    try {
      print('📡 Fetching all parents...');
      final response = await supabase.from('parents').select().order('parent_id');
      print('✅ Fetched ${(response as List).length} parents');
      setState(() {
        _allParents = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('❌ Error loading parents: $e');
      try {
        final response = await supabase.from('parents').select();
        setState(() {
          _allParents = List<Map<String, dynamic>>.from(response);
        });
      } catch (_) {}
    }
  }

  Future<void> _loadAllTeachers() async {
    try {
      print('📡 Fetching all teachers...');
      final response = await supabase.from('teachers').select().order('username');
      print('✅ Fetched ${(response as List).length} teachers');
      setState(() {
        _allTeachers = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('❌ Error loading teachers: $e');
      try {
        final response = await supabase.from('teachers').select();
        setState(() {
          _allTeachers = List<Map<String, dynamic>>.from(response);
        });
      } catch (_) {}
    }
  }

  void _showAddEditTeacherDialog([Map<String, dynamic>? teacher]) {
    final nameController = TextEditingController(text: teacher?['name']);
    final usernameController = TextEditingController(text: teacher?['username']);
    final pinController = TextEditingController(text: teacher?['pin'] ?? 'teacher@1234');
    final batchController = TextEditingController(text: teacher?['batch']);
    final subjectController = TextEditingController(text: teacher?['subject']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(teacher == null ? 'Add Teacher' : 'Edit Teacher'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
              TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username (Login ID)')),
              TextField(controller: pinController, decoration: const InputDecoration(labelText: 'Password/PIN')),
              TextField(controller: batchController, decoration: const InputDecoration(labelText: 'Batch (e.g. ICSE 10)')),
              TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject (Empty for General)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final data = {
                  'name': nameController.text.trim(),
                  'username': usernameController.text.trim(),
                  'pin': pinController.text.trim(),
                  'batch': batchController.text.trim(),
                  'subject': subjectController.text.trim().isEmpty ? null : subjectController.text.trim(),
                  'updated_at': DateTime.now().toIso8601String(),
                };

                if (teacher == null) {
                  await supabase.from('teachers').insert(data);
                } else {
                  await supabase.from('teachers').update(data).eq('id', teacher['id']);
                }

                if (mounted) {
                  Navigator.pop(context);
                  _loadAllTeachers();
                  _showMessage(teacher == null ? 'Teacher added successfully' : 'Teacher updated successfully');
                }
              } catch (e) {
                _showMessage('Operation failed: $e', isError: true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTeacher(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: const Text('Are you sure? This will remove this teacher account.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await supabase.from('teachers').delete().eq('id', id);
        _loadAllTeachers();
        _showMessage('Teacher deleted');
      } catch (e) {
        _showMessage('Delete failed: $e', isError: true);
      }
    }
  }

  void _showAddEditStudentDialog([Map<String, dynamic>? student]) {
    final nameController = TextEditingController(text: student?['name']);
    final studentIdController = TextEditingController(text: student?['student_id']);
    final passwordController = TextEditingController(text: student?['password']);
    final boardController = TextEditingController(text: student?['board']);
    final standardController = TextEditingController(text: student?['standard']);
    final batchController = TextEditingController(text: student?['batch']);
    final schoolNameController = TextEditingController(text: student?['school_name']);
    final classBranchController = TextEditingController(text: student?['class_branch']);
    final emailController = TextEditingController(text: student?['email']);
    final phoneController = TextEditingController(text: student?['phone']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student == null ? 'Add Student' : 'Edit Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: studentIdController, decoration: const InputDecoration(labelText: 'Student ID (e.g. 001)')),
              TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password')),
              TextField(controller: boardController, decoration: const InputDecoration(labelText: 'Board (ICSE/CBSE)')),
              TextField(controller: standardController, decoration: const InputDecoration(labelText: 'Standard (9/10)')),
              TextField(controller: batchController, decoration: const InputDecoration(labelText: 'Batch (e.g. ICSE 10)')),
              TextField(controller: schoolNameController, decoration: const InputDecoration(labelText: 'School Name')),
              TextField(controller: classBranchController, decoration: const InputDecoration(labelText: 'Class Branch')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final data = {
                  'name': nameController.text.trim(),
                  'serial_id': studentIdController.text.trim(), // Reverted
                  'password': passwordController.text.trim(),
                  'board': boardController.text.trim(),
                  'standard': standardController.text.trim(),
                  'batch': batchController.text.trim(),
                  'school_name': schoolNameController.text.trim(),
                  'class_branch': classBranchController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'updated_at': DateTime.now().toIso8601String(),
                };

                if (student == null) {
                  // Use upsert instead of insert to be safer against duplicates
                  await supabase.from('students').upsert(data, onConflict: 'serial_id'); // Reverted
                } else {
                  await supabase.from('students').update(data).eq('id', student['id'] ?? '');
                }

                if (mounted) {
                  Navigator.pop(context);
                  _loadAllStudents();
                  _showMessage(student == null ? 'Student added successfully' : 'Student updated successfully');
                }
              } catch (e) {
                _showMessage('Operation failed: $e', isError: true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddEditParentDialog([Map<String, dynamic>? parent]) {
    final nameController = TextEditingController(text: parent?['name']);
    final parentIdController = TextEditingController(text: parent?['parent_id']);
    final passwordController = TextEditingController(text: parent?['password']);
    final childIdController = TextEditingController(text: parent?['child_id']);
    final emailController = TextEditingController(text: parent?['email']);
    final phoneController = TextEditingController(text: parent?['phone']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(parent == null ? 'Add Parent' : 'Edit Parent'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Parent Name')),
              TextField(controller: parentIdController, decoration: const InputDecoration(labelText: 'Parent ID (Login ID)')),
              TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password')),
              TextField(controller: childIdController, decoration: const InputDecoration(labelText: 'Child ID (Student ID)')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final data = {
                  'name': nameController.text.trim(),
                  'parent_id': parentIdController.text.trim(),
                  'password': passwordController.text.trim(),
                  'child_id': childIdController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'updated_at': DateTime.now().toIso8601String(),
                };

                if (parent == null) {
                  await supabase.from('parents').upsert(data, onConflict: 'parent_id');
                } else {
                  await supabase.from('parents').update(data).eq('id', parent['id'] ?? '');
                }

                if (mounted) {
                  Navigator.pop(context);
                  _loadAllParents();
                  _showMessage(parent == null ? 'Parent added successfully' : 'Parent updated successfully');
                }
              } catch (e) {
                _showMessage('Operation failed: $e', isError: true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStudent(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure? This will remove them from the approved list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await supabase.from('students').delete().eq('id', id);
        _loadAllStudents();
        _showMessage('Student deleted');
      } catch (e) {
        _showMessage('Delete failed: $e', isError: true);
      }
    }
  }

  Future<void> _deleteParent(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Parent'),
        content: const Text('Are you sure? This will remove them from the approved list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await supabase.from('parents').delete().eq('id', id);
        _loadAllParents();
        _showMessage('Parent deleted');
      } catch (e) {
        _showMessage('Delete failed: $e', isError: true);
      }
    }
  }

  Future<void> _pickAndParseFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
      );

      if (result != null) {
        setState(() => _isLoading = true);
        File file = File(result.files.single.path!);
        String extension = result.files.single.extension ?? '';

        List<Map<String, dynamic>> parsedData = [];

        if (extension == 'csv') {
          final input = file.openRead();
          final fields = await input
              .transform(utf8.decoder)
              .transform(const CsvToListConverter())
              .toList();
          if (_importType == 'Students') {
            parsedData = _processRawStudentList(fields);
          } else if (_importType == 'Parents') {
            parsedData = _processRawParentList(fields);
          } else {
            parsedData = _processRawTeacherList(fields);
          }
        } else {
          var bytes = file.readAsBytesSync();
          var excel = excel_lib.Excel.decodeBytes(bytes);
          for (var table in excel.tables.keys) {
            var rows = excel.tables[table]!.rows;
            List<List<dynamic>> rawList = rows.map((row) => row.map((cell) => cell?.value).toList()).toList();
            if (_importType == 'Students') {
              parsedData = _processRawStudentList(rawList);
            } else if (_importType == 'Parents') {
              parsedData = _processRawParentList(rawList);
            } else {
              parsedData = _processRawTeacherList(rawList);
            }
            break;
          }
        }

        setState(() {
          _previewData = parsedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Error picking file: $e', isError: true);
    }
  }

  List<Map<String, dynamic>> _processRawStudentList(List<List<dynamic>> rawData) {
    if (rawData.isEmpty) return [];

    int startIndex = 0;
    // Indices mapping
    int nameIdx = 0;
    int phoneIdx = 1;
    int emailIdx = 2;
    int batchIdx = 3;
    int passIdx = 4;
    int sidIdx = 5;

    // Detect headers
    final firstRow = rawData[0].map((e) => e.toString().toLowerCase()).toList();
    bool hasHeader = false;

    for (int i = 0; i < firstRow.length; i++) {
      final cell = firstRow[i];
      if (cell.contains('name')) { nameIdx = i; hasHeader = true; }
      else if (cell.contains('phone')) { phoneIdx = i; hasHeader = true; }
      else if (cell.contains('email')) { emailIdx = i; hasHeader = true; }
      else if (cell.contains('batch')) { batchIdx = i; hasHeader = true; }
      else if (cell.contains('pass')) { passIdx = i; hasHeader = true; }
      else if (cell.contains('id')) { sidIdx = i; hasHeader = true; }
    }

    if (hasHeader) startIndex = 1;

    List<Map<String, dynamic>> students = [];
    for (var i = startIndex; i < rawData.length; i++) {
      var row = rawData[i];
      if (row.isEmpty) continue;

      String name = row.length > nameIdx ? row[nameIdx]?.toString().trim() ?? '' : '';
      if (name.isEmpty) continue;

      String phone = row.length > phoneIdx ? row[phoneIdx]?.toString().trim() ?? '' : '';
      String email = row.length > emailIdx ? row[emailIdx]?.toString().trim() ?? '' : '';
      String batchValue = row.length > batchIdx ? row[batchIdx]?.toString().trim() ?? 'ICSE 10' : 'ICSE 10';
      String password = row.length > passIdx ? row[passIdx]?.toString().trim() ?? '123456' : '123456';
      String studentId = row.length > sidIdx ? row[sidIdx]?.toString().trim() ?? '' : '';

      // Fallback: if studentId is empty but email exists, use email prefix or something
      if (studentId.isEmpty && email.isNotEmpty) {
        studentId = email.split('@')[0];
      }

      students.add({
        'name': name,
        'phone': phone,
        'email': email,
        'batch': batchValue,
        'password': password,
        'serial_id': studentId, // Changed back to serial_id
      });
    }
    return students;
  }

  List<Map<String, dynamic>> _processRawParentList(List<List<dynamic>> rawData) {
    if (rawData.isEmpty) return [];

    int startIndex = 0;
    if (rawData[0].any((cell) =>
        cell.toString().toLowerCase().contains('name') ||
        cell.toString().toLowerCase().contains('child'))) {
      startIndex = 1;
    }

    List<Map<String, dynamic>> parents = [];
    for (var i = startIndex; i < rawData.length; i++) {
      var row = rawData[i];
      if (row.length < 2) continue;

      String name = row[0]?.toString().trim() ?? '';
      String parentId = row[1]?.toString().trim() ?? '';
      String password = row.length > 2 ? row[2]?.toString().trim() ?? '123456' : '123456';
      String childId = row.length > 3 ? row[3]?.toString().trim() ?? '' : '';
      String email = row.length > 4 ? row[4]?.toString().trim() ?? '' : '';
      String phone = row.length > 5 ? row[5]?.toString().trim() ?? '' : '';

      parents.add({
        'name': name,
        'parent_id': parentId,
        'password': password,
        'child_id': childId,
        'email': email,
        'phone': phone,
      });
    }
    return parents;
  }

  List<Map<String, dynamic>> _processRawTeacherList(List<List<dynamic>> rawData) {
    if (rawData.isEmpty) return [];

    int startIndex = 0;
    if (rawData[0].any((cell) =>
        cell.toString().toLowerCase().contains('username') ||
        cell.toString().toLowerCase().contains('batch'))) {
      startIndex = 1;
    }

    List<Map<String, dynamic>> teachers = [];
    for (var i = startIndex; i < rawData.length; i++) {
      var row = rawData[i];
      if (row.length < 2) continue;

      String username = row[0]?.toString().trim() ?? '';
      String batch = row.length > 1 ? row[1]?.toString().trim() ?? '' : '';
      String subject = row.length > 2 ? row[2]?.toString().trim() ?? '' : '';
      String pin = row.length > 3 ? row[3]?.toString().trim() ?? 'teacher@1234' : 'teacher@1234';
      String name = row.length > 4 ? row[4]?.toString().trim() ?? '' : '';

      teachers.add({
        'username': username,
        'batch': batch,
        'subject': subject.isEmpty ? null : subject,
        'pin': pin,
        'name': name.isEmpty ? username.replaceAll('_', ' ').toUpperCase() : name,
      });
    }
    return teachers;
  }

  Future<void> _uploadToDatabase() async {
    if (_previewData.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      if (_importType == 'Students') {
        await supabase.from('students').upsert(_previewData, onConflict: 'student_id');
        _showMessage('Successfully uploaded ${_previewData.length} students.');
        _loadAllStudents();
      } else if (_importType == 'Parents') {
        await supabase.from('parents').upsert(_previewData, onConflict: 'parent_id');
        _showMessage('Successfully uploaded ${_previewData.length} parents.');
        _loadAllParents();
      } else {
        await supabase.from('teachers').upsert(_previewData, onConflict: 'username');
        _showMessage('Successfully uploaded ${_previewData.length} teachers.');
        _loadAllTeachers();
      }

      setState(() {
        _previewData = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Upload failed: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Bulk Import', 'Approved Students', 'Approved Parents', 'Approved Teachers', 'User Profiles'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthRepository().logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/role-selection');
              }
            },
          )
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildImportTab(),
          _buildStudentManagementTab(),
          _buildParentManagementTab(),
          _buildTeacherManagementTab(),
          _buildUserManagementTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: 'Import'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: 'Parents'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Teachers'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        ],
      ),
    );
  }

  Widget _buildStudentManagementTab() {
    final filteredStudents = _allStudents.where((s) {
      final query = _studentSearchQuery.toLowerCase();
      final sid = (s['student_id'] ?? '').toString().toLowerCase();
      return (s['name'] ?? '').toString().toLowerCase().contains(query) ||
          sid.contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _studentSearchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Search student ID or name...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                onPressed: () => _showAddEditStudentDialog(),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredStudents.isEmpty
            ? const Center(child: Text('No students in approved list.'))
            : ListView.builder(
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = filteredStudents[index];
                  return ListTile(
                    title: Text(student['name'] ?? 'No Name'),
                    subtitle: Text('ID: ${student['serial_id']} | Pass: ${student['password']}\n${student['batch']}'), // Changed back to serial_id
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showAddEditStudentDialog(student)),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () {
                            final id = student['id']?.toString();
                            if (id != null) _deleteStudent(id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildParentManagementTab() {
    final filteredParents = _allParents.where((p) {
      final query = _parentSearchQuery.toLowerCase();
      return (p['name'] ?? '').toString().toLowerCase().contains(query) ||
          (p['parent_id'] ?? '').toString().toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _parentSearchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Search parent ID or name...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                onPressed: () => _showAddEditParentDialog(),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredParents.isEmpty
            ? const Center(child: Text('No parents in approved list.'))
            : ListView.builder(
                itemCount: filteredParents.length,
                itemBuilder: (context, index) {
                  final parent = filteredParents[index];
                  return ListTile(
                    title: Text(parent['name'] ?? 'No Name'),
                    subtitle: Text('Parent ID: ${parent['parent_id']} | Pass: ${parent['password']}\nChild: ${parent['child_id']}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showAddEditParentDialog(parent)),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () {
                            final id = parent['id']?.toString();
                            if (id != null) _deleteParent(id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildTeacherManagementTab() {
    final filteredTeachers = _allTeachers.where((t) {
      final query = _teacherSearchQuery.toLowerCase();
      return (t['name'] ?? '').toString().toLowerCase().contains(query) ||
          (t['username'] ?? '').toString().toLowerCase().contains(query) ||
          (t['subject'] ?? '').toString().toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _teacherSearchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Search teacher, username or subject...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                onPressed: () => _showAddEditTeacherDialog(),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredTeachers.isEmpty
            ? const Center(child: Text('No teachers in approved list.'))
            : ListView.builder(
                itemCount: filteredTeachers.length,
                itemBuilder: (context, index) {
                  final teacher = filteredTeachers[index];
                  return ListTile(
                    title: Text(teacher['name'] ?? 'No Name'),
                    subtitle: Text('ID: ${teacher['username']} | Pass: ${teacher['pin']}\nBatch: ${teacher['batch']} | Subject: ${teacher['subject'] ?? "ALL"}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showAddEditTeacherDialog(teacher)),
                        IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _deleteTeacher(teacher['id'])),
                      ],
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildImportTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Import $_importType',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<String>(
                        value: _importType,
                        onChanged: (val) => setState(() {
                          _importType = val!;
                          _previewData = [];
                        }),
                        items: ['Students', 'Parents', 'Teachers'].map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickAndParseFile,
                    icon: const Icon(Icons.file_upload),
                    label: Text('Select File for $_importType'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_previewData.isNotEmpty) ...[
            Text('Preview (${_previewData.length} $_importType)', style: const TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _previewData.length,
                itemBuilder: (context, index) {
                  final item = _previewData[index];
                  String displayId = '';
                  if (_importType == 'Students') displayId = item['serial_id'] ?? ''; // Changed to serial_id
                  else if (_importType == 'Parents') displayId = item['parent_id'] ?? '';
                  else displayId = item['username'] ?? '';

                  return ListTile(
                    title: Text(item['name'] ?? item['username'] ?? 'No Name'),
                    subtitle: Text('ID: $displayId'),
                    dense: true,
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _uploadToDatabase,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: _isLoading ? const CircularProgressIndicator() : const Text('Confirm Upload to Database'),
            ),
          ] else if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            const Expanded(child: Center(child: Text('No data loaded. Select a file to preview.'))),
        ],
      ),
    );
  }

  Widget _buildUserManagementTab() {
    final filteredUsers = _allUsers.where((u) {
      final matchesSearch = u['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (u['username'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: const InputDecoration(
              hintText: 'Search users...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text('No user profiles found.'))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final bool isSuperAdmin = user['role'] == 'super_admin';
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSuperAdmin ? Colors.red : AppTheme.primary,
                          child: Icon(
                            isSuperAdmin ? Icons.admin_panel_settings : Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(user['name'] ?? 'No Name'),
                        subtitle: Text('${user['role']} | ${user['batch'] ?? 'No Batch'}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
