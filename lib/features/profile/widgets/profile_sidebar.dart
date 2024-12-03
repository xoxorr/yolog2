import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';

class ProfileSidebar extends StatelessWidget {
  const ProfileSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Text(
                    '프로필 관리',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline,
                  title: '프로필 설정',
                  onTap: () {
                    // TODO: 프로필 설정 화면으로 이동
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.style_outlined,
                  title: '여행 스타일',
                  onTap: () {
                    // TODO: 여행 스타일 설정 화면으로 이동
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.history,
                  title: '여행 히스토리',
                  onTap: () {
                    // TODO: 여행 히스토리 화면으로 이동
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.analytics_outlined,
                  title: '통계',
                  onTap: () {
                    // TODO: 통계 화면으로 이동
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: '설정',
                  onTap: () {
                    // TODO: 설정 화면으로 이동
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected
            ? Theme.of(context).primaryColor
            : Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: selected ? FontWeight.w600 : null,
        ),
      ),
      onTap: onTap,
      selected: selected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }
}
