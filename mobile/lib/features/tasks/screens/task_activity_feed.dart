import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/task_comment.dart';
import '../../../core/models/task.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_colors.dart';

final _taskCommentsProvider = FutureProvider.autoDispose
    .family<List<TaskComment>, int>((ref, taskId) {
  return ref.read(activityServiceProvider).getTaskComments(taskId);
});

class TaskActivityFeed extends ConsumerStatefulWidget {
  const TaskActivityFeed({
    required this.task,
    super.key,
  });

  final Task task;

  @override
  ConsumerState<TaskActivityFeed> createState() => _TaskActivityFeedState();
}

class _TaskActivityFeedState extends ConsumerState<TaskActivityFeed> {
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(_taskCommentsProvider(widget.task.id));
    final user = ref.watch(authProvider).user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Activity Feed',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  maxLines: null,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _addComment,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        comments.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
          error: (err, st) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading comments: $err'),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No comments yet',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final comment = items[index];
                return _CommentTile(comment: comment);
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    try {
      await ref
          .read(activityServiceProvider)
          .addComment(widget.task.id, _commentController.text);
      _commentController.clear();
      ref.invalidate(_taskCommentsProvider(widget.task.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    }
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final TaskComment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.accent,
                child: Text(
                  comment.userName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      Fmt.dateTime(comment.createdAt),
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(comment.content),
          ),
        ],
      ),
    );
  }
}
