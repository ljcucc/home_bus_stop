import '../services/storage_service.dart';

class SettingsRepository {
  final StorageService _storage;

  SettingsRepository(this._storage);

  bool get isDark => _storage.getTheme() == 'dark';
  bool get hideNobus => _storage.getHideNobus();

  Future<void> setDarkMode(bool value) =>
      _storage.setTheme(value ? 'dark' : 'light');

  Future<void> setHideNobus(bool value) => _storage.setHideNobus(value);
}
