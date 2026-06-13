import '../services/storage_service.dart';

class SettingsRepository {
  final StorageService _storage;

  SettingsRepository(this._storage);

  String get themeMode => _storage.getTheme();
  bool get hideNobus => _storage.getHideNobus();
  bool get useDynamicColor => _storage.getUseDynamicColor();

  Future<void> setThemeMode(String value) => _storage.setTheme(value);

  Future<void> setHideNobus(bool value) => _storage.setHideNobus(value);

  Future<void> setUseDynamicColor(bool value) =>
      _storage.setUseDynamicColor(value);
}
