import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tainan_bus_sign/data/models/api_suggestion.dart';
import 'package:tainan_bus_sign/data/models/api_stop_data.dart';
import 'package:tainan_bus_sign/data/models/api_route_info.dart';
import 'package:tainan_bus_sign/data/repositories/bus_repository.dart';
import 'package:tainan_bus_sign/data/repositories/location_repository.dart';
import 'package:tainan_bus_sign/data/repositories/settings_repository.dart';
import 'package:tainan_bus_sign/data/services/bus_api_service.dart';
import 'package:tainan_bus_sign/data/services/location_service.dart';
import 'package:tainan_bus_sign/data/services/storage_service.dart';
import 'package:tainan_bus_sign/ui/core/theme.dart';
import 'package:tainan_bus_sign/ui/features/home/view_models/home_view_model.dart';
import 'package:tainan_bus_sign/ui/features/home/views/home_screen.dart';

class _MockBusApiService extends BusApiService {
  @override
  Future<List<ApiSuggestion>> searchStops(String keyword) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (keyword.contains('火車站')) {
      return [
        ApiSuggestion(name: '臺南火車站', lat: '22.9975', lon: '120.2128'),
        ApiSuggestion(name: '臺南火車站(北站)', lat: '22.9985', lon: '120.2135'),
      ];
    }
    return [];
  }

  @override
  Future<List<ApiStopLocation>> fetchStopData(String stopName) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ApiStopLocation(
        locationId: '1',
        info: [
          ApiRouteInfo(
            routeName: '5', goBack: '0', dest: '市立醫院', dept: '火車站',
            time: '3', lat: '22.9975', lon: '120.2128',
          ),
          ApiRouteInfo(
            routeName: '6', goBack: '1', dest: '火車站', dept: '裕義路',
            time: '1', lat: '22.9975', lon: '120.2128',
          ),
          ApiRouteInfo(
            routeName: '99', goBack: '0', dest: '臺南轉運站', dept: '火車站',
            time: '15', lat: '22.9975', lon: '120.2128',
          ),
          ApiRouteInfo(
            routeName: '18', goBack: '0', dest: '國民路', dept: '火車站',
            time: '未發車', lat: '22.9975', lon: '120.2128',
          ),
        ],
      ),
    ];
  }
}

class _MockLocationService extends LocationService {
  final Completer<void>? pause;

  _MockLocationService({this.pause});

  @override
  Future<Position?> getCurrentPosition() async {
    await pause?.future;
    return Position(
      latitude: 22.9997, longitude: 120.2139,
      timestamp: DateTime.now(), accuracy: 10.0, altitude: 0.0,
      altitudeAccuracy: 10.0, heading: 0.0, headingAccuracy: 0.0,
      speed: 0.0, speedAccuracy: 0.0,
    );
  }
}

Future<StorageService> createTestStorage() async {
  SharedPreferences.setMockInitialValues({});
  final storage = StorageService();
  await storage.init();
  return storage;
}

Widget buildTestApp(HomeViewModel vm) {
  return ChangeNotifierProvider.value(
    value: vm,
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const HomeScreen(),
    ),
  );
}

void main() {
  late StorageService storage;
  late BusApiService mockApi;
  late BusRepository busRepo;
  late SettingsRepository settingsRepo;
  late LocationRepository locationRepo;

  setUp(() async {
    storage = await createTestStorage();
    mockApi = _MockBusApiService();
    busRepo = BusRepository(mockApi);
    settingsRepo = SettingsRepository(storage);
    locationRepo = LocationRepository(_MockLocationService());
  });

  group('完整使用者流程', () {
    testWidgets('初始畫面顯示正確', (tester) async {
      final vm = HomeViewModel(
        busRepo: busRepo,
        settingsRepo: settingsRepo,
        locationRepo: locationRepo,
        storage: storage,
        initialStops: [],
      );

      await tester.pumpWidget(buildTestApp(vm));
      await tester.pump();

      expect(find.text('大台南公車立牌'), findsOneWidget);
      expect(find.text('等待更新…'), findsOneWidget);
      expect(
        find.text('在上方搜尋站牌名稱加入\n即會顯示即時到站資訊'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsOneWidget);

      vm.dispose();
    });

    testWidgets('搜尋站牌 → 點擊加入 → 站牌出現在清單', (tester) async {
      final vm = HomeViewModel(
        busRepo: busRepo,
        settingsRepo: settingsRepo,
        locationRepo: locationRepo,
        storage: storage,
        initialStops: [],
      );

      await tester.pumpWidget(buildTestApp(vm));
      await tester.pump();

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.enterText(find.byType(TextField), '火車站');
      await tester.pump(const Duration(milliseconds: 600));

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(ListTile), findsAtLeast(1));

      await tester.tap(find.byType(ListTile).first);
      await tester.pump();

      expect(find.text('臺南火車站'), findsOneWidget);

      vm.dispose();
    });

    testWidgets('加入重複站牌會顯示錯誤', (tester) async {
      final vm = HomeViewModel(
        busRepo: busRepo,
        settingsRepo: settingsRepo,
        locationRepo: locationRepo,
        storage: storage,
        initialStops: ['臺南火車站'],
      );

      await tester.pumpWidget(buildTestApp(vm));
      await tester.pump();

      expect(find.text('臺南火車站'), findsOneWidget);

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.enterText(find.byType(TextField), '火車站');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byType(ListTile).first);
      await tester.pump();

      expect(find.text('「臺南火車站」已在清單中'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      expect(find.text('「臺南火車站」已在清單中'), findsNothing);

      vm.dispose();
    });

    testWidgets('切換主題模式 — 開啟設定選單並選取深色模式', (tester) async {
      final vm = HomeViewModel(
        busRepo: busRepo,
        settingsRepo: settingsRepo,
        locationRepo: locationRepo,
        storage: storage,
        initialStops: [],
      );

      await tester.pumpWidget(buildTestApp(vm));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();

      expect(find.text('系統預設'), findsOneWidget);
      expect(find.text('淺色模式'), findsOneWidget);
      expect(find.text('深色模式'), findsOneWidget);

      await tester.tap(find.text('深色模式'));
      await tester.pump();

      expect(vm.themeMode, 'dark');

      vm.dispose();
    });

    testWidgets('定位功能 — 顯示定位中與定位完成狀態', (tester) async {
      final pause = Completer<void>();
      final locationRepo = LocationRepository(_MockLocationService(pause: pause));

      final vm = HomeViewModel(
        busRepo: busRepo,
        settingsRepo: settingsRepo,
        locationRepo: locationRepo,
        storage: storage,
        initialStops: [],
      );

      await tester.pumpWidget(buildTestApp(vm));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.location_on_outlined));
      await tester.pump();

      expect(find.text('定位中…'), findsOneWidget);

      pause.complete();
      await tester.pump();

      expect(find.textContaining('已定位'), findsOneWidget);

      vm.dispose();
    });
  });
}
