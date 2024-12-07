import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/post_model.dart';
import '../models/media_model.dart';
import '../services/post_service.dart';
import 'package:provider/provider.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late final PostService _postService;
  bool _isLoading = true;
  PostModel? _post;
  String? _error;

  @override
  void initState() {
    super.initState();
    _postService = Provider.of<PostService>(context, listen: false);
    _loadPost();
  }

  Future<void> _loadPost() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final post = await _postService.getPost(widget.postId);
      setState(() {
        _post = post;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '포스트를 불러오는데 실패했습니다.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('포스트 삭제'),
        content: const Text('정말로 이 포스트를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _postService.deletePost(widget.postId);

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('포스트가 삭제되었습니다.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('포스트 삭제에 실패했습니다.')),
      );
    }
  }

  Future<void> _handleEdit() async {
    if (_post == null) return;

    // TODO: 게시글 수정 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('게시글 수정 기능은 아직 구현되지 않았습니다.')),
    );
  }

  Widget _buildMediaCarousel(List<MediaModel> media) {
    return CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 16 / 9,
        viewportFraction: 1.0,
        enableInfiniteScroll: false,
      ),
      items: media.map((item) {
        if (item.type == MediaType.image) {
          return Image.network(
            item.url,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.error),
              );
            },
          );
        } else {
          // TODO: 비디오 플레이어 구현
          return Container(
            color: Colors.black,
            child: const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 64,
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('포스트 상세'),
        actions: [
          if (_post != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _handleEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _handleDelete,
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPost,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_post == null) {
      return const Center(
        child: Text('포스트를 찾을 수 없습니다.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 미디어
          if (_post!.media.isNotEmpty) _buildMediaCarousel(_post!.media),

          const SizedBox(height: 16),

          // 제목
          Text(
            _post!.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 8),

          // 메타 정보
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 4),
              Text(
                _post!.createdAt.toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (_post!.location != null) ...[
                const SizedBox(width: 16),
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _post!.location!.name ?? _post!.location!.address ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // 내용
          Text(_post!.content),

          const SizedBox(height: 16),

          // 태그
          if (_post!.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _post!.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
