import 'package:flutter/material.dart';
import '../../../core/routes/routes.dart';

class ProfileSidebar extends StatelessWidget {
  const ProfileSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildSectionTitle(context, '프로필'),
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline,
                  title: '프로필',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.profileScreen);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: '프로필 설정',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.profileSettings);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.history,
                  title: '여행 히스토리',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.travelHistory);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.style_outlined,
                  title: '여행 스타일',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.travelStyle);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.analytics_outlined,
                  title: '통계',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.statistics);
                  },
                ),
                const SizedBox(height: 16),
                _buildSectionTitle(context, '설정'),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: '설정',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.settings);
                  },
                ),
              ],
            ),
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
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: ListTile(
        dense: true,
        selected: selected,
        selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.1),
        leading: Icon(
          icon,
          color: selected ? theme.colorScheme.primary : null,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: selected ? theme.colorScheme.primary : null,
            fontWeight: selected ? FontWeight.bold : null,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
