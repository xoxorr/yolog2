import 'package:go_router/go_router.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/home_feed_screen.dart';
import '../features/post/screens/post_detail_screen.dart';
import '../features/post/screens/create_post_screen.dart';
import '../features/post/screens/edit_post_screen.dart';
import '../features/post/models/post_model.dart';

final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => HomeScreen(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeFeedScreen(),
        ),
        GoRoute(
          path: '/post/:id',
          builder: (context, state) => PostDetailScreen(
            postId: state.params['id']!,
          ),
        ),
        GoRoute(
          path: '/post/create',
          builder: (context, state) => const CreatePostScreen(),
        ),
        GoRoute(
          path: '/post/edit/:id',
          builder: (context, state) => EditPostScreen(
            post: state.extra as PostModel,
          ),
        ),
        // ... 기타 라우트
      ],
    ),
  ],
);
