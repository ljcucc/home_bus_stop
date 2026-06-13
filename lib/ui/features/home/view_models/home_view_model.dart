import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/repositories/bus_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../data/repositories/location_repository.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../domain/models/stop_side.dart';

class SideTab {
  final String stopName;
  final StopSide side;

  const SideTab({required this.stopName, required this.side});
}

class HomeViewModel extends ChangeNotifier {
  final BusRepository busRepo;
  final SettingsRepository _settingsRepo;
  final LocationRepository _locationRepo;
  final StorageService _storage;

  List<String> _stops;
  bool _hideNobus;
  bool _useDynamicColor;
  String _themeMode;
  double? _myLat;
  double? _myLon;
  bool _isTracking = false;
  String _lastUpdate = '';
  String _errorMessage = '';
  DateTime _currentTime = DateTime.now();
  Timer? _refreshTimer;
  Timer? _clockTimer;
  final List<SideTab> _sideTabs = [];
  bool _isLoading = false;
  String? _selectedStop;
  int _selectedStopVersion = 0;

  HomeViewModel({
    required this.busRepo,
    required this._settingsRepo,
    required this._locationRepo,
    required this._storage,
    required List<String> initialStops,
  })  : _stops = initialStops,
        _hideNobus = _settingsRepo.hideNobus,
        _useDynamicColor = _settingsRepo.useDynamicColor,
        _themeMode = _settingsRepo.themeMode {
    if (_stops.isNotEmpty) _selectedStop = _stops.first;
  }

  List<String> get stops => _stops;
  bool get hideNobus => _hideNobus;
  bool get useDynamicColor => _useDynamicColor;
  String get themeMode => _themeMode;
  double? get myLat => _myLat;
  double? get myLon => _myLon;
  bool get isTracking => _isTracking;
  String get lastUpdate => _lastUpdate;
  String get errorMessage => _errorMessage;
  DateTime get currentTime => _currentTime;
  bool get isLoading => _isLoading;
  String? get selectedStop => _selectedStop;
  int get selectedStopVersion => _selectedStopVersion;

  List<SideTab> get selectedStopTabs {
    if (_selectedStop == null) return [];
    final tabs = _sideTabs.where((t) => t.stopName == _selectedStop).toList();
    if (!_hideNobus) return tabs;
    return tabs
        .map((t) => SideTab(
              stopName: t.stopName,
              side: StopSide(
                locId: t.side.locId,
                dirLabel: t.side.dirLabel,
                distText: t.side.distText,
                routes: t.side.routes
                    .where((r) => r.timeClass != 'nobus')
                    .toList(),
                gobacks: t.side.gobacks,
              ),
            ))
        .where((t) => t.side.routes.isNotEmpty)
        .toList();
  }

  void selectStop(String name) {
    if (_selectedStop == name || !_stops.contains(name)) return;
    _selectedStop = name;
    _selectedStopVersion++;
    notifyListeners();
  }

  String get geoStatusText {
    if (_isTracking) return '定位中…';
    if (_myLat != null && _myLon != null) {
      return '已定位 (${_myLat!.toStringAsFixed(4)}, ${_myLon!.toStringAsFixed(4)})';
    }
    return '';
  }

  void startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _currentTime = DateTime.now();
      notifyListeners();
    });
  }

  void stopClock() {
    _clockTimer?.cancel();
  }

  void startAutoRefresh() {
    _refreshTimer?.cancel();
    if (_stops.isEmpty) return;
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refresh();
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }

  Future<void> refresh() async {
    final now = DateTime.now();
    _lastUpdate =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    _isLoading = true;
    notifyListeners();
    _sideTabs.clear();
    for (final name in _stops) {
      await _fetchStopSides(name);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addStop(String name) async {
    if (_stops.contains(name)) {
      _errorMessage = '「$name」已在清單中';
      notifyListeners();
      Future.delayed(const Duration(seconds: 3), () {
        _errorMessage = '';
        notifyListeners();
      });
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = await busRepo.fetchStopData(
        name,
        myLat: _myLat,
        myLon: _myLon,
      );
      if (data.isEmpty) {
        _errorMessage = '「$name」查無站牌資料';
        _isLoading = false;
        notifyListeners();
        Future.delayed(const Duration(seconds: 3), () {
          _errorMessage = '';
          notifyListeners();
        });
        return false;
      }

      _stops = [..._stops, name];
      _storage.setStops(_stops);
      for (final side in data) {
        _sideTabs.add(SideTab(stopName: name, side: side));
      }
      _selectedStop = name;
      _selectedStopVersion++;
      _isLoading = false;
      notifyListeners();
      startAutoRefresh();
      return true;
    } catch (e) {
      _errorMessage = '「$name」資料讀取失敗';
      _isLoading = false;
      notifyListeners();
      Future.delayed(const Duration(seconds: 3), () {
        _errorMessage = '';
        notifyListeners();
      });
      return false;
    }
  }

  Future<void> _fetchStopSides(String name) async {
    try {
      final data = await busRepo.fetchStopData(
        name,
        myLat: _myLat,
        myLon: _myLon,
      );
      for (final side in data) {
        _sideTabs.add(SideTab(stopName: name, side: side));
      }
    } catch (_) {}
  }

  void reorderStop(int oldIndex, int newIndex) {
    final name = _stops.removeAt(oldIndex);
    _stops.insert(newIndex, name);

    final stopSides = _sideTabs.where((t) => t.stopName == name).toList();
    _sideTabs.removeWhere((t) => t.stopName == name);
    int insertPos = 0;
    for (int i = 0; i < newIndex; i++) {
      insertPos += _sideTabs.where((t) => t.stopName == _stops[i]).length;
    }
    _sideTabs.insertAll(insertPos, stopSides);

    _storage.setStops(_stops);
    notifyListeners();
  }

  void removeStop(String name) {
    _stops = _stops.where((s) => s != name).toList();
    _sideTabs.removeWhere((t) => t.stopName == name);
    _storage.setStops(_stops);
    if (name == _selectedStop) {
      _selectedStop = _stops.isNotEmpty ? _stops.first : null;
      _selectedStopVersion++;
    }
    if (_stops.isEmpty) {
      _lastUpdate = '';
      stopAutoRefresh();
    }
    notifyListeners();
  }

  void setThemeMode(String mode) async {
    _themeMode = mode;
    await _settingsRepo.setThemeMode(mode);
    notifyListeners();
  }

  void toggleUseDynamicColor() async {
    _useDynamicColor = !_useDynamicColor;
    await _settingsRepo.setUseDynamicColor(_useDynamicColor);
    notifyListeners();
  }

  void toggleHideNobus() async {
    _hideNobus = !_hideNobus;
    await _settingsRepo.setHideNobus(_hideNobus);
    notifyListeners();
  }

  Future<void> startLocation() async {
    _isTracking = true;
    notifyListeners();
    try {
      final pos = await _locationRepo.getCurrentPosition();
      if (pos != null) {
        _myLat = pos.latitude;
        _myLon = pos.longitude;
      }
    } catch (_) {}
    _isTracking = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    stopClock();
    stopAutoRefresh();
    super.dispose();
  }
}
