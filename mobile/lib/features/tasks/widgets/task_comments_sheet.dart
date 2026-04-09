import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/task_comment.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

class TaskCommentsSheet extends ConsumerStatefulWidget {
  const TaskCommentsSheet({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  final int taskId;
  final String taskTitle;

  @override
  ConsumerState<TaskCommentsSheet> createState() => _TaskCommentsSheetState();
}

class _TaskCommentsSheetState extends ConsumerState<TaskCommentsSheet> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  List<TaskComment> _comments = <TaskComment>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    try {
      final comments =
          await ref.read(activityServiceProvider).getTaskComments(widget.taskId);
      comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load comments: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    _commentController.clear();
    try {
      final newComment =
          await ref.read(activityServiceProvider).addComment(widget.taskId, content);
      if (!mounted) return;
      setState(() => _comments.add(newComment));
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add comment: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, __) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withAlpha(50)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Task: ${widget.taskTitle}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? const Center(
                        child: Text('No comments yet. Be the first to comment.'),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _comments.length,
                        itemBuilder: (_, i) => _CommentTile(comment: _comments[i]),
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendComment,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final TaskComment comment;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          (comment.userName.isEmpty ? 'U' : comment.userName[0]).toUpperCase(),
        ),
      ),
      title: Text(
        comment.userName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(comment.content),
      trailing: Text(
        Fmt.timeAgo(comment.createdAt),
        style: const TextStyle(fontSize: 11),
      ),
      isThreeLine: true,
    );
  }
}
