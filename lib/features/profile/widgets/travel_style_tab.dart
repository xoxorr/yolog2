import 'package:flutter/material.dart';

class TravelStyleTab extends StatelessWidget {
  const TravelStyleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 선호하는 여행 스타일 카드
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '선호하는 여행 스타일',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        // TODO: 여행 스타일 편집
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStyleChip('자연 탐방'),
                    _buildStyleChip('문화 체험'),
                    _buildStyleChip('맛집 탐방'),
                    _buildStyleChip('액티비티'),
                    // TODO: 실제 데이터로 교체
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 선호하는 여행지 카드
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '선호하는 여행지',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                // TODO: 선호 여행지 목록 추가
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 여행 성향 분석 카드
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '여행 성향 분석',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                // TODO: 여행 성향 차트 추가
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.blue.withOpacity(0.1),
    );
  }
}
