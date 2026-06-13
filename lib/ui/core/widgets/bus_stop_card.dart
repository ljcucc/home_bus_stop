import 'package:flutter/material.dart';
import '../../../data/services/bus_api_service.dart';
import '../../../data/repositories/bus_repository.dart';
import '../../../domain/models/stop_side.dart';
import 'route_row.dart';

class BusStopCard extends StatefulWidget {
  final String stopName;
  final bool hideNobus;
  final int refreshKey;
  final double? myLat;
  final double? myLon;
  final VoidCallback onRemove;
  final ValueChanged<String> onError;

  const BusStopCard({
    super.key,
    required this.stopName,
    required this.hideNobus,
    required this.refreshKey,
    this.myLat,
    this.myLon,
    required this.onRemove,
    required this.onError,
  });

  @override
  State<BusStopCard> createState() => _BusStopCardState();
}

class _BusStopCardState extends State<BusStopCard> {
  final BusRepository _repository = BusRepository(BusApiService());

  List<StopSide> _sides = [];
  bool _loading = true;
  bool _isFirstLoad = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(BusStopCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey ||
        oldWidget.myLat != widget.myLat ||
        oldWidget.myLon != widget.myLon) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_isFirstLoad) {
      setState(() { _loading = true; _errorMessage = null; });
    }
    try {
      final data = await _repository.fetchStopData(
        widget.stopName,
        myLat: widget.myLat,
        myLon: widget.myLon,
      );
      if (!mounted) return;
      if (data.isNotEmpty) {
        setState(() {
          _sides = data;
          _loading = false;
          _isFirstLoad = false;
        });
      } else {
        setState(() {
          _sides = [];
          _errorMessage = '查無此站牌資料';
          _loading = false;
          _isFirstLoad = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sides = [];
        _errorMessage = '資料讀取失敗';
        _loading = false;
        _isFirstLoad = false;
      });
      widget.onError('${widget.stopName}: 資料讀取失敗');
    }
  }

  List<({
    String locId,
    String dirLabel,
    String distText,
    List<dynamic> routes,
    List<String> gobacks,
  })> get _visibleSides {
    return _sides
        .map((side) {
          final filteredRoutes = widget.hideNobus
              ? side.routes
                  .where((r) => r.timeClass != 'nobus')
                  .toList()
              : side.routes;
          return (
            locId: side.locId,
            dirLabel: side.dirLabel,
            distText: side.distText,
            routes: filteredRoutes,
            gobacks: side.gobacks,
          );
        })
        .where((s) => s.routes.isNotEmpty)
        .toList();
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.stopName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildBody(theme),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading && _isFirstLoad) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          _errorMessage!,
          style: TextStyle(color: theme.colorScheme.primary),
        ),
      );
    }

    final sides = _visibleSides;

    if (sides.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '無營運路線',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    if (sides.length == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSideHeader(sides[0], theme),
          for (final route in sides[0].routes)
            RouteRow(route: route),
          const SizedBox(height: 8),
        ],
      );
    }

    return DefaultTabController(
      length: sides.length,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            type: MaterialType.transparency,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              tabs: sides.map((s) {
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('📍', style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
                      const SizedBox(width: 4),
                      Text(s.locId, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Builder(builder: (context) {
            final tc = DefaultTabController.of(context);
            final side = sides[tc.index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSideHeader(side, theme),
                for (final route in side.routes)
                  RouteRow(route: route),
                const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSideHeader(
    ({
      String locId,
      String dirLabel,
      String distText,
      List<dynamic> routes,
      List<String> gobacks,
    }) side,
    ThemeData theme,
  ) {
    return Padding(
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
    );
  }
}
