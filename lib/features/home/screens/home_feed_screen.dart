import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../post/services/post_service.dart';
import '../../post/models/post_model.dart';
import '../widgets/post_card.dart';

class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);

  List<PostModel> _getDummyPosts() {
    return [
      PostModel(
        id: '1',
        title: '첫 번째 게시글',
        content: '오늘은 날씨가 정말 좋습니다. 공원에서 산책하면서 여유로운 시간을 보냈어요.',
        authorId: 'user1',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PostModel(
        id: '2',
        title: '맛있는 레시피 공유',
        content: '오늘은 특별한 파스타 레시피를 공유합니다. 간단하면서도 맛있는 요리를 만들어보세요.',
        authorId: 'user2',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      PostModel(
        id: '3',
        title: '여행 이야기',
        content: '제주도 여행 중입니다. 아름다운 풍경과 맛있는 음식들이 정말 좋네요.',
        authorId: 'user3',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PostModel(
        id: '4',
        title: '독서 모임 후기',
        content: '오늘 독서 모임에서 좋은 사람들과 의미 있는 대화를 나눴습니다.',
        authorId: 'user4',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PostModel>>(
      stream: context.read<PostService>().getPostsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('오류가 발생했습니다: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final posts = snapshot.data ?? _getDummyPosts();
        if (posts.isEmpty) {
          return const Center(
            child: Text('게시글이 없습니다'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostCard(post: post);
          },
        );
      },
    );
  }
}
