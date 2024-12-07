import 'package:flutter/material.dart';
import '../../support/screens/update_screen.dart';
import '../../support/screens/support_center_screen.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/widgets/custom_sidebar.dart';
import '../../../core/routes/routes.dart';
import 'home_feed_screen.dart';
import '../../post/screens/create_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isDrawerOpen = true;

  final List<Widget> _pages = [
    const HomeFeedScreen(),
    const Center(child: Text('인기 콘텐츠')),
    const Center(child: Text('북마크')),
    const Center(child: Text('히스토리')),
    const CreatePostScreen(),
    const Center(child: Text('주목받는 멤버')),
    const Center(child: Text('팔로우 피드')),
    const Center(child: Text('태그 탐색')),
    const UpdateScreen(),
    const SupportCenterScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Yolog',
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _toggleDrawer,
        ),
        onTap: () => Navigator.pushNamed(context, Routes.home),
        onSearch: (query) {
          // TODO: 검색 기능 구현
          print('Search query: $query');
        },
      ),
      body: Row(
        children: [
          if (_isDrawerOpen)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 200,
              child: CustomSidebar(
                selectedIndex: _selectedIndex,
                onItemTapped: (index) {
                  _onItemTapped(index);
                  if (isSmallScreen) {
                    _toggleDrawer();
                  }
                },
              ),
            ),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
