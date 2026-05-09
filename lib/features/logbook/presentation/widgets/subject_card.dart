import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/subject_model.dart';
import '../../../../core/theme/app_theme.dart';
import 'chapter_item.dart';

class SubjectCard extends ConsumerStatefulWidget {
  final SubjectModel subject;
  final int index;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.index,
  });

  @override
  ConsumerState<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends ConsumerState<SubjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  double _calculateSubjectProgress() {
    // Calculate progress from chapters/tasks
    if (widget.subject.chapters == null || widget.subject.chapters!.isEmpty) {
      return 0;
    }
    // TODO: Calculate based on completed tasks
    return 0; // Default to 0 for now
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateSubjectProgress();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
        border: Border.all(
          color: _isExpanded ? AppTheme.primary : AppTheme.borderColor,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: _toggleExpand,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        widget.subject.icon ?? widget.subject.name[0],
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.subject.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 6),
                        // Subject Progress Bar (Formula synced)
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: AppTheme.bgGray,
                                  valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                                  minHeight: 10, // Increased from 8
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(_expandController),
                    child: const Icon(Icons.expand_more, color: AppTheme.primary),
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable content
          SizeTransition(
            sizeFactor: _expandController,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.bgLight,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: widget.subject.chapters != null && widget.subject.chapters!.isNotEmpty
                    ? widget.subject.chapters!
                        .map((chapter) => ChapterItem(
                              key: ValueKey('chapter_${chapter.id}'),
                              subjectId: widget.subject.id,
                              chapterId: chapter.id,
                              title: chapter.title,
                              progress: 0, // TODO: Calculate from tasks
                              topics: null, // No topics level anymore
                              tasks: chapter.tasks, // Pass tasks from chapter
                            ))
                        .toList()
                    : [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No content found for this subject.'),
                        )
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
