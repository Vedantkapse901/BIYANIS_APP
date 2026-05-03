import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/topic_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/logbook_providers.dart';

class TopicItem extends ConsumerStatefulWidget {
  final TopicEntity topic;
  final Color subjectColor;

  const TopicItem({
    super.key,
    required this.topic,
    required this.subjectColor,
  });

  @override
  ConsumerState<TopicItem> createState() => _TopicItemState();
}

class _TopicItemState extends ConsumerState<TopicItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    // Start animation if already completed
    if (widget.topic.isCompleted ?? false) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCompletion() async {
    // Animate the checkbox
    if (widget.topic.isCompleted ?? false) {
      await _animationController.reverse();
    } else {
      await _animationController.forward();
    }

    // Toggle in database
    ref.read(toggleTopicProvider.notifier).toggleTopic(widget.topic.id);

    // Refresh the subjects list
    ref.invalidate(allSubjectsProvider);
    if (widget.topic.subjectId != null) {
      ref.invalidate(topicsBySubjectProvider(widget.topic.subjectId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(userRoleProvider);
    final canToggle = roleAsync.maybeWhen(
      data: (role) => role == 'student',
      orElse: () => false,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (widget.topic.isCompleted ?? false)
              ? widget.subjectColor.withValues(alpha: 0.3)
              : AppTheme.borderColor,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Custom Animated Checkbox
          GestureDetector(
            onTap: canToggle ? _toggleCompletion : null,
            child: ScaleTransition(
// ...
              scale: Tween(begin: 1.0, end: 1.15).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeInOutBack,
                ),
              ),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: (widget.topic.isCompleted ?? false)
                      ? widget.subjectColor
                      : AppTheme.bgWhite,
                  border: Border.all(
                    color: (widget.topic.isCompleted ?? false)
                        ? widget.subjectColor
                        : AppTheme.borderColor,
                    width: 2,
                  ),
                ),
                child: AnimatedOpacity(
                  opacity: (widget.topic.isCompleted ?? false) ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.check,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Topic Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.topic.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        decoration: (widget.topic.isCompleted ?? false)
                            ? TextDecoration.lineThrough
                            : null,
                        color: (widget.topic.isCompleted ?? false)
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                      ),
                ),
                if (widget.topic.description != null &&
                    widget.topic.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.topic.description!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.textLight,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          // Completion Date (if completed)
          if ((widget.topic.isCompleted ?? false) && widget.topic.completedAt != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.subjectColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '✓ Done',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: widget.subjectColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
