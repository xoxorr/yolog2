import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<bool> connectionChangeController =
      StreamController.broadcast();
  bool _hasConnection = true;

  Stream<bool> get connectionChange => connectionChangeController.stream;
  bool get hasConnection => _hasConnection;

  void initialize() {
    _connectivity.onConnectivityChanged.listen(_connectionChange);
    checkConnection();
  }

  void dispose() {
    connectionChangeController.close();
  }

  void _connectionChange(ConnectivityResult result) {
    _hasConnection = result != ConnectivityResult.none;
    connectionChangeController.add(_hasConnection);
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _hasConnection = result != ConnectivityResult.none;
    return _hasConnection;
  }

  Future<ConnectivityResult> getConnectionType() async {
    return await _connectivity.checkConnectivity();
  }

  String getConnectionTypeName(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return '모바일 데이터';
      case ConnectivityResult.ethernet:
        return '이더넷';
      case ConnectivityResult.bluetooth:
        return '블루투스';
      case ConnectivityResult.none:
        return '연결 없음';
      default:
        return '알 수 없음';
    }
  }

  Future<bool> isConnectedToWifi() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi;
  }

  Future<bool> isConnectedToMobileData() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile;
  }

  void addListener(void Function(bool) listener) {
    connectionChange.listen(listener);
  }
}
