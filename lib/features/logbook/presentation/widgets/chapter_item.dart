import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/topic_entity.dart';
import '../../data/models/task_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/logbook_providers.dart';
import 'task_checkbox_item.dart';

class ChapterItem extends StatefulWidget {
  final String subjectId;
  final String chapterId;
  final String title;
  final double progress;
  final List<TopicEntity>? topics;
  final List<TaskModel>? tasks;

  const ChapterItem({
    super.key,
    required this.subjectId,
    required this.chapterId,
    required this.title,
    required this.progress,
    this.topics,
    this.tasks,
  });

  @override
  State<ChapterItem> createState() => _ChapterItemState();
}

class _ChapterItemState extends State<ChapterItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          ListTile(
            dense: true,
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: widget.progress,
                  backgroundColor: AppTheme.bgGray,
                  valueColor: AlwaysStoppedAnimation(
                    widget.progress == 1.0 ? Colors.green : AppTheme.primary,
                  ),
                  minHeight: 4,
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(widget.progress * 100).round()}%',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, size: 18),
              ],
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                children: [
                  if (widget.tasks != null && widget.tasks!.isNotEmpty)
                    _buildTasksList(widget.tasks!),
                  if (widget.topics != null && widget.topics!.isNotEmpty)
                    ...widget.topics!.map((topic) => _buildTopicRow(topic)).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTasksList(List<TaskModel> tasks) {
    final sortedTasks = [...tasks]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Text(
            'Tasks',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
        ),
        ...sortedTasks.map((task) {
          return TaskCheckboxItem(
            subjectId: widget.subjectId,
            chapterId: widget.chapterId,
            topicId: widget.chapterId, // Use chapterId as topicId for compatibility
            taskId: task.id,
            title: task.title,
            isCompleted: task.isCompleted,
          );
        }).toList(),
        const Divider(height: 12, thickness: 0.5),
      ],
    );
  }

  Widget _buildTopicRow(TopicEntity topic) {
    final sortedTasks = [...topic.tasks]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Text(
            topic.title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: sortedTasks.map((task) {
              return Tooltip(
                message: task.title,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: CompactTaskCheckbox(
                    subjectId: widget.subjectId,
                    chapterId: widget.chapterId,
                    topicId: topic.id,
                    taskId: task.id,
                    isCompleted: task.isCompleted,
                    orderIndex: task.orderIndex,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 12, thickness: 0.5),
      ],
    );
  }
}

class CompactTaskCheckbox extends ConsumerWidget {
  final String subjectId;
  final String chapterId;
  final String topicId;
  final String taskId;
  final bool isCompleted;
  final int orderIndex;

  const CompactTaskCheckbox({
    super.key,
    required this.subjectId,
    required this.chapterId,
    required this.topicId,
    required this.taskId,
    required this.isCompleted,
    required this.orderIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.read(taskCompletionProvider(taskId).notifier).toggleCompletion(!isCompleted);
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isCompleted ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isCompleted ? AppTheme.primary : AppTheme.borderColor,
            width: 1.5,
          ),
        ),
        child: isCompleted
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : Center(
                child: Text(
                  '$orderIndex',
                  style: TextStyle(fontSize: 9, color: AppTheme.textLight),
                ),
              ),
      ),
    );
  }
}
