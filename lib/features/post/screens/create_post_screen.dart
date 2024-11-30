import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/post_service.dart';
import '../models/post_model.dart';
import '../widgets/post_editor.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  bool _isSaving = false;

  Future<void> _handleSave(PostModel post) async {
    if (_isSaving) return;

    try {
      setState(() => _isSaving = true);

      final postService = context.read<PostService>();
      
      // 게시글 유효성 검사
      final error = postService.validatePost(post);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        return;
      }

      // 게시글 저장
      await postService.createPost(post);

      if (!mounted) return;

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 작성되었습니다')),
      );

      // 홈 화면으로 이동
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 작성 중 오류가 발생했습니다: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 게시글 작성'),
      ),
      body: PostEditor(
        onSave: _handleSave,
        isSaving: _isSaving,
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}
