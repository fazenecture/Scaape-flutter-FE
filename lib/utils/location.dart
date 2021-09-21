import 'package:geolocator/geolocator.dart';

class Location {
  double latitude = 0.0;
  double longitude = 0.0;
  getCurrentLocation() async {
    // LocationPermission permission = await Geolocator.checkPermission();
    try {
      print('Entered in location block');
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      latitude = position.latitude;
      longitude = position.longitude;
      return position;
    } catch (e) {
      print(e);
    }
  }
}
