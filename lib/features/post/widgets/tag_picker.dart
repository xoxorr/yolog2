import 'package:flutter/material.dart';
import '../models/tag_model.dart';

class TagPicker extends StatelessWidget {
  final List<TagModel> selectedTags;
  final Function(List<TagModel>) onTagsSelected;

  const TagPicker({
    Key? key,
    required this.selectedTags,
    required this.onTagsSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('태그', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      // TODO: 태그 선택 구현
                      // 임시로 더미 데이터 추가
                      final newTag = TagModel(
                        id: DateTime.now().toString(),
                        name: '#새태그',
                        createdAt: DateTime.now(),
                      );
                      onTagsSelected([...selectedTags, newTag]);
                    },
                    icon: const Icon(Icons.tag),
                    label: const Text('태그 추가'),
                  ),
                ],
              ),
              if (selectedTags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedTags.map((tag) {
                    return Chip(
                      label: Text(tag.name),
                      onDeleted: () {
                        onTagsSelected(
                          selectedTags.where((t) => t.id != tag.id).toList(),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
