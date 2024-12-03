import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/routes/app_routes.dart';
import '../services/profile_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/profile_sidebar.dart';
import '../models/profile_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileView();
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      context.read<ProfileService>().loadProfile(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'YOLOG',
        centerTitle: false,
        leading: Container(),
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.initial,
            (route) => false,
          );
        },
      ),
      body: Row(
        children: [
          // 고정 사이드바
          const ProfileSidebar(),
          // 메인 컨텐츠
          Expanded(
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
                      // 프로필 헤더
                      _buildProfileHeader(profile),
                      const SizedBox(height: 24),
                      // 프로필 컨텐츠
                      _buildProfileContent(profile),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ProfileModel profile) {
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

  Widget _buildProfileContent(ProfileModel profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 여행 스타일 섹션
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
                // TODO: 여행 스타일 내용 추가
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 여행 통계 섹션
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
                // TODO: 통계 내용 추가
              ],
            ),
          ),
        ),
      ],
    );
  }
}
