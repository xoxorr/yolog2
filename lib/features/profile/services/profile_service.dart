import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/profile_model.dart';
import './style_service.dart';
import './portfolio_service.dart';
import './stats_service.dart';

class ProfileService extends ChangeNotifier {
  final StyleService _styleService = StyleService();
  final PortfolioService _portfolioService = PortfolioService();
  final StatsService _statsService = StatsService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  ProfileModel? _profile;
  bool _isLoading = false;
  String? _error;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 프로필 데이터 통합 메서드
  Future<Map<String, dynamic>> getCompleteProfile(String userId) async {
    final style = await _styleService.getTravelStyle(userId);
    final preferences = await _styleService.getUserPreferences(userId);
    final history = await _portfolioService.getUserHistory(userId);
    final stories = await _portfolioService.getUserStories(userId);
    final stats = await _statsService.getTravelStats(userId);
    final expenses = await _statsService.getTravelExpense(userId);

    return {
      'style': style?.toFirestore(),
      'preferences': preferences.map((p) => p.toFirestore()).toList(),
      'history': history.map((h) => h.toFirestore()).toList(),
      'stories': stories.map((s) => s.toFirestore()).toList(),
      'stats': stats?.toFirestore(),
      'expenses': expenses?.toFirestore(),
    };
  }

  // 프로필 분석 메서드
  Future<Map<String, dynamic>> getProfileAnalytics(String userId) async {
    final topDestinations = await _styleService.analyzeTopDestinations(userId);
    final categoryAverages =
        await _styleService.calculateCategoryAverages(userId);
    final visitedCountries =
        await _portfolioService.getVisitedCountries(userId);
    final activityDistribution =
        await _portfolioService.getActivityDistribution(userId);
    final monthlyTrends = await _statsService.getMonthlyTrends(userId);
    final expenseBreakdown = await _statsService.getExpenseBreakdown(userId);
    final yearlyComparison = await _statsService.getYearlyComparison(userId);
    final destinationInsights =
        await _statsService.getDestinationInsights(userId);

    return {
      'preferences': {
        'topDestinations': topDestinations,
        'categoryAverages': categoryAverages,
      },
      'activities': {
        'visitedCountries': visitedCountries,
        'activityDistribution': activityDistribution,
      },
      'expenses': {
        'monthlyTrends': monthlyTrends,
        'breakdown': expenseBreakdown,
        'yearlyComparison': yearlyComparison,
      },
      'destinations': destinationInsights,
    };
  }

  // 프로필 동기화 메서드
  Future<void> syncProfileData(String userId) async {
    final batch = _firestore.batch();

    // 통계 업데이트
    final history = await _portfolioService.getUserHistory(userId);
    final stats = await _calculateStats(userId, history);
    batch.set(_firestore.collection('travelStats').doc(userId), stats);

    // 지출 동기화
    final expenses = await _calculateExpenses(userId, history);
    batch.set(_firestore.collection('travelExpenses').doc(userId), expenses);

    await batch.commit();
  }

  Future<Map<String, dynamic>> _calculateStats(
      String userId, List<dynamic> history) async {
    // 여행 통계 계산 로직
    int totalTrips = history.length;
    Set<String> countries = {};
    Set<String> cities = {};
    int totalDays = 0;
    Map<String, int> destinationTypes = {};
    Map<String, int> activities = {};
    double totalDistance = 0;

    for (var trip in history) {
      final destination = trip.destination.split(',');
      countries.add(destination.last.trim());
      cities.add(destination.first.trim());

      // duration을 명시적으로 int로 변환
      int tripDuration = (trip.duration as num).toInt();
      totalDays = totalDays + tripDuration;

      for (var type in trip.destinationType) {
        destinationTypes[type] = (destinationTypes[type] ?? 0) + 1;
      }

      for (var activity in trip.activities) {
        activities[activity] = (activities[activity] ?? 0) + 1;
      }

      totalDistance += trip.distance;
    }

    return {
      'userId': userId,
      'totalTrips': totalTrips,
      'totalCountries': countries.length,
      'totalCities': cities.length,
      'totalDays': totalDays,
      'destinationTypes': destinationTypes,
      'activities': activities,
      'totalDistance': totalDistance,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  Future<Map<String, dynamic>> _calculateExpenses(
      String userId, List<dynamic> history) async {
    // 지출 통계 계산 로직
    Map<String, double> categoryExpenses = {};
    Map<String, double> monthlyExpenses = {};
    Map<String, double> countryExpenses = {};
    double totalExpense = 0;

    for (var trip in history) {
      final month =
          '${trip.startDate.year}-${trip.startDate.month.toString().padLeft(2, '0')}';
      final country = trip.destination.split(',').last.trim();

      for (var expense in trip.expenses) {
        categoryExpenses[expense.category] =
            (categoryExpenses[expense.category] ?? 0) + expense.amount;
        monthlyExpenses[month] = (monthlyExpenses[month] ?? 0) + expense.amount;
        countryExpenses[country] =
            (countryExpenses[country] ?? 0) + expense.amount;
        totalExpense += expense.amount;
      }
    }

    return {
      'userId': userId,
      'categoryExpenses': categoryExpenses,
      'monthlyExpenses': monthlyExpenses,
      'countryExpenses': countryExpenses,
      'totalExpense': totalExpense,
      'defaultCurrency': 'KRW',
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  // 프로필 정보 가져오기
  Future<void> loadProfile(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _profile = ProfileModel.fromMap({...doc.data()!, 'uid': doc.id});
      }
    } catch (e) {
      _error = '프로필을 불러오는 중 오류가 발생했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 프로필 업데이트
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw '로그인이 필요합니다.';

      final updates = <String, dynamic>{
        if (displayName != null) 'displayName': displayName,
        if (bio != null) 'bio': bio,
        if (preferences != null) 'preferences': preferences,
      };

      await _firestore.collection('users').doc(user.uid).update(updates);
      await loadProfile(user.uid);
    } catch (e) {
      _error = '프로필 업데이트 중 오류가 발생했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 프로필 이미지 업로드
  Future<void> updateProfileImage(File imageFile) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw '로그인이 필요합니다.';

      final ref = _storage.ref().child('profile_images/${user.uid}');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'photoURL': url});

      await loadProfile(user.uid);
    } catch (e) {
      _error = '프로필 이미지 업데이트 중 오류가 발생했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
