class ApiRouteInfo {
  final String routeName;
  final String goBack;
  final String dest;
  final String dept;
  final String time;
  final String? lat;
  final String? lon;

  const ApiRouteInfo({
    required this.routeName,
    required this.goBack,
    required this.dest,
    required this.dept,
    required this.time,
    this.lat,
    this.lon,
  });

  factory ApiRouteInfo.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'RouteName': String routeName,
        'GoBack': String goBack,
        'Dest': String dest,
        'Dept': String dept,
        'Time': String time,
      } =>
        ApiRouteInfo(
          routeName: routeName,
          goBack: goBack,
          dest: dest,
          dept: dept,
          time: time,
          lat: json['Lat'] as String?,
          lon: json['Lon'] as String?,
        ),
      _ => throw const FormatException('Invalid ApiRouteInfo JSON'),
    };
  }
}
