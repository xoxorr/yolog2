import 'package:flutter/material.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('업데이트 소식'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          UpdateCard(
            version: '2.1.0',
            date: '2024.01.15',
            changes: [
              '• 소셜 기능 추가 - 팔로우, 좋아요, 댓글 기능이 추가되었습니다',
              '• UI/UX 개선 - 더욱 직관적인 인터페이스로 개선되었습니다',
              '• 버그 수정 및 성능 개선',
            ],
          ),
          SizedBox(height: 16),
          UpdateCard(
            version: '2.0.0',
            date: '2023.12.20',
            changes: [
              '• 새로운 디자인 적용',
              '• 다크모드 지원',
              '• 안정성 개선',
            ],
          ),
        ],
      ),
    );
  }
}

class UpdateCard extends StatelessWidget {
  final String version;
  final String date;
  final List<String> changes;

  const UpdateCard({
    super.key,
    required this.version,
    required this.date,
    required this.changes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Version $version',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...changes.map((change) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(change),
                )),
          ],
        ),
      ),
    );
  }
}
