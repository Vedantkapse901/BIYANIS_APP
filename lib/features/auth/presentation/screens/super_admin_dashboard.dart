import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../logbook/data/datasources/local_datasource.dart';
import '../../../logbook/presentation/screens/student_detail_screen.dart';
import '../../data/repositories/auth_repository.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  int _currentIndex = 0;
  bool _isAppending = true;
  bool _isLoading = false;
  String _importType = 'Students'; // 'Students' or 'Tasks'
  List<Map<String, dynamic>> _previewData = [];
  final LocalDataSource _localDataSource = LocalDataSource();
  final List<String> _importOptions = ['Students', 'Tasks'];

  // For User Management
  List<Map> _allUsers = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  Future<void> _loadAllUsers() async {
    await _localDataSource.initialize();
    final users = await _localDataSource.getAllUsers();
    setState(() {
      // Filter out super admin from being visible to themselves if they want, 
      // but usually they should see everything including other admins if any.
      // However, the requirement says "super admin be not visible to the users".
      _allUsers = users;
    });
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
            parsedData = _processRawList(fields);
          } else {
            parsedData = await _processTaskList(fields);
          }
        } else {
          var bytes = file.readAsBytesSync();
          var excel = excel_lib.Excel.decodeBytes(bytes);
          for (var table in excel.tables.keys) {
            var rows = excel.tables[table]!.rows;
            List<List<dynamic>> rawList = rows.map((row) => row.map((cell) => cell?.value).toList()).toList();

            if (_importType == 'Students') {
              parsedData = _processRawList(rawList);
            } else {
              parsedData = await _processTaskList(rawList);
            }
            break; // Only process first sheet
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

  List<Map<String, dynamic>> _processRawList(List<List<dynamic>> rawData) {
    if (rawData.isEmpty) return [];

    int startIndex = 0;
    // Skip header if first row contains keywords
    if (rawData[0].any((cell) =>
        cell.toString().toLowerCase().contains('name') ||
        cell.toString().toLowerCase().contains('phone'))) {
      startIndex = 1;
    }

    List<Map<String, dynamic>> students = [];
    Set<String> seenPhones = {};

    for (var i = startIndex; i < rawData.length; i++) {
      var row = rawData[i];
      if (row.length < 2) continue;

      String name = row[0]?.toString().trim() ?? '';
      String phone = row[1]?.toString().trim() ?? '';
      String email = row.length > 2 ? row[2]?.toString().trim() ?? '' : '';
      String batchValue = row.length > 3 ? row[3]?.toString().trim() ?? '' : 'ICSE 9';
      final List<String> batchParts = batchValue.split(' ');
      final String board = batchParts.isNotEmpty ? batchParts[0] : 'ICSE';
      final String standard = batchParts.length > 1 ? batchParts[1] : '9';

      if (phone.isEmpty || seenPhones.contains(phone)) continue;

      seenPhones.add(phone);
      students.add({
        'name': name,
        'phone': phone,
        'email': email,
        'board': board,
        'standard': standard,
        'is_registered': false,
      });
    }
    return students;
  }

  Future<List<Map<String, dynamic>>> _processTaskList(List<List<dynamic>> rawData) async {
    if (rawData.isEmpty) return [];

    // Header detection: Chapter Name, Task Title, Order
    int startIndex = 0;
    if (rawData[0].any((cell) => cell.toString().toLowerCase().contains('chapter'))) {
      startIndex = 1;
    }

    List<Map<String, dynamic>> tasks = [];

    // We'll insert with chapter_name and handle ID matching in the upload step
    for (var i = startIndex; i < rawData.length; i++) {
      var row = rawData[i];
      if (row.length < 2) continue;

      String chapterName = row[0]?.toString().trim() ?? '';
      String taskTitle = row[1]?.toString().trim() ?? '';
      int order = 1;
      if (row.length > 2) {
        order = int.tryParse(row[2].toString()) ?? 1;
      }

      if (chapterName.isNotEmpty && taskTitle.isNotEmpty) {
        tasks.add({
          'chapter_name': chapterName,
          'title': taskTitle,
          'order_index': order,
        });
      }
    }
    return tasks;
  }

  Future<void> _uploadToDatabase() async {
    if (_previewData.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;

      if (_importType == 'Students') {
        await _localDataSource.initialize();
        if (!_isAppending) {
          await _localDataSource.clearStudents();
        }

        // Upload to Supabase
        await supabase.from('students').upsert(_previewData);
        // Sync Local
        await _localDataSource.bulkAddStudents(_previewData);
        _showMessage('Successfully uploaded ${_previewData.length} students.');
      } else {
        // Task Upload Logic
        print('⚡ Starting Task Upload for ${_previewData.length} items');

        // 1. Get all chapters to match IDs
        final chaptersResponse = await supabase.from('chapters').select('id, title');
        final Map<String, String> chapterMap = {
          for (var c in chaptersResponse as List) c['title'].toString().toLowerCase().trim(): c['id'].toString()
        };

        final List<Map<String, dynamic>> tasksToUpload = [];
        int missingChapters = 0;

        for (var task in _previewData) {
          final cName = task['chapter_name'].toString().toLowerCase().trim();
          final cId = chapterMap[cName];

          if (cId != null) {
            tasksToUpload.add({
              'chapter_id': cId,
              'chapter_name': task['chapter_name'],
              'title': task['title'],
              'order_index': task['order_index'],
            });
          } else {
            missingChapters++;
            print('⚠️ Missing chapter in DB: ${task['chapter_name']}');
          }
        }

        if (tasksToUpload.isNotEmpty) {
          await supabase.from('tasks').insert(tasksToUpload);
          _showMessage('Uploaded ${tasksToUpload.length} tasks. ($missingChapters chapters not found)');
        } else {
          _showMessage('No tasks could be matched to existing chapters.', isError: true);
        }
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
        title: Text(_currentIndex == 0 ? 'Import Dashboard' : 'User Management'),
        actions: [
          if (_currentIndex == 1)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAllUsers,
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
          _buildUserManagementTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: 'Import'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        ],
      ),
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
                        items: _importOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_importType == 'Students')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Overwrite'),
                        Switch(
                          value: _isAppending,
                          onChanged: (val) => setState(() => _isAppending = val),
                        ),
                        const Text('Append'),
                      ],
                    ),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickAndParseFile,
                    icon: const Icon(Icons.file_upload),
                    label: Text('Select CSV / Excel for $_importType'),
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
                  if (_importType == 'Students') {
                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text('${item['phone']} | ${item['board']} ${item['standard']}'),
                      dense: true,
                    );
                  } else {
                    return ListTile(
                      title: Text(item['title']),
                      subtitle: Text('Chapter: ${item['chapter_name']} | Order: ${item['order_index']}'),
                      dense: true,
                    );
                  }
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
          u['username'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
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
                ? const Center(child: Text('No users found.'))
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
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Super admin can see everything - so they can view any student's detail
                          if (user['role'] == 'student') {
                             Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => StudentDetailScreen(
                                  studentName: user['name'] as String,
                                  branch: user['branch'],
                                  batch: user['batch'],
                                ),
                              ),
                            );
                          } else {
                            _showMessage('Viewing details for ${user['role']} not implemented yet.');
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
