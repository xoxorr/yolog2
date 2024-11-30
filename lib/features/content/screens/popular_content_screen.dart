import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../services/content_service.dart';

class PopularContentScreen extends StatefulWidget {
  const PopularContentScreen({super.key});

  @override
  State<PopularContentScreen> createState() => _PopularContentScreenState();
}

class _PopularContentScreenState extends State<PopularContentScreen> {
  final ContentService _contentService = ContentService();
  List<ContentModel> _popularContents = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPopularContents();
  }

  Future<void> _loadPopularContents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final contents = await _contentService.getPopularContents();
      setState(() {
        _popularContents = contents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '인기 콘텐츠를 불러오는데 실패했습니다.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPopularContents,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_popularContents.isEmpty) {
      return const Center(
        child: Text('인기 콘텐츠가 없습니다.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPopularContents,
      child: ListView.builder(
        itemCount: _popularContents.length,
        itemBuilder: (context, index) {
          final content = _popularContents[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: content.thumbnailUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        content.thumbnailUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.image),
              title: Text(
                content.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye, size: 16),
                      const SizedBox(width: 4),
                      Text(content.viewCount.toString()),
                      const SizedBox(width: 16),
                      const Icon(Icons.favorite, size: 16),
                      const SizedBox(width: 4),
                      Text(content.likeCount.toString()),
                    ],
                  ),
                ],
              ),
              onTap: () {
                // TODO: Navigate to content detail screen
              },
            ),
          );
        },
      ),
    );
  }
}
