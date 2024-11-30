import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/dark_theme.dart';
import '../theme/light_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themePreferenceKey = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeProvider(this._prefs) {
    // 저장된 테마 모드를 불러옵니다
    _themeMode = ThemeMode
        .values[_prefs.getInt(_themePreferenceKey) ?? ThemeMode.system.index];
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeData get theme =>
      _themeMode == ThemeMode.dark ? DarkTheme.theme : LightTheme.theme;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _prefs.setInt(_themePreferenceKey, mode.index);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setThemeMode(
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
