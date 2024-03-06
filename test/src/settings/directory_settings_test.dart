import 'package:barreler/src/settings/directory_settings.dart';
import 'package:barreler/src/settings/export_settings.dart';
import 'package:test/test.dart';

void main() {
  group('$DirectorySettings', () {
    group('serializes', () {
      test('when empty throws an error', () {
        expect(
          () => DirectorySettings.fromJson({}),
          throwsA(isA<Exception>()),
        );
      });

      test('successfully parses when path is only included', () {
        final settings = DirectorySettings.fromJson({
          'path': 'lib',
        });

        expect(settings, isA<DirectorySettings>());
      });

      for (final key in ['include', 'exports']) {
        group('#$key', () {
          void verify(
            DirectorySettings settings, {
            required List<String> expected,
          }) {
            final exportSettings = switch (key) {
              'include' => settings.include,
              'exports' => settings.exports,
              _ => throw ArgumentError('Invalid key: $key'),
            };

            expect(exportSettings, hasLength(expected.length));

            for (var i = 0; i < expected.length; i++) {
              expect(exportSettings[i], isA<ExportSettings>());
              expect(exportSettings[i].export, expected[i]);
            }
          }

          test('successfully parses string', () {
            final settings = DirectorySettings.fromJson({
              key: 'foo',
              'path': 'lib',
            });

            verify(settings, expected: ['foo']);
          });

          test('successfully parses list', () {
            final settings = DirectorySettings.fromJson({
              key: ['foo', 'bar'],
              'path': 'lib',
            });

            verify(settings, expected: ['foo', 'bar']);
          });

          test('successfully parses map', () {
            final settings = DirectorySettings.fromJson({
              key: {'export': 'foo'},
              'path': 'lib',
            });

            verify(settings, expected: ['foo']);
          });

          test('successfully parses list of maps', () {
            final settings = DirectorySettings.fromJson({
              key: [
                {'export': 'foo'},
                {'export': 'bar'},
              ],
              'path': 'lib',
            });

            verify(settings, expected: ['foo', 'bar']);
          });
        });
      }
    });

    group('#resolveFileName', () {
      test('returns default file name', () {
        final settings = DirectorySettings(
          dirPath: 'lib',
        );

        expect(settings.resolveFileName('index.dart'), 'index.dart');
      });

      test('returns custom file name', () {
        final settings = DirectorySettings(
          dirPath: 'lib',
          fileName: 'foo.dart',
        );

        expect(settings.resolveFileName('index.dart'), 'foo.dart');
      });

      test('returns directory name', () {
        final settings = DirectorySettings(
          dirPath: 'lib/foo',
        );

        expect(settings.resolveFileName(null), 'foo');
      });
    });

    test('#changePath changes only path', () {
      final settings = DirectorySettings(
        dirPath: 'lib',
        fileName: 'index.dart',
        disclaimer: true,
        comments: 'Generated by barreler',
        exports: [
          ExportSettings(export: 'foo'),
        ],
        include: [
          ExportSettings(export: 'bar'),
        ],
        exclude: ['baz'],
      );

      final expected = DirectorySettings(
        dirPath: 'foo',
        fileName: 'index.dart',
        disclaimer: true,
        comments: 'Generated by barreler',
        exports: [
          ExportSettings(export: 'foo'),
        ],
        include: [
          ExportSettings(export: 'bar'),
        ],
        exclude: ['baz'],
      );

      expect(settings.changePath('foo'), expected);
    });
  });
}
