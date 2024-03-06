import 'package:test/test.dart';
import 'package:barreler/src/extensions/string_extension.dart';

void main() {
  group('StringX', () {
    group('#removeWrapping', () {
      test('removes leading empty lines', () {
        final lines = '\n\n\nfoo\nbar'.removeWrapping().toList();

        expect(lines, hasLength(2));
        expect(lines[0], 'foo');
        expect(lines[1], 'bar');
      });

      test('removes trailing empty lines', () {
        final lines = 'foo\nbar\n\n\n'.removeWrapping().toList();

        expect(lines, hasLength(2));
        expect(lines[0], 'foo');
        expect(lines[1], 'bar');
      });

      test('trims leading and trailing spaces', () {
        final lines = '  foo  \n  bar  '.removeWrapping().toList();

        expect(lines, hasLength(2));
        expect(lines[0], 'foo');
        expect(lines[1], 'bar');
      });
    });

    group('#relativeTo', () {
      test('removes leading directory', () {
        final path = '/foo/bar'.relativeTo('/foo');

        expect(path, endsWith('bar'));
      });

      test('removes leading non-letter characters', () {
        final path = './bar/foo/bar'.relativeTo('/bar');

        expect(path, 'foo/bar');
      });

      test('leaves private files alone', () {
        final path = './bar/__foo/bar'.relativeTo('/bar');

        expect(path, '__foo/bar');
      });
    });
  });
}
