import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _error = '';
  bool _isOnline = true;

  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isOnline => _isOnline;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String message) {
    _error = message;
    notifyListeners();
  }

  void setOnlineStatus(bool status) {
    _isOnline = status;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
