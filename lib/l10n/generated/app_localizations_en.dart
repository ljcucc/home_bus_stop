// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tainan Bus Signboard';

  @override
  String get searchHint => 'Search bus stop name…';

  @override
  String get myStops => 'My Stops';

  @override
  String get hideNobus => 'Hide Non-Running';

  @override
  String get refresh => 'Refresh';

  @override
  String get noStopsHint =>
      'Search for a bus stop above\nto see real-time arrival info';

  @override
  String lastUpdate(Object time) {
    return 'Last updated: $time';
  }

  @override
  String get waitingUpdate => 'Waiting for update…';

  @override
  String get loading => 'Loading…';

  @override
  String get noData => 'No data for this stop';

  @override
  String get loadFailed => 'Failed to load data';

  @override
  String get noActiveRoutes => 'No active routes';

  @override
  String alreadyInList(Object name) {
    return '\"$name\" is already in the list';
  }

  @override
  String get arriving => 'Arriving';

  @override
  String min(Object minutes) {
    return '$minutes min';
  }

  @override
  String towards(Object dest) {
    return 'Towards $dest';
  }

  @override
  String get toVenue => 'To';

  @override
  String get roundTrip => 'Both';

  @override
  String get outbound => 'Outbound';

  @override
  String get inbound => 'Inbound';

  @override
  String get locationTracking => 'Tracking location…';

  @override
  String locationFixed(Object lat, Object lon) {
    return 'Fixed ($lat, $lon)';
  }

  @override
  String get settings => 'Settings';

  @override
  String get themeMode => 'Theme';

  @override
  String get systemTheme => 'System default';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get minute => 'min';

  @override
  String get notDeparted => 'Not departed';

  @override
  String get departed => 'Departed';
}
