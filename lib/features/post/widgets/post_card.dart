import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import '../models/post_model.dart';
import '../models/media_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const PostCard({
    Key? key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onShare,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return DateFormat('yyyy년 MM월 dd일').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            ListTile(
              leading: const CircleAvatar(
                // TODO: 사용자 프로필 이미지
                child: Icon(Icons.person),
              ),
              title: const Text('사용자 이름'), // TODO: 실제 사용자 이름
              subtitle: Text(
                _formatDate(post.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('수정'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('삭제'),
                  ),
                ],
                onSelected: (value) {
                  // TODO: 수정/삭제 기능 구현
                },
              ),
            ),

            // 제목
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                post.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            // 미디어 (이미지/비디오)
            if (post.media.isNotEmpty) ...[
              CarouselSlider(
                options: CarouselOptions(
                  aspectRatio: 16 / 9,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: false,
                ),
                items: post.media.map((media) {
                  if (media.type == 'image') {
                    return Image.network(
                      media.url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.error),
                        );
                      },
                    );
                  }
                  return const SizedBox(); // 비디오는 나중에 구현
                }).toList(),
              ),
            ],

            // 내용
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                post.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 태그
            if (post.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: post.tags.map((tag) {
                    return Chip(
                      label: Text('#$tag'),
                      backgroundColor: Colors.grey[200],
                    );
                  }).toList(),
                ),
              ),

            // 위치
            if (post.location != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      post.location!.name ?? post.location!.address ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

            // 액션 버튼
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActionButton(
                    icon: Icons.favorite_border,
                    label: '${post.likeCount}',
                    onTap: onLike,
                  ),
                  ActionButton(
                    icon: Icons.comment,
                    label: '${post.commentCount}',
                    onTap: onComment,
                  ),
                  ActionButton(
                    icon: Icons.share,
                    label: '공유',
                    onTap: onShare,
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

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
