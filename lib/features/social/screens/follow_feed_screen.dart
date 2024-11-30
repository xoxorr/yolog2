import 'package:flutter/material.dart';
import '../services/follow_service.dart';
import '../services/tag_service.dart';

class FollowFeedScreen extends StatefulWidget {
  final String userId;

  const FollowFeedScreen({
    super.key,
    required this.userId,
  });

  @override
  State<FollowFeedScreen> createState() => _FollowFeedScreenState();
}

class _FollowFeedScreenState extends State<FollowFeedScreen>
    with SingleTickerProviderStateMixin {
  final FollowService _followService = FollowService();
  final TagService _tagService = TagService();
  late TabController _tabController;
  List<dynamic> _followers = [];
  List<dynamic> _following = [];
  List<dynamic> _trendingTags = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        _followService.getFollowers(widget.userId),
        _followService.getFollowing(widget.userId),
        _tagService.getTrendingTags(),
      ]);

      setState(() {
        _followers = results[0];
        _following = results[1];
        _trendingTags = results[2];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '데이터를 불러오는데 실패했습니다.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('팔로우 피드'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '팔로워'),
            Tab(text: '팔로잉'),
            Tab(text: '인기 태그'),
          ],
        ),
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
              onPressed: _loadData,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildFollowersList(),
        _buildFollowingList(),
        _buildTrendingTagsList(),
      ],
    );
  }

  Widget _buildFollowersList() {
    if (_followers.isEmpty) {
      return const Center(
        child: Text('팔로워가 없습니다.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _followers.length,
        itemBuilder: (context, index) {
          final follower = _followers[index];
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(follower.followerId),
            trailing: FutureBuilder<bool>(
              future: _followService.isFollowing(
                widget.userId,
                follower.followerId,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                return snapshot.data!
                    ? OutlinedButton(
                        onPressed: () async {
                          await _followService.unfollow(
                            widget.userId,
                            follower.followerId,
                          );
                          _loadData();
                        },
                        child: const Text('팔로잉'),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          await _followService.follow(
                            widget.userId,
                            follower.followerId,
                          );
                          _loadData();
                        },
                        child: const Text('팔로우'),
                      );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFollowingList() {
    if (_following.isEmpty) {
      return const Center(
        child: Text('팔로잉하는 사용자가 없습니다.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _following.length,
        itemBuilder: (context, index) {
          final following = _following[index];
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(following.followingId),
            trailing: OutlinedButton(
              onPressed: () async {
                await _followService.unfollow(
                  widget.userId,
                  following.followingId,
                );
                _loadData();
              },
              child: const Text('팔로잉'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingTagsList() {
    if (_trendingTags.isEmpty) {
      return const Center(
        child: Text('인기 태그가 없습니다.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _trendingTags.length,
        itemBuilder: (context, index) {
          final tag = _trendingTags[index];
          return ListTile(
            leading: const Icon(Icons.tag),
            title: Text('#${tag.name}'),
            subtitle: Text('${tag.usageCount} 회 사용됨'),
            trailing: FutureBuilder<Map<String, dynamic>>(
              future: _tagService.getTagStats(tag.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                final stats = snapshot.data!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '일일 평균: ${stats['averageUsagePerDay'].toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${stats['daysActive']}일 동안 활성화',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
            onTap: () {
              // TODO: Navigate to tag detail screen
            },
          );
        },
      ),
    );
  }
}
