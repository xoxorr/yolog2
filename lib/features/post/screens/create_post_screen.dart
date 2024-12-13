import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/post_service.dart';
import '../models/post_model.dart';
import '../widgets/markdown_editor.dart';
import '../widgets/media_picker.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/constants/style_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/post_detail_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _tagController = TextEditingController();
  final _titleFocus = FocusNode();
  final _contentFocus = FocusNode();
  String _content = '';
  double _rating = 0;
  bool _isSaving = false;
  final Set<String> _tags = {};
  String _tempPostId = '';

  @override
  void initState() {
    super.initState();
    _tempPostId = const Uuid().v4();
  }

  @override
  void dispose() {
    _titleController.dispose();
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
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
      });

      try {
        // 현재 사용자 정보 가져오기
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw '로그인이 필요합니다';

        final post = PostModel(
          id: _tempPostId, // 미디어 업로드에 사용한 임시 ID를 실제 포스트 ID로 사용
          title: _titleController.text,
          content: _content,
          authorId: user.uid,
          authorName: user.displayName ?? '사용자',
          authorPhotoUrl: user.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          tags: _tags.toList(),
          rating: _rating,
        );

        // Firestore에 포스트 저장
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(_tempPostId)
            .set(post.toJson());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('저장되었습니다')),
          );
          // 저장 성공 후 포스트 상세 화면으로 이동
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(postId: _tempPostId),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('저장 실패: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  Future<void> _pickAndUploadMedia({required bool isVideo}) async {
    try {
      final XFile? pickedFile = isVideo
          ? await ImagePicker().pickVideo(source: ImageSource.gallery)
          : await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      // MediaService를 사용하여 파일 업로드
      // 예시: await _mediaService.uploadMedia(file);

      // 업로드 후 추가적인 처리
      // 예시: setState(() { _uploadedMedia.add(file); });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드 실패: $e')),
      );
    }
  }

  void _handleImageUpload() async {
    // 이미지 업로드 기능 구현
    await _pickAndUploadMedia(isVideo: false);
  }

  void _handleVideoUpload() async {
    // 영상 업로드 기능 구현
    await _pickAndUploadMedia(isVideo: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: const Text(''),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _handleSave,
            icon: const Icon(Icons.save_outlined),
            label: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                decoration: InputDecoration(
                  hintText: '제목을 입력하세요',
                  border: InputBorder.none,
                  hintStyle:
                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: MarkdownEditor(
                      onChanged: (value) => _content = value,
                      onImageUpload: () => _pickAndUploadMedia(isVideo: false),
                      onVideoUpload: () => _pickAndUploadMedia(isVideo: true),
                      label: '당신의 여정을 들려주세요!',
                      postId: _tempPostId,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_offer_outlined,
                          size: 20,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6)),
                      const SizedBox(width: 8),
                      Text(
                        '태그',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 16),
                      // 평점 선택
                      Icon(
                        Icons.star_outline,
                        size: 20,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 100,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 4),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12),
                            activeTrackColor:
                                Theme.of(context).colorScheme.primary,
                            inactiveTrackColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2),
                            thumbColor: Theme.of(context).colorScheme.primary,
                            overlayColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                          ),
                          child: Slider(
                            value: _rating,
                            min: 0,
                            max: 5,
                            divisions: 10,
                            label: _rating.toString(),
                            onChanged: (value) {
                              setState(() {
                                _rating = value;
                              });
                            },
                          ),
                        ),
                      ),
                      Text(
                        _rating.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                      if (_tags.isNotEmpty) ...[
                        const Spacer(),
                        Text(
                          '${_tags.length}개의 태그',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      hintText: '태그를 입력하고 엔터를 누르세요 (예: 여행, 일상)',
                      prefixIcon: Icon(
                        Icons.add,
                        size: 20,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (value) {
                      final tags = value
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty);
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
                          label: Text(tag),
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _removeTag(tag),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '쉼표(,)로 구분하여 여러 태그를 한 번에 입력할 수 있습니다',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
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
