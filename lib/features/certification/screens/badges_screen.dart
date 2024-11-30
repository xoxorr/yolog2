import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import '../services/badge_service.dart';

class BadgesScreen extends StatefulWidget {
  final String userId;

  const BadgesScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BadgeService _badgeService;
  Map<String, dynamic>? _badgeStats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _badgeService = BadgeService(userId: widget.userId);
    _loadBadgeStats();
  }

  Future<void> _loadBadgeStats() async {
    final stats = await _badgeService.getBadgeStats();
    setState(() {
      _badgeStats = stats;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 뱃지'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '획득한 뱃지'),
            Tab(text: '추천 뱃지'),
            Tab(text: '통계'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUnlockedBadgesTab(),
          _buildRecommendedBadgesTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  Widget _buildUnlockedBadgesTab() {
    return FutureBuilder<List<Badge>>(
      future: _badgeService.getUserBadges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final badges = snapshot.data ?? [];
        if (badges.isEmpty) {
          return const Center(
            child: Text('아직 획득한 뱃지가 없습니다.'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            return _buildBadgeCard(badge);
          },
        );
      },
    );
  }

  Widget _buildRecommendedBadgesTab() {
    return FutureBuilder<List<Badge>>(
      future: _badgeService.getRecommendedBadges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final badges = snapshot.data ?? [];
        if (badges.isEmpty) {
          return const Center(
            child: Text('추천할 뱃지가 없습니다.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            return _buildRecommendedBadgeCard(badge);
          },
        );
      },
    );
  }

  Widget _buildStatsTab() {
    if (_badgeStats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            '총 획득 뱃지',
            _badgeStats!['total'].toString(),
            Icons.military_tech,
          ),
          const SizedBox(height: 16),
          _buildRarityStats(),
          const SizedBox(height: 16),
          _buildCategoryStats(),
          const SizedBox(height: 16),
          _buildStatCard(
            '총 획득 포인트',
            '${_badgeStats!['totalPoints']} 포인트',
            Icons.stars,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(Badge badge) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _showBadgeDetails(badge),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                badge.iconUrl,
                width: 64,
                height: 64,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error_outline, size: 64);
                },
              ),
              const SizedBox(height: 8),
              Text(
                badge.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                badge.rarity,
                style: TextStyle(
                  color: _getRarityColor(badge.rarity),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedBadgeCard(Badge badge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Image.network(
          badge.iconUrl,
          width: 48,
          height: 48,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error_outline, size: 48);
          },
        ),
        title: Text(badge.name),
        subtitle: Text(badge.description),
        trailing: FutureBuilder<Map<String, double>>(
          future: _badgeService.getBadgeProgress(badge.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }

            final progress = snapshot.data!.values
                    .fold<double>(0, (sum, value) => sum + value) /
                snapshot.data!.length;

            return CircularProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
            );
          },
        ),
        onTap: () => _showBadgeDetails(badge),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRarityStats() {
    final rarityStats = _badgeStats!['byRarity'] as Map<String, dynamic>;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '희귀도별 통계',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...rarityStats.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        color: _getRarityColor(entry.key),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${entry.value}개'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStats() {
    final categoryStats = _badgeStats!['byCategory'] as Map<String, dynamic>;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '카테고리별 통계',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...categoryStats.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(entry.key),
                    const SizedBox(width: 8),
                    Text('${entry.value}개'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(Badge badge) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                badge.iconUrl,
                width: 96,
                height: 96,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error_outline, size: 96);
                },
              ),
              const SizedBox(height: 16),
              Text(
                badge.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                badge.description,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '획득 조건',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...badge.requirements.entries.map((entry) {
                return Text('${entry.key}: ${entry.value}');
              }),
              const SizedBox(height: 16),
              Text(
                '포인트: ${badge.points}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }
}
