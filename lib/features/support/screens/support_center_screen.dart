import 'package:flutter/material.dart';

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('고객센터'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SupportHeader(),
          const Divider(height: 1),
          ...supportItems.map((item) => SupportItem(
                title: item.title,
                content: item.content,
              )),
        ],
      ),
    );
  }
}

class SupportHeader extends StatelessWidget {
  const SupportHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          Text(
            '무엇을 도와드릴까요?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '자주 묻는 질문들을 확인해보세요',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class SupportItem extends StatelessWidget {
  final String title;
  final String content;

  const SupportItem({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class FAQItem {
  final String title;
  final String content;

  const FAQItem({
    required this.title,
    required this.content,
  });
}

final supportItems = [
  const FAQItem(
    title: '앱 이용 방법',
    content:
        '여행 일지를 작성하고 공유하는 방법은 간단합니다. 메인 화면의 + 버튼을 눌러 새로운 일지를 작성하고, 사진과 글을 추가한 후 저장하면 됩니다.',
  ),
  const FAQItem(
    title: '계정 관리',
    content:
        '계정 설정에서 프로필 정보를 수정하고, 알림 설정을 변경할 수 있습니다. 비밀번호 변경이나 계정 삭제도 계정 설정에서 가능합니다.',
  ),
  const FAQItem(
    title: '개인정보 보호',
    content: '사용자의 개인정보는 암호화되어 안전하게 보관됩니다. 게시물의 공개 범위는 설정에서 변경할 수 있습니다.',
  ),
  const FAQItem(
    title: '알림 설정',
    content:
        '설정 > 알림에서 다양한 알림을 켜고 끌 수 있습니다. 팔로워의 새 게시물, 좋아요, 댓글 등에 대한 알림을 설정할 수 있습니다.',
  ),
  const FAQItem(
    title: '오류 해결',
    content:
        '앱 사용 중 문제가 발생하면 앱을 완전히 종료한 후 다시 실행해보세요. 문제가 지속되면 설정의 "앱 초기화"를 시도해보세요.',
  ),
];
