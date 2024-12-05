import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
                  // TODO: 메뉴 액션 처리
                },
              ),
            ),

            // 미디어
            if (post.media.isNotEmpty) ...[
              CarouselSlider(
                options: CarouselOptions(
                  aspectRatio: 1,
                  viewportFraction: 1,
                  enableInfiniteScroll: false,
                ),
                items: post.media.map((media) {
                  if (media.type == MediaType.image) {
                    return Image.network(
                      media.url,
                      fit: BoxFit.cover,
                    );
                  } else {
                    // TODO: 비디오 플레이어 구현
                    return const Center(child: Icon(Icons.play_circle));
                  }
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],

            // 내용
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            // 태그
            if (post.tags.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  children: post.tags.map((tag) {
                    return Chip(
                      label: Text('#$tag'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ),

            // 위치
            if (post.location != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        post.location!.name ?? post.location!.address ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

            const Divider(),

            // 액션 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.favorite_border,
                  label: '${post.likeCount}',
                  onTap: onLike,
                ),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: '${post.commentCount}',
                  onTap: onComment,
                ),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: '공유',
                  onTap: onShare,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.year}.${date.month}.${date.day}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
