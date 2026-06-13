import 'package:flutter_test/flutter_test.dart';
import 'package:tainan_bus_sign/data/repositories/bus_repository.dart';

void main() {
  group('calcDistance', () {
    test('returns 0 for same point', () {
      expect(calcDistance(23.0, 120.0, 23.0, 120.0), equals(0));
    });

    test('returns positive distance for different points', () {
      final dist = calcDistance(22.99, 120.20, 23.00, 120.21);
      expect(dist, greaterThan(0));
    });

    test('distance between Tainan stations is reasonable', () {
      final dist = calcDistance(22.9947, 120.2069, 23.0000, 120.2100);
      expect(dist, greaterThan(100));
      expect(dist, lessThan(2000));
    });
  });

  group('formatDist', () {
    test('formats meters', () {
      expect(formatDist(500), '500m');
      expect(formatDist(999), '999m');
      expect(formatDist(0), '0m');
    });

    test('formats kilometers', () {
      expect(formatDist(1000), '1.0km');
      expect(formatDist(1500), '1.5km');
      expect(formatDist(12345), '12.3km');
    });
  });
}
