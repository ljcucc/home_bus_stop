import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import '../../../core/widgets/bus_stop_side_card.dart';
import '../../../../domain/models/bus_suggestion.dart';

String _shortDir(String dirLabel) {
  if (dirLabel.startsWith('往程')) return '往程';
  if (dirLabel.startsWith('返程')) return '返程';
  return dirLabel;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  bool _justAddedStop = false;
  int _prevVersion = -1;
  bool _editingStops = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<BusSuggestion> _suggestions = [];
  bool _showSuggestions = false;
  bool _searching = false;
  Timer? _debounceTimer;

  bool _hasLocation(HomeViewModel vm) => vm.myLat != null && vm.myLon != null;

  @override
  void initState() {
    super.initState();
    final vm = context.read<HomeViewModel>();
    vm.startClock();
    if (vm.stops.isNotEmpty) {
      vm.startAutoRefresh();
      vm.refresh();
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _syncTabController() {
    final vm = context.read<HomeViewModel>();
    final tabs = vm.selectedStopTabs;
    final tabCount = tabs.length;
    if (tabCount == 0) {
      _tabController?.dispose();
      _tabController = null;
    } else if (_tabController == null ||
        _tabController!.length != tabCount ||
        _prevVersion != vm.selectedStopVersion) {
      _prevVersion = vm.selectedStopVersion;
      _tabController?.dispose();
      _tabController = TabController(
        length: tabCount,
        vsync: this,
        initialIndex: _justAddedStop ? tabCount - 1 : 0,
      );
      _justAddedStop = false;
    }
  }

  void _onAddStop(String name) async {
    _justAddedStop = true;
    await context.read<HomeViewModel>().addStop(name);
  }

  void _onSearchInput(String val) {
    _debounceTimer?.cancel();
    if (val.trim().isEmpty) {
      setState(() => _showSuggestions = false);
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      _doSearch(val.trim());
    });
  }

  Future<void> _doSearch(String keyword) async {
    final vm = context.read<HomeViewModel>();
    setState(() => _searching = true);
    try {
      final results = await vm.busRepo.searchStops(
        keyword,
        myLat: vm.myLat,
        myLon: vm.myLon,
      );
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _showSuggestions = results.isNotEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _selectSuggestion(BusSuggestion s) {
    _onAddStop(s.name);
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final theme = Theme.of(context);
    _syncTabController();
    final tabs = vm.selectedStopTabs;
    final hasTabs = tabs.isNotEmpty;

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
                child: Row(
                  children: [
                    Icon(Icons.directions_bus, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '已開啟站牌',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (vm.stops.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          _editingStops ? Icons.check : Icons.edit,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _editingStops = !_editingStops),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _formatDateTime(vm.currentTime),
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              const Divider(),
              Expanded(
                child: vm.stops.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '尚未加入站牌',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      )
                    : _editingStops
                        ? ReorderableListView.builder(
                            itemCount: vm.stops.length,
                            onReorderItem: vm.reorderStop,
                            proxyDecorator: (child, index, animation) {
                              return Material(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                                elevation: 4,
                                child: child,
                              );
                            },
                            itemBuilder: (context, index) {
                              final name = vm.stops[index];
                              final isSelected = vm.selectedStop == name;
                              return ListTile(
                                key: ValueKey(name),
                                leading: Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: isSelected ? theme.colorScheme.primary : null,
                                  size: 20,
                                ),
                                title: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                dense: true,
                                onTap: () {
                                  vm.selectStop(name);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          )
                        : ListView.builder(
                            itemCount: vm.stops.length,
                            itemBuilder: (context, index) {
                              final name = vm.stops[index];
                              final isSelected = vm.selectedStop == name;
                              return ListTile(
                                leading: Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: isSelected ? theme.colorScheme.primary : null,
                                  size: 20,
                                ),
                                title: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.close, size: 18, color: theme.colorScheme.onSurfaceVariant),
                                  onPressed: () => vm.removeStop(name),
                                ),
                                dense: true,
                                onTap: () {
                                  vm.selectStop(name);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  '設定',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              _DrawerThemeOption(
                icon: Icons.brightness_auto,
                label: '系統預設',
                selected: vm.themeMode == 'system',
                onTap: () {
                  vm.setThemeMode('system');
                  Navigator.pop(context);
                },
              ),
              _DrawerThemeOption(
                icon: Icons.light_mode,
                label: '淺色模式',
                selected: vm.themeMode == 'light',
                onTap: () {
                  vm.setThemeMode('light');
                  Navigator.pop(context);
                },
              ),
              _DrawerThemeOption(
                icon: Icons.dark_mode,
                label: '深色模式',
                selected: vm.themeMode == 'dark',
                onTap: () {
                  vm.setThemeMode('dark');
                  Navigator.pop(context);
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Icon(Icons.palette_outlined, size: 20, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '動態色彩',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Switch(
                      value: vm.useDynamicColor,
                      onChanged: (_) {
                        vm.toggleUseDynamicColor();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _onSearchInput,
            decoration: InputDecoration(
              hintText: '搜尋站牌名稱…',
              prefixIcon: Icon(Icons.search, size: 20),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searching)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      _hasLocation(vm) ? Icons.location_on : Icons.location_on_outlined,
                      color: _hasLocation(vm) ? Colors.green : null,
                      size: 20,
                    ),
                    onPressed: vm.startLocation,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
          ),
        ),
        bottom: hasTabs && _tabController != null
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: tabs.map((t) {
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions_bus, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 2),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.side.locId, style: const TextStyle(fontSize: 13)),
                            Text(
                              _shortDir(t.side.dirLabel),
                              style: TextStyle(
                                fontSize: 9,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            : null,
      ),
      body: _buildBody(vm, theme, tabs),
    );
  }

  Widget _buildBody(HomeViewModel vm, ThemeData theme, List<SideTab> tabs) {
    final hasTabs = tabs.isNotEmpty;

    return Column(
      children: [
        if (_showSuggestions)
          Card(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final s = _suggestions[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      s.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: s.distanceText != null
                        ? Text(
                            s.distanceText!,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          )
                        : null,
                    onTap: () => _selectSuggestion(s),
                  );
                },
              ),
            ),
          ),
        if (hasTabs && _tabController != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          if (vm.isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: tabs.map((t) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: BusStopSideCard(
                      stopName: t.stopName,
                      side: t.side,
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
              child: vm.isLoading
                  ? const CircularProgressIndicator()
                  : Column(
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

class _DrawerThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: selected ? theme.colorScheme.primary : null),
      title: Text(
        label,
        style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal),
      ),
      trailing: selected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
      onTap: onTap,
      dense: true,
    );
  }
}
