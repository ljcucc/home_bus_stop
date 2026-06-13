# 大台南公車立牌

台南市公車即時到站資訊顯示面板。使用 Flutter 建置。

## 功能

- **站牌搜尋** – 輸入站牌名稱即可搜尋並加入追蹤清單
- **即時到站** – 顯示各站牌每條路線的預估到站時間，資料來源為台南市公車官方 API
- **地理定位** – 可啟用定位功能查看與站牌的距離
- **隱藏未發車** – 一鍵切換，只顯示營運中路線
- **全螢幕模式** – 轉換為專用資訊看板
- **深色 / 淺色主題** – 支援明暗主題切換
- **自動重新整理** – 每 30 秒自動更新到站資料
- **多國語言** – 支援繁體中文與英文

## 螢幕截圖

<img src="screenshot.png" width="360" alt="App Screenshot"/>

## 開始使用

```bash
flutter pub get
flutter run
```

## 測試

```bash
flutter test
```

## 資料來源

即時公車資料由[大台南公車資訊系統](https://2384.tainan.gov.tw/)提供。

## 技術棧

- Flutter / Dart
- MVVM + Repository + Service 架構
- go_router（導航）
- http（API 客戶端）
- shared_preferences（本地儲存）
- geolocator（GPS 定位）
- flutter_localizations（多國語系）

## 授權

MIT
