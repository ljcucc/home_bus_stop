import 'package:flutter/material.dart';
import '../../../domain/models/stop_side.dart';
import 'route_row.dart';

class BusStopSideCard extends StatelessWidget {
  final String stopName;
  final StopSide side;

  const BusStopSideCard({
    super.key,
    required this.stopName,
    required this.side,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '📍 ${side.locId}${side.distText.isNotEmpty ? ' · ${side.distText}' : ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(
                    side.dirLabel,
                    style: const TextStyle(fontSize: 11),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ],
            ),
          ),
          if (side.routes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '無營運路線',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          else
            ...side.routes.map((route) => RouteRow(route: route)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
