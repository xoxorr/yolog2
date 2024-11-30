import 'package:flutter/material.dart';
import '../services/share_service.dart';

class ShareScreen extends StatefulWidget {
  final String contentId;

  const ShareScreen({
    super.key,
    required this.contentId,
  });

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final ShareService _shareService = ShareService();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  String? _currentUserId;

  final List<Map<String, dynamic>> _platforms = [
    {
      'id': 'facebook',
      'name': 'Facebook',
      'icon': Icons.facebook,
      'color': Colors.blue,
    },
    {
      'id': 'twitter',
      'name': 'Twitter',
      'icon': Icons.flutter_dash,
      'color': Colors.lightBlue,
    },
    {
      'id': 'instagram',
      'name': 'Instagram',
      'icon': Icons.camera_alt,
      'color': Colors.purple,
    },
  ];

  Future<void> _shareContent(String platform) async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);
    try {
      await _shareService.shareContent(
        _currentUserId!,
        widget.contentId,
        platform,
        message: _messageController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('콘텐츠를 공유했습니다.')),
        );
        Navigator.of(context).pop();
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

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공유하기'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '공유 메시지를 입력하세요...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '공유할 플랫폼 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _platforms.length,
                    itemBuilder: (context, index) {
                      final platform = _platforms[index];
                      return ElevatedButton.icon(
                        onPressed: () => _shareContent(platform['id']),
                        icon: Icon(platform['icon']),
                        label: Text(platform['name']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: platform['color'],
                          foregroundColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
