import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/follow_service.dart';

class FeaturedMembersScreen extends StatefulWidget {
  const FeaturedMembersScreen({super.key});

  @override
  State<FeaturedMembersScreen> createState() => _FeaturedMembersScreenState();
}

class _FeaturedMembersScreenState extends State<FeaturedMembersScreen> {
  final FollowService _followService = FollowService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추천 멤버'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .orderBy('followerCount', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs;
                if (users.isEmpty) {
                  return const Center(child: Text('추천할 멤버가 없습니다.'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index].data() as Map<String, dynamic>;
                    final userId = users[index].id;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user['photoUrl'] != null
                            ? NetworkImage(user['photoUrl'])
                            : null,
                        child: user['photoUrl'] == null
                            ? Text(user['username'][0].toUpperCase())
                            : null,
                      ),
                      title: Text(user['username'] ?? '알 수 없는 사용자'),
                      subtitle: Text('팔로워 ${user['followerCount'] ?? 0}명'),
                      trailing:
                          _currentUserId != null && userId != _currentUserId
                              ? FutureBuilder<bool>(
                                  future: _followService.isFollowing(
                                    _currentUserId!,
                                    userId,
                                  ),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const SizedBox.shrink();
                                    }

                                    final isFollowing = snapshot.data!;
                                    return TextButton(
                                      onPressed: () => _toggleFollow(userId),
                                      child: Text(isFollowing ? '언팔로우' : '팔로우'),
                                    );
                                  },
                                )
                              : null,
                      onTap: () {
                        // TODO: 사용자 프로필 화면으로 이동
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  Future<void> _toggleFollow(String userId) async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);
    try {
      final isFollowing =
          await _followService.isFollowing(_currentUserId!, userId);
      if (isFollowing) {
        await _followService.unfollow(_currentUserId!, userId);
      } else {
        await _followService.follow(_currentUserId!, userId);
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
}
