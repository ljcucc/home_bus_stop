import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/repositories/bus_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../data/repositories/location_repository.dart';
import '../../../../data/services/storage_service.dart';

class HomeViewModel extends ChangeNotifier {
  final BusRepository busRepo;
  final SettingsRepository _settingsRepo;
  final LocationRepository _locationRepo;
  final StorageService _storage;

  List<String> _stops;
  bool _hideNobus;
  String _themeMode;
  double? _myLat;
  double? _myLon;
  bool _isTracking = false;
  String _lastUpdate = '';
  String _errorMessage = '';
  DateTime _currentTime = DateTime.now();
  int _refreshKey = 0;
  Timer? _refreshTimer;
  Timer? _clockTimer;

  HomeViewModel({
    required this.busRepo,
    required this._settingsRepo,
    required this._locationRepo,
    required this._storage,
    required List<String> initialStops,
  })  : _stops = initialStops,
        _hideNobus = _settingsRepo.hideNobus,
        _themeMode = _settingsRepo.themeMode;

  List<String> get stops => _stops;
  bool get hideNobus => _hideNobus;
  String get themeMode => _themeMode;
  double? get myLat => _myLat;
  double? get myLon => _myLon;
  bool get isTracking => _isTracking;
  String get lastUpdate => _lastUpdate;
  String get errorMessage => _errorMessage;
  DateTime get currentTime => _currentTime;
  int get refreshKey => _refreshKey;

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

  void refresh() {
    _refreshKey++;
    final now = DateTime.now();
    _lastUpdate =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    notifyListeners();
  }

  bool addStop(String name) {
    if (_stops.contains(name)) {
      _errorMessage = '「$name」已在清單中';
      notifyListeners();
      Future.delayed(const Duration(seconds: 3), () {
        _errorMessage = '';
        notifyListeners();
      });
      return false;
    }
    _stops = [..._stops, name];
    _storage.setStops(_stops);
    notifyListeners();
    startAutoRefresh();
    return true;
  }

  void removeStop(String name) {
    _stops = _stops.where((s) => s != name).toList();
    _storage.setStops(_stops);
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
