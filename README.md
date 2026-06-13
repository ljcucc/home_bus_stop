# Tainan Bus Stop Sign

A real-time bus departure information board for Tainan City. Built with Flutter.

## Features

- **Search & Track** – Search for bus stops by name and add them to your list
- **Real-time Arrivals** – Displays estimated arrival times for every route at each stop, fetched from the official Tainan City bus API
- **Geolocation** – Optionally use your current location to see distance to each stop
- **Hide Non-Operating** – Toggle to hide routes that are not currently running
- **Fullscreen Mode** – Turn the page into a dedicated information display
- **Dark / Light Theme** – Switch between dark and light modes
- **Auto Refresh** – Arrival data refreshes every 30 seconds automatically
- **Multi-language** – Supports Traditional Chinese and English

## Screenshots

<img src="screenshot.png" width="360" alt="App Screenshot"/>

## Getting Started

```bash
flutter pub get
flutter run
```

## Testing

```bash
flutter test
```

## Data Source

Real-time data is provided by [Tainan City Bus Information System](https://2384.tainan.gov.tw/).

## Tech Stack

- Flutter / Dart
- MVVM + Repository + Service architecture
- go_router (navigation)
- http (API client)
- shared_preferences (local storage)
- geolocator (GPS)
- flutter_localizations (i18n)

## License

MIT
