import 'package:flutter/material.dart';
import '../widgets/profile_layout.dart';

class TravelStyleScreen extends StatelessWidget {
  const TravelStyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileLayout(
      title: '여행 스타일',
      child: Center(
        child: Text('여행 스타일 화면 (개발 중)'),
      ),
    );
  }
}
