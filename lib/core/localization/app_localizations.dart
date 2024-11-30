import 'package:flutter/material.dart';
import 'supported_locales.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Yolog',
      'home': 'Home',
      'profile': 'Profile',
      'settings': 'Settings',
      'search': 'Search',
      'create_post': 'Create Post',
      'popular': 'Popular',
      'bookmarks': 'Bookmarks',
      'history': 'History',
      'featured_members': 'Featured Members',
      'follow_feed': 'Follow Feed',
      'tag_search': 'Tag Search',
      'support_center': 'Support Center',
      'update': 'Update',
    },
    'ko': {
      'app_name': '요로그',
      'home': '홈',
      'profile': '프로필',
      'settings': '설정',
      'search': '검색',
      'create_post': '글쓰기',
      'popular': '인기',
      'bookmarks': '북마크',
      'history': '히스토리',
      'featured_members': '추천 회원',
      'follow_feed': '팔로우 피드',
      'tag_search': '태그 검색',
      'support_center': '고객센터',
      'update': '업데이트',
    },
  };

  String get appName => _localizedValues[locale.languageCode]!['app_name']!;
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get search => _localizedValues[locale.languageCode]!['search']!;
  String get createPost =>
      _localizedValues[locale.languageCode]!['create_post']!;
  String get popular => _localizedValues[locale.languageCode]!['popular']!;
  String get bookmarks => _localizedValues[locale.languageCode]!['bookmarks']!;
  String get history => _localizedValues[locale.languageCode]!['history']!;
  String get featuredMembers =>
      _localizedValues[locale.languageCode]!['featured_members']!;
  String get followFeed =>
      _localizedValues[locale.languageCode]!['follow_feed']!;
  String get tagSearch => _localizedValues[locale.languageCode]!['tag_search']!;
  String get supportCenter =>
      _localizedValues[locale.languageCode]!['support_center']!;
  String get update => _localizedValues[locale.languageCode]!['update']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => SupportedLocales.locales
      .map((e) => e.languageCode)
      .contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
