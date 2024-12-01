import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../features/auth/widgets/login_dialog.dart';
import '../providers/theme_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final Widget? leading;
  final Function(String)? onSearch;
  final bool showSearchBox;
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.leading,
    this.onSearch,
    this.showSearchBox = true,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LoginDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation,
                )
              ]
            : null,
      ),
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: AppBar(
            backgroundColor: Colors.transparent,
            leading: leading,
            title: Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (showSearchBox)
                  Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '검색어를 입력하세요',
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.search, size: 20),
                                onPressed: () {
                                  onSearch?.call('');
                                },
                              ),
                            ],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onSubmitted: onSearch,
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    Theme.of(context).brightness == Brightness.light
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                ),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.currentUser != null) {
                      return PopupMenuButton(
                        icon: CircleAvatar(
                          backgroundImage:
                              authProvider.currentUser?.photoURL != null
                                  ? NetworkImage(
                                      authProvider.currentUser!.photoURL!)
                                  : null,
                          child: authProvider.currentUser?.photoURL == null
                              ? Text(
                                  authProvider.currentUser?.displayName
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      '?',
                                )
                              : null,
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'profile',
                            child: Text('프로필'),
                          ),
                          const PopupMenuItem(
                            value: 'settings',
                            child: Text('설정'),
                          ),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Text('로그아웃'),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'logout') {
                            authProvider.signOut();
                          }
                          // TODO: 다른 메뉴 항목 처리
                        },
                      );
                    } else {
                      return TextButton(
                        onPressed: () => _showLoginDialog(context),
                        child: const Text('로그인'),
                      );
                    }
                  },
                ),
              ],
            ),
            centerTitle: centerTitle,
            elevation: elevation,
          ),
        ),
      ),
    );
  }
}
