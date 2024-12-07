import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

class MarkdownEditor extends StatefulWidget {
  final String? initialValue;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final String? label;

  const MarkdownEditor({
    Key? key,
    this.initialValue,
    required this.onChanged,
    this.validator,
    this.label,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black12),
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              QuillToolbar.simple(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: _controller,
                  showFontFamily: false,
                  showFontSize: false,
                  showBackgroundColorButton: false,
                  showColorButton: true,
                  showClearFormat: true,
                  showCodeBlock: false,
                  showInlineCode: false,
                  showListCheck: false,
                  showQuote: true,
                  showLink: true,
                  showHeaderStyle: true,
                  showAlignmentButtons: true,
                  multiRowsDisplay: false,
                  toolbarIconAlignment: WrapAlignment.start,
                  toolbarIconCrossAlignment: WrapCrossAlignment.start,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.horizontal_rule),
                    onPressed: _insertDivider,
                    tooltip: '구분선 추가',
                  ),
                ],
              ),
            ],
          ),
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
