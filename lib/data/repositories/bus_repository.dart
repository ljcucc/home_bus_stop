import 'dart:math';

import '../services/bus_api_service.dart';
import '../../domain/models/bus_suggestion.dart';
import '../../domain/models/route_info.dart';
import '../../domain/models/stop_side.dart';

class BusRepository {
  final BusApiService _api;

  BusRepository(this._api);

  Future<List<BusSuggestion>> searchStops(
    String keyword, {
    double? myLat,
    double? myLon,
  }) async {
    final results = await _api.searchStops(keyword);
    return results.map((s) {
      double? distance;
      String? distanceText;
      if (myLat != null && myLon != null && s.lat != null && s.lon != null) {
        distance = calcDistance(
          myLat,
          myLon,
          double.parse(s.lat!),
          double.parse(s.lon!),
        );
        distanceText = formatDist(distance);
      }
      return BusSuggestion(
        name: s.name,
        distance: distance,
        distanceText: distanceText,
      );
    }).toList();
  }

  Future<List<StopSide>> fetchStopData(
    String stopName, {
    double? myLat,
    double? myLon,
  }) async {
    final data = await _api.fetchStopData(stopName);
    if (data.isEmpty) return [];

    final hasLocation = myLat != null && myLon != null;

    final sides = data.map((loc) {
      final routes = loc.info.map((info) {
        final classified = _classifyTime(info.time);
        return RouteInfo(
          routeName: info.routeName,
          dest: info.goBack == '0' ? info.dest : info.dept,
          timeLabel: classified.label,
          timeClass: classified.cls,
          numeric: classified.numeric,
          goback: info.goBack,
          dir: info.goBack == '0' ? '往程' : '返程',
        );
      }).toList();

      routes.sort(_compareRoutes);

      final gobacks = routes.map((r) => r.goback).toSet().toList();
      final dirLabel = gobacks.length == 1
          ? (gobacks[0] == '0' ? '往程' : '返程')
          : '雙向';

      String distText = '';
      if (hasLocation &&
          loc.info.isNotEmpty &&
          loc.info[0].lat != null &&
          loc.info[0].lon != null) {
        final dist = calcDistance(
          myLat,
          myLon,
          double.parse(loc.info[0].lat!),
          double.parse(loc.info[0].lon!),
        );
        distText = formatDist(dist);
      }

      return StopSide(
        locId: loc.locationId,
        dirLabel: dirLabel,
        distText: distText,
        routes: routes,
        gobacks: gobacks,
      );
    }).toList();

    sides.sort((a, b) {
      if (a.gobacks.length != b.gobacks.length) {
        return b.gobacks.length.compareTo(a.gobacks.length);
      }
      return a.locId.compareTo(b.locId);
    });

    return sides;
  }

  static _RouteClassified _classifyTime(String timeStr) {
    final timeNum = int.tryParse(timeStr);
    if (timeStr == '未發車' || timeStr == '已發車' || timeNum == null) {
      return _RouteClassified(
        label: timeStr,
        cls: 'nobus',
        numeric: double.infinity,
      );
    }
    if (timeNum <= 1) {
      return _RouteClassified(label: '即將進站', cls: 'arriving', numeric: 1);
    }
    if (timeNum <= 3) {
      return _RouteClassified(
        label: '$timeNum 分',
        cls: 'arriving',
        numeric: timeNum.toDouble(),
      );
    }
    if (timeNum <= 10) {
      return _RouteClassified(
        label: '$timeNum 分',
        cls: 'approaching',
        numeric: timeNum.toDouble(),
      );
    }
    return _RouteClassified(
      label: '$timeNum 分',
      cls: 'coming',
      numeric: timeNum.toDouble(),
    );
  }

  static int _compareRoutes(RouteInfo a, RouteInfo b) {
    const order = {'arriving': 0, 'approaching': 1, 'coming': 2, 'nobus': 3};
    final ao = order[a.timeClass] ?? 99;
    final bo = order[b.timeClass] ?? 99;
    if (ao != bo) return ao.compareTo(bo);
    if (a.numeric != double.infinity && b.numeric != double.infinity) {
      return a.numeric.compareTo(b.numeric);
    }
    return a.routeName.compareTo(b.routeName);
  }
}

class _RouteClassified {
  final String label;
  final String cls;
  final double numeric;

  const _RouteClassified({
    required this.label,
    required this.cls,
    required this.numeric,
  });
}

double calcDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371e3;
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) *
          cos(_toRad(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double _toRad(double d) => d * pi / 180;

String formatDist(double meters) {
  return meters < 1000
      ? '${meters.round()}m'
      : '${(meters / 1000).toStringAsFixed(1)}km';
}
