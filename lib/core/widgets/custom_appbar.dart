import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/widgets/login_dialog.dart';
import '../providers/theme_provider.dart';
import '../routes/routes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final Widget? leading;
  final Function(String)? onSearch;
  final bool showSearchBox;
  final double elevation;
  final VoidCallback? onTap;
  final bool? isSidebarOpen;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.leading,
    this.onSearch,
    this.showSearchBox = true,
    this.elevation = 0,
    this.onTap,
    this.isSidebarOpen,
    this.actions,
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
        color: Colors.transparent,
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
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            leading: leading ??
                (isSidebarOpen != null
                    ? Icon(
                        isSidebarOpen! ? Icons.menu_open : Icons.menu,
                        color: Theme.of(context).iconTheme.color,
                      )
                    : null),
            title: Row(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          letterSpacing: 1.2,
                        ),
                  ),
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
              ],
            ),
            centerTitle: centerTitle,
            actions: actions ?? [
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
                      offset: const Offset(0, 8),
                      position: PopupMenuPosition.under,
                      icon: CircleAvatar(
                        backgroundImage: authProvider.currentUser?.photoURL !=
                                null
                            ? NetworkImage(authProvider.currentUser!.photoURL!)
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
                          child: Row(
                            children: [
                              Icon(Icons.person_outline),
                              SizedBox(width: 8),
                              Text('프로필'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(Icons.settings_outlined),
                              SizedBox(width: 8),
                              Text('설정'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout_outlined),
                              SizedBox(width: 8),
                              Text('로그아웃'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'profile':
                            Navigator.pushNamed(context, Routes.profile);
                            break;
                          case 'settings':
                            // TODO: 설정 화면으로 이동
                            break;
                          case 'logout':
                            authProvider.signOut();
                            break;
                        }
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
        ),
      ),
    );
  }
}
