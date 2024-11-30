import 'package:flutter/material.dart';
import '../models/media_model.dart';

class MediaPicker extends StatelessWidget {
  final List<MediaModel> selectedMedia;
  final Function(List<MediaModel>) onMediaSelected;

  const MediaPicker({
    Key? key,
    required this.selectedMedia,
    required this.onMediaSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('미디어', style: TextStyle(fontSize: 16)),
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
                      // TODO: 미디어 선택 구현
                      // 임시로 더미 데이터 추가
                      final newMedia = MediaModel(
                        id: DateTime.now().toString(),
                        url: 'https://example.com/image.jpg',
                        type: 'image',
                        createdAt: DateTime.now(),
                      );
                      onMediaSelected([...selectedMedia, newMedia]);
                    },
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('미디어 추가'),
                  ),
                ],
              ),
              if (selectedMedia.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedMedia.map((media) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Icon(Icons.image),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              onMediaSelected(
                                selectedMedia.where((m) => m.id != media.id).toList(),
                              );
                            },
                          ),
                        ),
                      ],
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
