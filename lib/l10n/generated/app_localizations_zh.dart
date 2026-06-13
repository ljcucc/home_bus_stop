// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '大台南公車立牌';

  @override
  String get searchHint => '搜尋站牌名稱…';

  @override
  String get myStops => '我的站牌';

  @override
  String get hideNobus => '隱藏未發車';

  @override
  String get refresh => '重新整理';

  @override
  String get noStopsHint => '在上方搜尋站牌名稱加入\n即會顯示即時到站資訊';

  @override
  String lastUpdate(Object time) {
    return '最後更新：$time';
  }

  @override
  String get waitingUpdate => '等待更新…';

  @override
  String get loading => '載入中…';

  @override
  String get noData => '查無此站牌資料';

  @override
  String get loadFailed => '資料讀取失敗';

  @override
  String get noActiveRoutes => '無營運路線';

  @override
  String alreadyInList(Object name) {
    return '「$name」已在清單中';
  }

  @override
  String get arriving => '即將進站';

  @override
  String min(Object minutes) {
    return '$minutes 分';
  }

  @override
  String towards(Object dest) {
    return '往 $dest';
  }

  @override
  String get toVenue => '往';

  @override
  String get roundTrip => '雙向';

  @override
  String get outbound => '往程';

  @override
  String get inbound => '返程';

  @override
  String get locationTracking => '定位中…';

  @override
  String locationFixed(Object lat, Object lon) {
    return '已定位 ($lat, $lon)';
  }

  @override
  String get darkMode => '深色模式';

  @override
  String get lightMode => '淺色模式';

  @override
  String get fullscreen => '全螢幕';

  @override
  String get exitFullscreen => '離開全螢幕';

  @override
  String get minute => '分';

  @override
  String get notDeparted => '未發車';

  @override
  String get departed => '已發車';
}
