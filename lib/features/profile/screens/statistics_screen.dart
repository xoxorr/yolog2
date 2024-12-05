import 'package:flutter/material.dart';
import '../widgets/profile_layout.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileLayout(
      title: '통계',
      child: Center(
        child: Text('통계 화면 (개발 중)'),
      ),
    );
  }
}
