import 'route_info.dart';

class StopSide {
  final String locId;
  final String dirLabel;
  final String distText;
  final List<RouteInfo> routes;
  final List<String> gobacks;

  const StopSide({
    required this.locId,
    required this.dirLabel,
    required this.distText,
    required this.routes,
    required this.gobacks,
  });
}
