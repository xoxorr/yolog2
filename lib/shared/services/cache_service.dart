import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  late SharedPreferences _prefs;
  final Duration _defaultExpiration = const Duration(hours: 1);

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> setCache(
    String key,
    dynamic value, {
    Duration? expiration,
  }) async {
    final expirationTime = DateTime.now()
        .add(expiration ?? _defaultExpiration)
        .millisecondsSinceEpoch;

    final cacheData = {
      'value': value,
      'expiration': expirationTime,
    };

    return await _prefs.setString(key, jsonEncode(cacheData));
  }

  T? getCache<T>(String key) {
    final data = _prefs.getString(key);
    if (data == null) return null;

    final cacheData = jsonDecode(data);
    final expiration =
        DateTime.fromMillisecondsSinceEpoch(cacheData['expiration']);

    if (DateTime.now().isAfter(expiration)) {
      _prefs.remove(key);
      return null;
    }

    return cacheData['value'] as T;
  }

  Future<bool> removeCache(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clearCache() async {
    return await _prefs.clear();
  }

  bool hasValidCache(String key) {
    final data = _prefs.getString(key);
    if (data == null) return false;

    final cacheData = jsonDecode(data);
    final expiration =
        DateTime.fromMillisecondsSinceEpoch(cacheData['expiration']);

    return DateTime.now().isBefore(expiration);
  }

  Future<void> refreshCache(String key) async {
    final data = getCache(key);
    if (data != null) {
      await setCache(key, data);
    }
  }

  Future<void> extendExpiration(String key, Duration extension) async {
    final data = getCache(key);
    if (data != null) {
      await setCache(key, data, expiration: extension);
    }
  }
}
