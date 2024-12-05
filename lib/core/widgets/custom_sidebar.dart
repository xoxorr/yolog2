import 'package:flutter/material.dart';

class CustomSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isCompact;

  const CustomSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCompact ? 0 : 200,
      color: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionTitle(context, '내 콘텐츠'),
          _buildMenuItem(
            context,
            index: 0,
            icon: Icons.home_outlined,
            title: '홈 피드',
          ),
          _buildMenuItem(
            context,
            index: 1,
            icon: Icons.trending_up_outlined,
            title: '인기 콘텐츠',
          ),
          _buildMenuItem(
            context,
            index: 2,
            icon: Icons.bookmark_border_outlined,
            title: '북마크',
          ),
          _buildMenuItem(
            context,
            index: 3,
            icon: Icons.history_outlined,
            title: '히스토리',
          ),
          _buildMenuItem(
            context,
            index: 4,
            icon: Icons.edit_outlined,
            title: '글쓰기',
          ),
          const SizedBox(height: 16),
          _buildSectionTitle(context, '탐색 및 소셜'),
          _buildMenuItem(
            context,
            index: 5,
            icon: Icons.people_outline,
            title: '주목받는 멤버',
          ),
          _buildMenuItem(
            context,
            index: 6,
            icon: Icons.rss_feed_outlined,
            title: '팔로우 피드',
          ),
          _buildMenuItem(
            context,
            index: 7,
            icon: Icons.tag_outlined,
            title: '태그 탐색',
          ),
          const SizedBox(height: 16),
          _buildSectionTitle(context, '안내'),
          _buildMenuItem(
            context,
            index: 8,
            icon: Icons.update_outlined,
            title: '업데이트',
          ),
          _buildMenuItem(
            context,
            index: 9,
            icon: Icons.help_outline,
            title: '고객센터',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
  }) {
    final isSelected = index == selectedIndex;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: ListTile(
        dense: true,
        selected: isSelected,
        selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.1),
        leading: Icon(
          icon,
          color: isSelected ? theme.colorScheme.primary : null,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? theme.colorScheme.primary : null,
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        ),
        onTap: () => onItemTapped(index),
      ),
    );
  }
}
