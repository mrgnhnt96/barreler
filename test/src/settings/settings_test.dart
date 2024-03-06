import 'package:test/test.dart';
import 'package:barreler/src/settings/settings.dart';

void main() {
  group('$Settings', () {
    group('#serializes', () {
      test('empty object', () {
        final settings = Settings.fromJson({});

        expect(settings, isA<Settings>());
      });
    });
  });
}
