import 'package:flutter/material.dart';
import '../models/post_model.dart';

class PostEditor extends StatefulWidget {
  final PostModel? initialPost;
  final Function(PostModel) onSave;
  final VoidCallback? onCancel;
  final bool isSaving;

  const PostEditor({
    Key? key,
    this.initialPost,
    required this.onSave,
    this.onCancel,
    this.isSaving = false,
  }) : super(key: key);

  @override
  State<PostEditor> createState() => _PostEditorState();
}

class _PostEditorState extends State<PostEditor> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPost != null) {
      _titleController.text = widget.initialPost!.title;
      _contentController.text = widget.initialPost!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final post = PostModel(
        id: widget.initialPost?.id ?? '',
        title: _titleController.text,
        content: _contentController.text,
        authorId: widget.initialPost?.authorId ?? '',
        createdAt: widget.initialPost?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
      );

      widget.onSave(post);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '제목',
              hintText: '제목을 입력하세요',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '제목을 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: '내용',
              hintText: '내용을 입력하세요',
            ),
            maxLines: null,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '내용을 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.onCancel != null)
                TextButton(
                  onPressed: widget.isSaving ? null : widget.onCancel,
                  child: const Text('취소'),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: widget.isSaving ? null : _handleSave,
                child: widget.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('저장'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
