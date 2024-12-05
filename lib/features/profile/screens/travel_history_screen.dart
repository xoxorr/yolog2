import 'package:flutter/material.dart';
import '../widgets/profile_layout.dart';

class TravelHistoryScreen extends StatelessWidget {
  const TravelHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileLayout(
      title: '여행 히스토리',
      child: Center(
        child: Text('여행 히스토리 화면 (개발 중)'),
      ),
    );
  }
}
