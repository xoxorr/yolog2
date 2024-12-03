import 'package:flutter/material.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/post/screens/create_post_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String createPost = '/post/create';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initial: (context) => const HomeScreen(),
      home: (context) => const HomeScreen(),
      login: (context) => const HomeScreen(),
      signup: (context) => const HomeScreen(),
      forgotPassword: (context) => const HomeScreen(),
      createPost: (context) => const CreatePostScreen(),
    };
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const Scaffold(
        body: Center(
          child: Text('페이지를 찾을 수 없습니다.'),
        ),
      ),
    );
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const Scaffold(
        body: Center(
          child: Text('알 수 없는 오류가 발생했습니다.'),
        ),
      ),
    );
  }
}
