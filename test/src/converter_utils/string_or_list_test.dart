import 'package:test/test.dart';
import 'package:barreler/src/converter_utils/string_or_list.dart';

void main() {
  group('stringOrList', () {
    test('return null when key is not found in json', () {
      final result = stringOrList({}, 'foo');

      expect(result, isNull);
    });

    test('return null when value is not a string or list', () {
      final result = stringOrList({'foo': 42}, 'foo');

      expect(result, isNull);
    });

    test('return list with string when value is a string', () {
      final result = stringOrList({'foo': 'bar'}, 'foo');

      expect(result, ['bar']);
    });

    test('return list with strings when value is a list', () {
      final result = stringOrList({
        'foo': ['bar', 'baz']
      }, 'foo');

      expect(result, ['bar', 'baz']);
    });

    test('return list with strings when value is a list with empty strings',
        () {
      final result = stringOrList(
        {
          'foo': ['bar', '', 'baz']
        },
        'foo',
      );

      expect(result, ['bar', 'baz']);
    });
  });
}
