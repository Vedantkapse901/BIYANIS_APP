import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/logbook_providers.dart';

class TaskCheckboxItem extends ConsumerStatefulWidget {
  final String subjectId;
  final String chapterId;
  final String topicId;
  final String taskId;
  final String title;
  final bool isCompleted;

  const TaskCheckboxItem({
    super.key,
    required this.subjectId,
    required this.chapterId,
    required this.topicId,
    required this.taskId,
    required this.title,
    required this.isCompleted,
  });

  @override
  ConsumerState<TaskCheckboxItem> createState() => _TaskCheckboxItemState();
}

class _TaskCheckboxItemState extends ConsumerState<TaskCheckboxItem> {
  late bool _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.isCompleted;
  }

  @override
  void didUpdateWidget(TaskCheckboxItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCompleted != widget.isCompleted) {
      _currentValue = widget.isCompleted;
    }
  }

  void _toggleTask() {
    setState(() => _currentValue = !_currentValue);
    ref.read(taskCompletionProvider(widget.taskId).notifier).toggleCompletion(!widget.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    // Allow all users to toggle tasks (you can add role check if needed)
    const canToggle = true;

    return InkWell(
      onTap: canToggle ? _toggleTask : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _currentValue,
                activeColor: AppTheme.primary,
                onChanged: canToggle ? (v) => _toggleTask() : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 12,
                  decoration: _currentValue ? TextDecoration.lineThrough : null,
                  color: _currentValue ? AppTheme.textLight : AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
