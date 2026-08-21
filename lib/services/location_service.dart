import 'dart:math';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// User ki live location coordinates (Latitude & Longitude) fetch karta hai
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Do coordinates ke beech exact road/aerial distance (KM) nikalta hai (Haversine Formula)
  static double getDistanceInKm({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final double a = 0.5 -
        cos((endLatitude - startLatitude) * p) / 2 +
        cos(startLatitude * p) *
            cos(endLatitude * p) *
            (1 - cos((endLongitude - startLongitude) * p)) /
            2;
    return 12742 * asin(sqrt(a)); // Radius of Earth = 6371 km
  }
}
