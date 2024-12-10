import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MarkdownEditor extends StatefulWidget {
  final String? initialValue;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final String? label;
  final VoidCallback onImageUpload;
  final VoidCallback onVideoUpload;
  final String postId;

  const MarkdownEditor({
    Key? key,
    this.initialValue,
    required this.onChanged,
    this.validator,
    this.label,
    required this.onImageUpload,
    required this.onVideoUpload,
    required this.postId,
  }) : super(key: key);

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    if (widget.initialValue != null) {
      _controller.document.insert(0, widget.initialValue!);
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final plainText = _controller.document.toPlainText();
    widget.onChanged(plainText);
  }

  void _insertDivider() {
    final index = _controller.selection.baseOffset;
    final length = _controller.selection.extentOffset - index;

    // 현재 커서 위치에 구분선 삽입
    _controller.replaceText(index, length, '\n───────────────────\n', null);
  }

  void _handleImageUpload() async {
    await _pickAndUploadMedia(isVideo: false);
  }

  void _handleVideoUpload() async {
    await _pickAndUploadMedia(isVideo: true);
  }

  Future<void> _pickAndUploadMedia({required bool isVideo}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = isVideo
          ? await picker.pickVideo(source: ImageSource.gallery)
          : await picker.pickImage(source: ImageSource.gallery);

      if (file == null) return;

      // 파일 업로드 로직
      final String fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + '_' + file.name;

      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('posts/${widget.postId}/$fileName');

      await storageRef.putFile(File(file.path));
      final String downloadUrl = await storageRef.getDownloadURL();

      // 마크다운 텍스트에 미디어 링크 추가
      final String mediaMarkdown = isVideo
          ? '\n<video src="$downloadUrl"></video>\n'
          : '\n![](${downloadUrl})\n';

      final int index = _controller.selection.baseOffset;
      final length = _controller.selection.extentOffset - index;

      // QuillController를 사용하여 텍스트 삽입
      _controller.replaceText(index, length, mediaMarkdown, null);
    } catch (e) {
      // 에러 처리
      print('미디어 업로드 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('미디어 업로드에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.format_size),
              onPressed: () {
                _controller.formatText(
                  _controller.selection.baseOffset,
                  _controller.selection.extentOffset -
                      _controller.selection.baseOffset,
                  Attribute.h1,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.format_bold),
              onPressed: () {
                _controller.formatText(
                  _controller.selection.baseOffset,
                  _controller.selection.extentOffset -
                      _controller.selection.baseOffset,
                  Attribute.bold,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.format_italic),
              onPressed: () {
                _controller.formatText(
                  _controller.selection.baseOffset,
                  _controller.selection.extentOffset -
                      _controller.selection.baseOffset,
                  Attribute.italic,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.format_quote),
              onPressed: () {
                _controller.formatText(
                  _controller.selection.baseOffset,
                  _controller.selection.extentOffset -
                      _controller.selection.baseOffset,
                  Attribute.blockQuote,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.link),
              onPressed: () {
                // Link 기능 구현
              },
            ),
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: widget.onImageUpload,
              tooltip: '이미지 업로드',
            ),
            IconButton(
              icon: const Icon(Icons.videocam),
              onPressed: widget.onVideoUpload,
              tooltip: '동영상 업로드',
            ),
            IconButton(
              icon: const Icon(Icons.code),
              onPressed: () {
                _controller.formatText(
                  _controller.selection.baseOffset,
                  _controller.selection.extentOffset -
                      _controller.selection.baseOffset,
                  Attribute.codeBlock,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.horizontal_rule),
              onPressed: _insertDivider,
              tooltip: '구분선 추가',
            ),
          ],
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                controller: _controller,
                autoFocus: false,
                placeholder: widget.label ?? '당신의 여정을 들려주세요!',
                padding: const EdgeInsets.symmetric(vertical: 16),
                scrollable: true,
                expands: false,
                scrollBottomInset: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
