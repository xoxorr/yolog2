import 'package:flutter/material.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../widgets/profile_sidebar.dart';
import '../../../core/routes/routes.dart';

class ProfileLayout extends StatefulWidget {
  final String title;
  final Widget child;

  const ProfileLayout({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  State<ProfileLayout> createState() => _ProfileLayoutState();
}

class _ProfileLayoutState extends State<ProfileLayout> {
  bool _isSidebarOpen = true;

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Yolog',
        centerTitle: false,
        showSearchBox: false,
        isSidebarOpen: _isSidebarOpen,
        leading: IconButton(
          icon: Icon(
            _isSidebarOpen ? Icons.menu : Icons.menu,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: _toggleSidebar,
        ),
        onTap: () => Navigator.pushNamed(context, Routes.home),
      ),
      body: Row(
        children: [
          Container(
            width: _isSidebarOpen ? 200 : 0,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(),
            child: const ProfileSidebar(),
          ),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
