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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: QuillToolbar.simple(
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
              multiRowsDisplay: false,
              toolbarIconAlignment: WrapAlignment.start,
              toolbarIconCrossAlignment: WrapCrossAlignment.start,
              padding: const EdgeInsets.all(0),
              iconTheme: const QuillIconTheme(
                iconSelectedColor: Colors.blue,
                iconUnselectedColor: Colors.black87,
                iconSelectedFillColor: Colors.transparent,
                iconUnselectedFillColor: Colors.transparent,
                iconSize: 20,
              ),
              customButtons: const [],
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                controller: _controller,
                autoFocus: false,
                readOnly: false,
                placeholder: '당신의 여정을 들려주세요!',
                placeholderStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.black38,
                  height: 1.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                scrollable: true,
                expands: false,
                scrollBottomInset: 0,
                customStyles: DefaultStyles(
                  paragraph: DefaultTextBlockStyle(
                    const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    const VerticalSpacing(0, 0),
                    const VerticalSpacing(0, 0),
                    null,
                  ),
                  h1: DefaultTextBlockStyle(
                    const TextStyle(
                      fontSize: 24,
                      color: Colors.black87,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                    const VerticalSpacing(12, 8),
                    const VerticalSpacing(12, 8),
                    null,
                  ),
                  h2: DefaultTextBlockStyle(
                    const TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                    const VerticalSpacing(10, 6),
                    const VerticalSpacing(10, 6),
                    null,
                  ),
                  h3: DefaultTextBlockStyle(
                    const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                    const VerticalSpacing(8, 4),
                    const VerticalSpacing(8, 4),
                    null,
                  ),
                  lists: DefaultListBlockStyle(
                    const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    const VerticalSpacing(8, 4),
                    const VerticalSpacing(8, 4),
                    null,
                    null,
                  ),
                  quote: DefaultTextBlockStyle(
                    const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                    const VerticalSpacing(8, 4),
                    const VerticalSpacing(8, 4),
                    BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Colors.black26,
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
