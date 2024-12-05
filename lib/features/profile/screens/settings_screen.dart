import 'package:flutter/material.dart';
import '../widgets/profile_layout.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileLayout(
      title: '설정',
      child: Center(
        child: Text('설정 화면 (개발 중)'),
      ),
    );
  }
}
