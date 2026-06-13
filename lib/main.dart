import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/generated/app_localizations.dart';
import 'data/services/bus_api_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/location_service.dart';
import 'data/repositories/bus_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/location_repository.dart';
import 'ui/core/theme.dart';
import 'ui/features/home/view_models/home_view_model.dart';
import 'ui/features/home/views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  await storage.init();
  runApp(TainanBusSignApp(storage: storage));
}

class TainanBusSignApp extends StatefulWidget {
  final StorageService storage;

  const TainanBusSignApp({super.key, required this.storage});

  @override
  State<TainanBusSignApp> createState() => _TainanBusSignAppState();
}

class _TainanBusSignAppState extends State<TainanBusSignApp> {
  late final BusRepository _busRepo;
  late final SettingsRepository _settingsRepo;
  late final LocationRepository _locationRepo;
  late final HomeViewModel _homeVM;

  @override
  void initState() {
    super.initState();
    final busApi = BusApiService();
    final locationService = LocationService();
    _busRepo = BusRepository(busApi);
    _settingsRepo = SettingsRepository(widget.storage);
    _locationRepo = LocationRepository(locationService);
    _homeVM = HomeViewModel(
      busRepo: _busRepo,
      settingsRepo: _settingsRepo,
      locationRepo: _locationRepo,
      storage: widget.storage,
      initialStops: widget.storage.getStops(),
    );
  }

  ThemeMode _resolveThemeMode(String mode) {
    switch (mode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  @override
  void dispose() {
    _homeVM.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _homeVM,
      child: Consumer<HomeViewModel>(
        builder: (context, vm, child) {
          return MaterialApp(
            title: '大台南公車立牌',
            debugShowCheckedModeBanner: false,
            themeMode: _resolveThemeMode(vm.themeMode),
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh'),
              Locale('en'),
            ],
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
