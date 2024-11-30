import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GpsService {
  static final GpsService _instance = GpsService._internal();
  factory GpsService() => _instance;
  GpsService._internal();

  StreamController<Position>? _locationController;
  Timer? _locationTimer;
  bool _isTracking = false;

  // GPS 권한 확인 및 요청
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // 현재 위치 가져오기
  Future<LatLng?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // 위치 추적 시작
  Stream<Position> startTracking({
    int intervalSeconds = 10,
    double distanceFilter = 10,
  }) {
    if (_isTracking) {
      return _locationController!.stream;
    }

    _locationController = StreamController<Position>.broadcast();
    _isTracking = true;

    // 초기 위치 가져오기
    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).then((position) {
      if (_locationController?.isClosed == false) {
        _locationController?.add(position);
      }
    });

    // 주기적으로 위치 업데이트
    _locationTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (timer) async {
        if (_locationController?.isClosed == true) {
          timer.cancel();
          return;
        }

        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          _locationController?.add(position);
        } catch (e) {
          print('Error updating location: $e');
        }
      },
    );

    return _locationController!.stream;
  }

  // 위치 추적 중지
  void stopTracking() {
    _isTracking = false;
    _locationTimer?.cancel();
    _locationController?.close();
    _locationController = null;
  }

  // 두 위치 사이의 거리 계산 (km)
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
          point1.latitude,
          point1.longitude,
          point2.latitude,
          point2.longitude,
        ) /
        1000; // meters to kilometers
  }

  // 지정된 위치 반경 내에 있는지 확인
  Future<bool> isWithinRadius(LatLng targetLocation,
      {double radiusKm = 0.1}) async {
    final currentLocation = await getCurrentLocation();
    if (currentLocation == null) return false;

    final distance = calculateDistance(currentLocation, targetLocation);
    return distance <= radiusKm;
  }

  // 이동 경로 기록
  List<LatLng> _trackPoints = [];

  void addTrackPoint(LatLng point) {
    _trackPoints.add(point);
  }

  List<LatLng> getTrackPoints() {
    return List.from(_trackPoints);
  }

  void clearTrackPoints() {
    _trackPoints.clear();
  }

  // 총 이동 거리 계산 (km)
  double calculateTotalDistance() {
    if (_trackPoints.length < 2) return 0;

    double totalDistance = 0;
    for (int i = 0; i < _trackPoints.length - 1; i++) {
      totalDistance += calculateDistance(_trackPoints[i], _trackPoints[i + 1]);
    }
    return totalDistance;
  }

  // 평균 이동 속도 계산 (km/h)
  double calculateAverageSpeed() {
    if (_trackPoints.length < 2) return 0;

    final totalDistance = calculateTotalDistance();
    final duration = _trackPoints.last.timestamp!
        .difference(_trackPoints.first.timestamp!)
        .inHours;
    return totalDistance / duration;
  }

  // 위치 정확도 향상을 위한 보정
  LatLng smoothLocation(List<LatLng> recentLocations) {
    if (recentLocations.isEmpty) {
      throw ArgumentError('Recent locations list cannot be empty');
    }

    // 칼만 필터나 이동 평균 등의 알고리즘을 적용할 수 있습니다.
    // 여기서는 간단한 이동 평균을 사용합니다.
    double sumLat = 0;
    double sumLng = 0;

    for (var location in recentLocations) {
      sumLat += location.latitude;
      sumLng += location.longitude;
    }

    return LatLng(
      sumLat / recentLocations.length,
      sumLng / recentLocations.length,
    );
  }
}

extension TimestampLatLng on LatLng {
  DateTime? get timestamp => null;
}
