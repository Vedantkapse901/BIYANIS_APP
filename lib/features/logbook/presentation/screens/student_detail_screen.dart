import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/logbook_providers.dart';
import '../widgets/subject_card.dart';

class StudentDetailScreen extends ConsumerWidget {
  final String studentName;
  final String? branch;
  final String? batch;

  const StudentDetailScreen({
    super.key,
    required this.studentName,
    this.branch,
    this.batch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider(batch ?? 'ICSE 10'));
    
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.bgLight,
        title: Text('$studentName\'s Logbook'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 24),

              Text(
                'Subjects Progress',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
              ),
              const SizedBox(height: 16),

              // Subjects List
              subjectsAsync.when(
                data: (subjects) {
                  if (subjects.isEmpty) {
                    return const Center(child: Text('No subjects available.'));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      return SubjectCard(
                        subject: subjects[index],
                        index: index,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(child: Text('Error: $err')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student Profile',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                  ),
                  Text(
                    studentName,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Icon(Icons.person, color: Colors.white, size: 40),
            ],
          ),
          if (branch != null || batch != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (branch != null) ...[
                  const Icon(Icons.location_on, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(branch!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  const SizedBox(width: 16),
                ],
                if (batch != null) ...[
                  const Icon(Icons.school, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(batch!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
