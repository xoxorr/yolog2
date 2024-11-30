import 'package:flutter/material.dart';

class SupportedLocales {
  static const List<Locale> locales = [
    Locale('en', 'US'), // English (United States)
    Locale('ko', 'KR'), // Korean (South Korea)
    Locale('ja', 'JP'), // Japanese (Japan)
    Locale('zh', 'CN'), // Chinese (China)
  ];

  static const Locale defaultLocale = Locale('ko', 'KR');

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ko':
        return '한국어';
      case 'ja':
        return '日本語';
      case 'zh':
        return '中文';
      default:
        return 'Unknown';
    }
  }

  static String getCountryName(String countryCode) {
    switch (countryCode) {
      case 'US':
        return 'United States';
      case 'KR':
        return 'South Korea';
      case 'JP':
        return 'Japan';
      case 'CN':
        return 'China';
      default:
        return 'Unknown';
    }
  }
}
