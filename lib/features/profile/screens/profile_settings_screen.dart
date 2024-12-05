import 'package:flutter/material.dart';
import '../widgets/profile_layout.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileLayout(
      title: '프로필 설정',
      child: Center(
        child: Text('프로필 설정 화면 (개발 중)'),
      ),
    );
  }
}
