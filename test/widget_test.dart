import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tainan_bus_sign/domain/models/route_info.dart';
import 'package:tainan_bus_sign/ui/core/widgets/route_row.dart';

void main() {
  group('RouteRow', () {
    testWidgets('displays route info correctly', (tester) async {
      const route = RouteInfo(
        routeName: '99',
        dest: '臺南轉運站',
        timeLabel: '3 分',
        timeClass: 'approaching',
        numeric: 3,
        goback: '0',
        dir: '往程',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteRow(route: route),
          ),
        ),
      );

      expect(find.text('99'), findsOneWidget);
      expect(find.text('往程 臺南轉運站'), findsOneWidget);
      expect(find.text('3 分'), findsOneWidget);
    });

    testWidgets('shows arriving style for imminent bus', (tester) async {
      const route = RouteInfo(
        routeName: '1',
        dest: '火車站',
        timeLabel: '即將進站',
        timeClass: 'arriving',
        numeric: 1,
        goback: '0',
        dir: '往程',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteRow(route: route),
          ),
        ),
      );

      expect(find.text('即將進站'), findsOneWidget);
    });

    testWidgets('shows nobus style for non-running bus', (tester) async {
      const route = RouteInfo(
        routeName: '2',
        dest: '安平',
        timeLabel: '未發車',
        timeClass: 'nobus',
        numeric: double.infinity,
        goback: '0',
        dir: '往程',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteRow(route: route),
          ),
        ),
      );

      expect(find.text('未發車'), findsOneWidget);
    });
  });
}
