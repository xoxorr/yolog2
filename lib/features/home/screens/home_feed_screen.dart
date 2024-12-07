import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../post/services/post_service.dart';
import '../../post/models/post_model.dart';
import '../../post/widgets/post_card.dart';

class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PostModel>>(
      stream: context.read<PostService>().getPostsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!;
        if (posts.isEmpty) {
          return const Center(child: Text('게시글이 없습니다.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PostCard(post: post),
            );
          },
        );
      },
    );
  }
}
