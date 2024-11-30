import 'package:flutter/material.dart';
import '../services/follow_service.dart';

class FeaturedMembersScreen extends StatefulWidget {
  final String userId;

  const FeaturedMembersScreen({
    super.key,
    required this.userId,
  });

  @override
  State<FeaturedMembersScreen> createState() => _FeaturedMembersScreenState();
}

class _FeaturedMembersScreenState extends State<FeaturedMembersScreen> {
  final FollowService _followService = FollowService();
  List<String> _recommendedUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecommendedUsers();
  }

  Future<void> _loadRecommendedUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final users = await _followService.getRecommendedFollows(widget.userId);
      setState(() {
        _recommendedUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '추천 회원을 불러오는데 실패했습니다.';
        _isLoading = false;
      });
    }
  }

  Future<void> _followUser(String userId) async {
    try {
      await _followService.follow(widget.userId, userId);
      setState(() {
        _recommendedUsers.remove(userId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('팔로우했습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('팔로우에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추천 회원'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecommendedUsers,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_recommendedUsers.isEmpty) {
      return const Center(
        child: Text('추천할 회원이 없습니다.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecommendedUsers,
      child: ListView.builder(
        itemCount: _recommendedUsers.length,
        itemBuilder: (context, index) {
          final userId = _recommendedUsers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              // TODO: 사용자 프로필 이미지 및 정보 표시
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text('User $userId'),
              subtitle: FutureBuilder<int>(
                future: _followService.getFollowersCount(userId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text('팔로워 ${snapshot.data} 명');
                  }
                  return const SizedBox.shrink();
                },
              ),
              trailing: ElevatedButton(
                onPressed: () => _followUser(userId),
                child: const Text('팔로우'),
              ),
              onTap: () {
                // TODO: Navigate to user profile screen
              },
            ),
          );
        },
      ),
    );
  }
}
