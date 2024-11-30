import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../models/location_model.dart';

class LocationService {
  // 현재 위치 가져오기
  Future<LocationModel?> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestPermission = await Geolocator.requestPermission();
        if (requestPermission == LocationPermission.denied) {
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = [
          placemark.street,
          placemark.subLocality,
          placemark.locality,
          placemark.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        return LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          name: placemark.name,
          address: address,
        );
      }

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // 주소로 위치 검색
  Future<List<LocationModel>> searchLocation(String query) async {
    try {
      final locations = await locationFromAddress(query);
      final results = <LocationModel>[];

      for (final location in locations) {
        final placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final address = [
            placemark.street,
            placemark.subLocality,
            placemark.locality,
            placemark.administrativeArea,
          ].where((e) => e != null && e.isNotEmpty).join(', ');

          results.add(LocationModel(
            latitude: location.latitude,
            longitude: location.longitude,
            name: placemark.name,
            address: address,
          ));
        }
      }

      return results;
    } catch (e) {
      print('Error searching location: $e');
      return [];
    }
  }

  // 위치 권한 확인
  Future<bool> checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requestPermission = await Geolocator.requestPermission();
      return requestPermission != LocationPermission.denied;
    }
    return permission != LocationPermission.denied;
  }

  // 위치 서비스 활성화 확인
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // 두 위치 사이의 거리 계산 (km)
  double calculateDistance(LocationModel location1, LocationModel location2) {
    return Geolocator.distanceBetween(
          location1.latitude,
          location1.longitude,
          location2.latitude,
          location2.longitude,
        ) /
        1000; // meters to kilometers
  }
}
