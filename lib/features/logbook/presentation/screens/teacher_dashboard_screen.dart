import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../providers/logbook_providers.dart';
import '../widgets/student_progress_card.dart';
import 'student_detail_screen.dart';

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState
    extends ConsumerState<TeacherDashboardScreen> {
  String _searchQuery = '';
  String _selectedBranch = 'All';
  String _selectedBatch = 'All';

  final List<String> _branches = ['All', 'Mira Road', 'Bhayander', 'Kandivali'];
  final List<String> _batches = ['All', 'ICSE 9', 'ICSE 10', 'CBSE 9', 'CBSE 10'];

  @override
  Widget build(BuildContext context) {
    // We'll fetch users from the repository
    final authRepo = AuthRepository();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.bgLight,
        title: const Text('Class Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textPrimary),
            onPressed: () => _showLogoutDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filters Section
              _buildFilters(context),
              const SizedBox(height: 24),

              // Student Progress Cards
              Text(
                'Student Progress',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700, color: AppTheme.primary),
              ),
              const SizedBox(height: 16),

              // Student List from "Database"
              FutureBuilder<List<Map>>(
                future: authRepo.localDataSource.getAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allUsers = snapshot.data ?? [];
                  final students = allUsers.where((u) => u['role'] == 'student').toList();

                  // Apply search and sorting
                  final filteredStudents = students.where((s) {
                    final matchesName = s['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
                    final matchesBranch = _selectedBranch == 'All' || s['branch'] == _selectedBranch;
                    final matchesBatch = _selectedBatch == 'All' || s['batch'] == _selectedBatch;
                    return matchesName && matchesBranch && matchesBatch;
                  }).toList();

                  if (filteredStudents.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text('No students found matching the criteria.'),
                      ),
                    );
                  }

                  // Get actual progress per student batch
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      final studentBatch = student['batch'] as String?;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => StudentDetailScreen(
                                  studentName: student['name'] as String,
                                  branch: student['branch'],
                                  batch: student['batch'],
                                ),
                              ),
                            );
                          },
                          child: Consumer(
                            builder: (context, ref, child) {
                              final progressAsync = ref.watch(progressByBatchProvider(studentBatch));
                              final progressValue = progressAsync.maybeWhen(
                                data: (d) => d,
                                orElse: () => 0.0,
                              );
                              return StudentProgressCard(
                                studentName: student['name'] as String,
                                progress: progressValue,
                                branch: student['branch'],
                                batch: student['batch'],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search by name...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedBranch,
                  decoration: const InputDecoration(labelText: 'Branch', contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                  items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (v) => setState(() => _selectedBranch = v!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedBatch,
                  decoration: const InputDecoration(labelText: 'Batch', contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                  items: _batches.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (v) => setState(() => _selectedBatch = v!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final authRepo = AuthRepository();
              await authRepo.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/role-selection', (route) => false);
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
