class RouteInfo {
  final String routeName;
  final String dest;
  final String timeLabel;
  final String timeClass;
  final double numeric;
  final String goback;
  final String dir;

  const RouteInfo({
    required this.routeName,
    required this.dest,
    required this.timeLabel,
    required this.timeClass,
    required this.numeric,
    required this.goback,
    required this.dir,
  });
}
