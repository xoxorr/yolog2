import 'package:flutter/material.dart';
import '../services/comment_service.dart';
import '../models/comment_model.dart';

class CommentScreen extends StatefulWidget {
  final String contentId;

  const CommentScreen({
    super.key,
    required this.contentId,
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<CommentModel> _comments = [];
  String? _lastCommentId;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _currentUserId;
  CommentModel? _replyTo;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    try {
      final comments = await _commentService.getComments(
        widget.contentId,
        lastCommentId: _lastCommentId,
      );

      if (comments.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        setState(() {
          _comments.addAll(comments);
          _lastCommentId = comments.last.id;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadComments();
    }
  }

  Future<void> _submitComment() async {
    if (_currentUserId == null) return;

    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _commentService.addComment(
        _currentUserId!,
        widget.contentId,
        content,
        parentId: _replyTo?.id,
      );

      _commentController.clear();
      setState(() => _replyTo = null);

      // 새 댓글을 보기 위해 목록 새로고침
      _comments.clear();
      _lastCommentId = null;
      _hasMore = true;
      await _loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('댓글'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _comments.isEmpty
                ? Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('댓글이 없습니다.'),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _comments.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _comments.length) {
                        return _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox.shrink();
                      }

                      final comment = _comments[index];
                      return _CommentTile(
                        comment: comment,
                        currentUserId: _currentUserId,
                        onReply: (comment) {
                          setState(() => _replyTo = comment);
                          _commentController.text = '@${comment.userId} ';
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        onDelete: (comment) async {
                          try {
                            await _commentService.deleteComment(comment.id);
                            // 댓글 목록 새로고침
                            _comments.clear();
                            _lastCommentId = null;
                            _hasMore = true;
                            await _loadComments();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
          ),
          if (_replyTo != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Row(
                children: [
                  Expanded(
                    child: Text('답글 작성: ${_replyTo!.userId}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() => _replyTo = null);
                      _commentController.clear();
                    },
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText:
                          _replyTo != null ? '답글을 입력하세요...' : '댓글을 입력하세요...',
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _submitComment,
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
  final CommentModel comment;
  final String? currentUserId;
  final Function(CommentModel) onReply;
  final Function(CommentModel) onDelete;

  const _CommentTile({
    required this.comment,
    required this.currentUserId,
    required this.onReply,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text(comment.userId),
          const SizedBox(width: 8),
          Text(
            comment.isEdited ? '(수정됨)' : '',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment.content),
          Row(
            children: [
              TextButton(
                onPressed: () => onReply(comment),
                child: const Text('답글'),
              ),
              if (currentUserId == comment.userId)
                TextButton(
                  onPressed: () => onDelete(comment),
                  child: const Text(
                    '삭제',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ],
      ),
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
    );
  }
}
