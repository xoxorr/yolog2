import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../models/profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/profile_layout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final profileService = context.read<ProfileService>();
          profileService.loadProfile(user.uid);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfileLayout(
      title: '프로필',
      child: Consumer<ProfileService>(
        builder: (context, profileService, child) {
          if (profileService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = profileService.profile;
          if (profile == null) {
            return const Center(child: Text('프로필을 불러올 수 없습니다.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, profile),
                const SizedBox(height: 24),
                _buildProfileContent(context, profile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileModel profile) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage:
              profile.photoURL != null ? NetworkImage(profile.photoURL!) : null,
          child: profile.photoURL == null
              ? Text(
                  profile.displayName?.substring(0, 1).toUpperCase() ?? '?',
                  style: const TextStyle(fontSize: 32),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName ?? '이름 없음',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (profile.bio != null) ...[
                const SizedBox(height: 4),
                Text(
                  profile.bio!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // TODO: 프로필 편집 화면으로 이동
          },
        ),
      ],
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileModel profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '여행 스타일',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                // TODO: 여행 타일 내용 추가
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '여행 통계',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                // TODO: 통계 내용 가
              ],
            ),
          ),
        ),
      ],
    );
  }
}
