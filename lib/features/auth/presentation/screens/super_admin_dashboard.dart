import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel_lib;
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
  List<Map<String, dynamic>> _previewData = [];
  final LocalDataSource _localDataSource = LocalDataSource();

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
          parsedData = _processRawList(fields);
        } else {
          var bytes = file.readAsBytesSync();
          var excel = excel_lib.Excel.decodeBytes(bytes);
          for (var table in excel.tables.keys) {
            var rows = excel.tables[table]!.rows;
            List<List<dynamic>> rawList = rows.map((row) => row.map((cell) => cell?.value).toList()).toList();
            parsedData = _processRawList(rawList);
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
    // Skip header if first row contains 'name' or 'phone'
    if (rawData[0].any((cell) => cell.toString().toLowerCase().contains('name') || cell.toString().toLowerCase().contains('phone'))) {
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
      String batch = row.length > 3 ? row[3]?.toString().trim() ?? '' : 'ICSE 9';

      if (phone.isEmpty || seenPhones.contains(phone)) continue;

      seenPhones.add(phone);
      students.add({
        'name': name,
        'phone': phone,
        'email': email,
        'batch': batch,
        'is_registered': false,
      });
    }
    return students;
  }

  Future<void> _uploadToDatabase() async {
    if (_previewData.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _localDataSource.initialize();
      
      if (!_isAppending) {
        // Clear existing (simulated by overwriting Hive box logic in DataSource if implemented)
        // For now, we use bulkAdd which can be modified to clear first
        await _localDataSource.clearApprovedStudents(); 
      }

      await _localDataSource.bulkAddApprovedStudents(_previewData);
      
      _showMessage('Successfully uploaded ${_previewData.length} students.');
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
                  const Text('Import Approved Students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
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
                    label: const Text('Select CSV / Excel File'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_previewData.isNotEmpty) ...[
            Text('Preview (${_previewData.length} students)', style: const TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _previewData.length,
                itemBuilder: (context, index) {
                  final s = _previewData[index];
                  return ListTile(
                    title: Text(s['name']),
                    subtitle: Text('${s['phone']} | ${s['batch']}'),
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
