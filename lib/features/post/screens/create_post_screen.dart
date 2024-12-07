import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/post_service.dart';
import '../models/post_model.dart';
import '../widgets/markdown_editor.dart';
import '../screens/post_detail_screen.dart'; // PostDetailScreen import 추가

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  String _content = '';
  List<String> _tags = [];
  bool _isSaving = false;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _handleSave() async {
    try {
      if (_titleController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('제목을 입력해주세요')),
        );
        return;
      }

      setState(() => _isSaving = true);

      final postService = context.read<PostService>();

      final post = PostModel(
        id: '',
        title: _titleController.text,
        content: _content,
        authorId: '', // PostService에서 업데이트됨
        authorName: '', // PostService에서 업데이트됨
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
        tags: _tags,
      );

      final postId = await postService.createPost(post);

      if (mounted) {
        // 게시글 작성 완료 후 해당 게시글로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postId: postId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _handleSave,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    '저장',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextFormField(
                controller: _titleController,
                focusNode: _titleFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  _contentFocus.requestFocus();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: '제목을 입력하세요',
                  border: InputBorder.none,
                ),
              ),
            ),
            const Divider(height: 1, color: Colors.black12),
            Expanded(
              child: MarkdownEditor(
                onChanged: (value) => _content = value,
                label: '당신의 여정을 들려주세요!',
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                border: Border(
                  top: BorderSide(color: Colors.black12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_offer_outlined, size: 20, color: Colors.black54),
                      const SizedBox(width: 8),
                      const Text(
                        '태그',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      if (_tags.isNotEmpty)
                        Text(
                          '${_tags.length}개의 태그',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      hintText: '태그를 입력하고 엔터를 누르세요 (예: 여행, 일상)',
                      hintStyle: const TextStyle(color: Colors.black38),
                      prefixIcon: const Icon(Icons.add, size: 20, color: Colors.black54),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue, width: 1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (value) {
                      final tags = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
                      for (final tag in tags) {
                        _addTag(tag);
                      }
                    },
                  ),
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide.none,
                          deleteIcon: const Icon(Icons.close, size: 16),
                          deleteIconColor: Colors.black54,
                          onDeleted: () => _removeTag(tag),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 4),
                  const Text(
                    '쉼표(,)로 구분하여 여러 태그를 한 번에 입력할 수 있습니다',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
