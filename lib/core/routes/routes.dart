import 'package:flutter/material.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/profile_settings_screen.dart';
import '../../features/profile/screens/travel_history_screen.dart';
import '../../features/profile/screens/travel_style_screen.dart';
import '../../features/profile/screens/statistics_screen.dart';
import '../../features/profile/screens/settings_screen.dart';

class Routes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String profileSettings = '/profile/settings';
  static const String travelHistory = '/profile/history';
  static const String travelStyle = '/profile/style';
  static const String statistics = '/profile/statistics';
  static const String settings = '/settings';
  static const String profileScreen = '/profile/main';

  // initial route 추가
  static const String initial = home;

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      profile: (context) => const ProfileScreen(),
      profileSettings: (context) => const ProfileSettingsScreen(),
      travelHistory: (context) => const TravelHistoryScreen(),
      travelStyle: (context) => const TravelStyleScreen(),
      statistics: (context) => const StatisticsScreen(),
      settings: (context) => const SettingsScreen(),
      profileScreen: (context) => const ProfileScreen(),
    };
  }

  // onGenerateRoute 추가
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const HomeScreen(),
    );
  }

  // onUnknownRoute 추가
  static Route<dynamic>? onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const HomeScreen(),
    );
  }
}
