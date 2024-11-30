import 'package:flutter/material.dart';
import '../services/follow_service.dart';

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
  late TabController _tabController;
  final FollowService _followService = FollowService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('팔로우'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '팔로워'),
            Tab(text: '팔로잉'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FollowList(
            userId: widget.userId,
            getFollows: _followService.getFollowers,
          ),
          _FollowList(
            userId: widget.userId,
            getFollows: _followService.getFollowing,
          ),
        ],
      ),
    );
  }
}

class _FollowList extends StatefulWidget {
  final String userId;
  final Future<List<dynamic>> Function(String,
      {String? lastFollowId, int limit}) getFollows;

  const _FollowList({
    required this.userId,
    required this.getFollows,
  });

  @override
  State<_FollowList> createState() => _FollowListState();
}

class _FollowListState extends State<_FollowList> {
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _follows = [];
  String? _lastFollowId;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadFollows();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFollows() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    try {
      final follows = await widget.getFollows(
        widget.userId,
        lastFollowId: _lastFollowId,
      );

      if (follows.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        setState(() {
          _follows.addAll(follows);
          _lastFollowId = follows.last.id;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadFollows();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_follows.isEmpty) {
      if (_isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return const Center(child: Text('팔로우가 없습니다.'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _follows.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _follows.length) {
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink();
        }

        final follow = _follows[index];
        final userId = follow.followerId == widget.userId
            ? follow.followingId
            : follow.followerId;

        return FutureBuilder(
          future:
              FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const ListTile(
                leading: CircleAvatar(),
                title: Text('로딩 중...'),
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: userData['photoUrl'] != null
                    ? NetworkImage(userData['photoUrl'])
                    : null,
                child: userData['photoUrl'] == null
                    ? Text(userData['username'][0].toUpperCase())
                    : null,
              ),
              title: Text(userData['username'] ?? '알 수 없는 사용자'),
              subtitle: Text('팔로워 ${userData['followerCount'] ?? 0}명'),
              onTap: () {
                // TODO: 사용자 프로필 화면으로 이동
              },
            );
          },
        );
      },
    );
  }
}
