import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import '../../../core/widgets/bus_stop_card.dart';
import 'bus_search_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  bool _justAddedStop = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<HomeViewModel>();
    vm.startClock();
    if (vm.stops.isNotEmpty) {
      vm.startAutoRefresh();
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _syncTabController() {
    final stopCount = context.read<HomeViewModel>().stops.length;
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
    context.read<HomeViewModel>().addStop(name);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final theme = Theme.of(context);

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
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsSheet(context),
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

  void _showSettingsSheet(BuildContext context) {
    final vm = context.read<HomeViewModel>();
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                '設定',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '主題模式',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              _ThemeOption(
                icon: Icons.brightness_auto,
                label: '系統預設',
                selected: vm.themeMode == 'system',
                onTap: () {
                  vm.setThemeMode('system');
                  Navigator.pop(ctx);
                },
              ),
              _ThemeOption(
                icon: Icons.light_mode,
                label: '淺色模式',
                selected: vm.themeMode == 'light',
                onTap: () {
                  vm.setThemeMode('light');
                  Navigator.pop(ctx);
                },
              ),
              _ThemeOption(
                icon: Icons.dark_mode,
                label: '深色模式',
                selected: vm.themeMode == 'dark',
                onTap: () {
                  vm.setThemeMode('dark');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    final weekdays = ['日', '一', '二', '三', '四', '五', '六'];
    return '${dt.year}/${_pad(dt.month)}/${_pad(dt.day)} (${weekdays[dt.weekday % 7]})  '
        '${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: selected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: selected
            ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: selected ? theme.colorScheme.primary : null),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: selected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
