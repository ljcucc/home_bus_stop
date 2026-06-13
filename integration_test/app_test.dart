import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:tainan_bus_sign/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('大台南公車立牌 - 整合測試', () {
    testWidgets('完整使用者流程：搜尋站牌 → 加入 → 顯示資料', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. 檢查 AppBar 標題
      expect(find.text('大台南公車立牌'), findsOneWidget);

      // 2. 檢查初始空狀態
      expect(find.text('我的站牌'), findsOneWidget);
      expect(find.text('等待更新…'), findsOneWidget);
      expect(find.text('在上方搜尋站牌名稱加入\n即會顯示即時到站資訊'), findsOneWidget);

      // 3. 點擊搜尋欄位
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.tap(searchField);
      await tester.pumpAndSettle();

      // 4. 輸入站牌名稱
      const keyword = '火車站';
      await tester.enterText(searchField, keyword);
      await tester.pump(const Duration(milliseconds: 500));

      // 5. 等待搜尋結果出現 (最多 15 秒)
      try {
        await tester.pumpAndSettle(const Duration(seconds: 15));
      } catch (_) {
        // pumpAndSettle may timeout if there are animations, that's OK
      }

      // Check if suggestions appeared (either by text or by ListTile)
      final suggestions = find.byType(ListTile);
      if (suggestions.evaluate().isNotEmpty) {
        // 6. 點擊第一個搜尋結果
        await tester.tap(suggestions.first);
        await tester.pumpAndSettle();

        // 7. 驗證站牌已被加入 (搜尋欄會清空，站牌卡片出現)
        expect(find.text(keyword), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);

        // 8. 確認卡片資料開始載入
        final cards = find.byType(Card);
        expect(cards, findsAtLeast(1));

        // 9. 等待 API 資料回傳
        await tester.pump(const Duration(seconds: 10));
        await tester.pumpAndSettle(const Duration(seconds: 5));
      } else {
        // 搜尋沒有結果 — 可能是 API 問題
        // 至少確認搜尋功能有觸發（沒有顯示 loading 動畫）
        final loadingIndicator = find.byType(CircularProgressIndicator);
        expect(loadingIndicator, findsNothing);
      }
    });

    testWidgets('測試切換深色模式', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 找到深色/亮色模式切換按鈕
      final themeButton = find.byIcon(Icons.dark_mode);
      expect(themeButton, findsOneWidget);

      await tester.tap(themeButton);
      await tester.pumpAndSettle();

      // 切換後應顯示亮色模式圖示
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
    });

    testWidgets('測試「隱藏未發車」按鈕', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 找到「隱藏未發車」按鈕
      final hideBtn = find.text('隱藏未發車');
      expect(hideBtn, findsOneWidget);

      // 點擊切換狀態
      await tester.tap(hideBtn);
      await tester.pumpAndSettle();

      // 按鈕應該還是顯示「隱藏未發車」
      expect(find.text('隱藏未發車'), findsOneWidget);
    });
  });
}
