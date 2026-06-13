import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _themeKey = 'tnBusTheme';
  static const _hideNobusKey = 'tnBusHideNobus';
  static const _useDynamicColorKey = 'tnBusDynamicColor';
  static const _stopsKey = 'tnBusStops';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String getTheme() => _prefs?.getString(_themeKey) ?? 'system';

  Future<void> setTheme(String value) => _prefs!.setString(_themeKey, value);

  bool getHideNobus() => _prefs?.getBool(_hideNobusKey) ?? true;

  Future<void> setHideNobus(bool value) =>
      _prefs!.setBool(_hideNobusKey, value);

  bool getUseDynamicColor() => _prefs?.getBool(_useDynamicColorKey) ?? true;

  Future<void> setUseDynamicColor(bool value) =>
      _prefs!.setBool(_useDynamicColorKey, value);

  List<String> getStops() => _prefs?.getStringList(_stopsKey) ?? [];

  Future<void> setStops(List<String> stops) =>
      _prefs!.setStringList(_stopsKey, stops);
}
