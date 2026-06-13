import 'package:flutter/material.dart';
import '../view_models/home_view_model.dart';
import '../../../core/widgets/bus_stop_card.dart';
import 'bus_search_widget.dart';

class HomeScreen extends StatefulWidget {
  final HomeViewModel viewModel;

  const HomeScreen({super.key, required this.viewModel});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  bool _justAddedStop = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
    widget.viewModel.startClock();
    if (widget.viewModel.stops.isNotEmpty) {
      widget.viewModel.startAutoRefresh();
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  void _syncTabController() {
    final stopCount = widget.viewModel.stops.length;
    if (stopCount == 0) {
      _tabController?.dispose();
      _tabController = null;
    } else if (_tabController == null || _tabController!.length != stopCount) {
      final prevIdx = _tabController?.index ?? 0;
      final newIdx = _justAddedStop ? stopCount - 1 : prevIdx.clamp(0, stopCount - 1);
      _justAddedStop = false;
      _tabController?.dispose();
      _tabController = TabController(
        length: stopCount,
        vsync: this,
        initialIndex: newIdx,
      );
    }
  }

  void _onAddStop(String name) {
    _justAddedStop = true;
    widget.viewModel.addStop(name);
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final theme = Theme.of(context);
    final hasStops = vm.stops.isNotEmpty;

    _syncTabController();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '大台南公車立牌',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
                fontSize: 18,
              ),
            ),
            Text(
              _formatDateTime(vm.currentTime),
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(vm.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: vm.toggleTheme,
          ),
          IconButton(
            icon: Icon(vm.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
            onPressed: vm.toggleFullscreen,
          ),
        ],
      ),
      body: _buildBody(vm, theme),
    );
  }

  Widget _buildBody(HomeViewModel vm, ThemeData theme) {
    final hasStops = vm.stops.isNotEmpty;

    return Column(
      children: [
        if (!vm.isFullscreen) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: BusSearchWidget(
              busRepo: vm.busRepo,
              myLat: vm.myLat,
              myLon: vm.myLon,
              onAddStop: _onAddStop,
              onLocate: vm.startLocation,
            ),
          ),
          if (vm.geoStatusText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    vm.geoStatusText,
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
              ),
            ),
        ],
        if (hasStops && _tabController != null) ...[
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: vm.stops.map((name) {
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_bus, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(name, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 2),
                    GestureDetector(
                      onTap: () => vm.removeStop(name),
                      child: Icon(Icons.close, size: 14, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('隱藏未發車', style: TextStyle(fontSize: 12)),
                  selected: vm.hideNobus,
                  onSelected: (_) => vm.toggleHideNobus(),
                  visualDensity: VisualDensity.compact,
                  showCheckmark: true,
                  selectedColor: theme.colorScheme.secondaryContainer,
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: vm.refresh,
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('重新整理', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
          if (vm.errorMessage.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      vm.errorMessage,
                      style: TextStyle(color: theme.colorScheme.onErrorContainer, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: vm.clearError,
                  ),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: vm.stops.map((stopName) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: BusStopCard(
                    stopName: stopName,
                    hideNobus: vm.hideNobus,
                    refreshKey: vm.refreshKey,
                    myLat: vm.myLat,
                    myLon: vm.myLon,
                    isFullscreen: vm.isFullscreen,
                    onRemove: () => vm.removeStop(stopName),
                    onError: (msg) {},
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              vm.lastUpdate.isNotEmpty
                  ? '最後更新：${vm.lastUpdate}'
                  : '等待更新…',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ] else ...[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🚌', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    '在上方搜尋站牌名稱加入\n即會顯示即時到站資訊',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final weekdays = ['日', '一', '二', '三', '四', '五', '六'];
    return '${dt.year}/${_pad(dt.month)}/${_pad(dt.day)} (${weekdays[dt.weekday % 7]})  '
        '${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
