import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationRepository {
  final LocationService _service;

  LocationRepository(this._service);

  Future<Position?> getCurrentPosition() => _service.getCurrentPosition();
}
