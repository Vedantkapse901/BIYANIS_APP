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
  int _currentIndex = 0;
  bool _isLoading = false;
  String _importType = 'Students'; // 'Students' or 'Parents'
  List<Map<String, dynamic>> _previewData = [];

  // For Management
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _allParents = [];
  String _searchQuery = '';
  String _studentSearchQuery = '';
  String _parentSearchQuery = '';

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
    ]);
  }

  Future<void> _loadAllUsers() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('profiles').select().order('name');
      setState(() {
        _allUsers = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> _loadAllStudents() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('students').select().order('serial_id');
      setState(() {
        _allStudents = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error loading students: $e');
    }
  }

  Future<void> _loadAllParents() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('parents').select().order('parent_id');
      setState(() {
        _allParents = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error loading parents: $e');
    }
  }

  void _showAddEditStudentDialog([Map<String, dynamic>? student]) {
    final nameController = TextEditingController(text: student?['name']);
    final serialIdController = TextEditingController(text: student?['serial_id']);
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
              TextField(controller: serialIdController, decoration: const InputDecoration(labelText: 'Student ID (e.g. 001)')),
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
                  'serial_id': serialIdController.text.trim(),
                  'password': passwordController.text.trim(),
                  'board': boardController.text.trim(),
                  'standard': standardController.text.trim(),
                  'batch': batchController.text.trim(),
                  'school_name': schoolNameController.text.trim(),
                  'class_branch': classBranchController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                };

                final supabase = Supabase.instance.client;
                if (student == null) {
                  await supabase.from('students').insert(data);
                } else {
                  await supabase.from('students').update(data).eq('id', student['id']);
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
              TextField(controller: childIdController, decoration: const InputDecoration(labelText: 'Child ID (Student Serial ID)')),
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
                };

                final supabase = Supabase.instance.client;
                if (parent == null) {
                  await supabase.from('parents').insert(data);
                } else {
                  await supabase.from('parents').update(data).eq('id', parent['id']);
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
        await Supabase.instance.client.from('students').delete().eq('id', id);
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
        await Supabase.instance.client.from('parents').delete().eq('id', id);
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
          } else {
            parsedData = _processRawParentList(fields);
          }
        } else {
          var bytes = file.readAsBytesSync();
          var excel = excel_lib.Excel.decodeBytes(bytes);
          for (var table in excel.tables.keys) {
            var rows = excel.tables[table]!.rows;
            List<List<dynamic>> rawList = rows.map((row) => row.map((cell) => cell?.value).toList()).toList();
            if (_importType == 'Students') {
              parsedData = _processRawStudentList(rawList);
            } else {
              parsedData = _processRawParentList(rawList);
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
    if (rawData[0].any((cell) =>
        cell.toString().toLowerCase().contains('name') ||
        cell.toString().toLowerCase().contains('phone'))) {
      startIndex = 1;
    }

    List<Map<String, dynamic>> students = [];
    for (var i = startIndex; i < rawData.length; i++) {
      var row = rawData[i];
      if (row.length < 2) continue;

      String name = row[0]?.toString().trim() ?? '';
      String phone = row[1]?.toString().trim() ?? '';
      String email = row.length > 2 ? row[2]?.toString().trim() ?? '' : '';
      String batchValue = row.length > 3 ? row[3]?.toString().trim() ?? 'ICSE 9' : 'ICSE 9';
      String password = row.length > 4 ? row[4]?.toString().trim() ?? '123456' : '123456';
      String serialId = row.length > 5 ? row[5]?.toString().trim() ?? '' : '';

      students.add({
        'name': name,
        'phone': phone,
        'email': email,
        'batch': batchValue,
        'password': password,
        'serial_id': serialId,
        'is_registered': false,
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

  Future<void> _uploadToDatabase() async {
    if (_previewData.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      if (_importType == 'Students') {
        await supabase.from('students').upsert(_previewData, onConflict: 'serial_id');
        _showMessage('Successfully uploaded ${_previewData.length} students.');
        _loadAllStudents();
      } else {
        await supabase.from('parents').upsert(_previewData, onConflict: 'parent_id');
        _showMessage('Successfully uploaded ${_previewData.length} parents.');
        _loadAllParents();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Bulk Import' : _currentIndex == 1 ? 'Approved Student List' : _currentIndex == 2 ? 'Approved Parent List' : 'User Profiles'),
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
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        ],
      ),
    );
  }

  Widget _buildStudentManagementTab() {
    final filteredStudents = _allStudents.where((s) {
      final query = _studentSearchQuery.toLowerCase();
      return (s['name'] ?? '').toString().toLowerCase().contains(query) ||
          (s['serial_id'] ?? '').toString().toLowerCase().contains(query);
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
                    subtitle: Text('ID: ${student['serial_id']} | Pass: ${student['password']}\n${student['batch']}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showAddEditStudentDialog(student)),
                        IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _deleteStudent(student['id'])),
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
                        IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _deleteParent(parent['id'])),
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
                        items: ['Students', 'Parents'].map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
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
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text('ID: ${item[_importType == 'Students' ? 'serial_id' : 'parent_id']}'),
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
