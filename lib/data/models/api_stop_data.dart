import 'api_route_info.dart';

class ApiStopLocation {
  final String locationId;
  final List<ApiRouteInfo> info;

  const ApiStopLocation({required this.locationId, required this.info});

  factory ApiStopLocation.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'LocationID': String locationId,
        'info': List<dynamic> infoList,
      } =>
        ApiStopLocation(
          locationId: locationId,
          info: infoList
              .cast<Map<String, dynamic>>()
              .map(ApiRouteInfo.fromJson)
              .toList(),
        ),
      _ => throw const FormatException('Invalid ApiStopLocation JSON'),
    };
  }
}
