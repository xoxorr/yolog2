import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 설정 화면으로 이동
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 헤더
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      // TODO: 사용자 프로필 이미지 추가
                      child: Icon(Icons.person, size: 50),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '사용자 이름', // TODO: 실제 사용자 이름으로 변경
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'user@email.com', // TODO: 실제 이메일로 변경
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 프로필 메뉴 아이템들
              _buildMenuItem(
                icon: Icons.person_outline,
                title: '개인정보 수정',
                onTap: () {
                  // TODO: 개인정보 수정 화면으로 이동
                },
              ),
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: '알림 설정',
                onTap: () {
                  // TODO: 알림 설정 화면으로 이동
                },
              ),
              _buildMenuItem(
                icon: Icons.security_outlined,
                title: '보안 설정',
                onTap: () {
                  // TODO: 보안 설정 화면으로 이동
                },
              ),
              _buildMenuItem(
                icon: Icons.help_outline,
                title: '도움말',
                onTap: () {
                  // TODO: 도움말 화면으로 이동
                },
              ),
              _buildMenuItem(
                icon: Icons.logout,
                title: '로그아웃',
                onTap: () async {
                  // TODO: 로그아웃 구현
                  final authService = context.read<AuthService>();
                  await authService.signOut();
                  if (!mounted) return;
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
