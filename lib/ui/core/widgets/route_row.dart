import 'package:flutter/material.dart';
import '../../../domain/models/route_info.dart';

class RouteRow extends StatelessWidget {
  final RouteInfo route;

  const RouteRow({super.key, required this.route});

  static const _timeColors = {
    'arriving': Color(0xFF4CAF50),
    'approaching': Color(0xFFFF9800),
    'coming': Color(0xFF42A5F5),
    'enroute': Color(0xFF78909C),
  };

  @override
  Widget build(BuildContext context) {
    final isNobus = route.timeClass == 'nobus';
    final timeColor = _timeColors[route.timeClass];
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              route.routeName,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${route.dir} ${route.dest}',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Text(
              route.timeLabel,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isNobus ? FontWeight.w400 : FontWeight.bold,
                fontSize: isNobus ? 13 : 20,
                color: timeColor ??
                    theme.colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
