import 'package:barreler/src/args/any_arg_parser.dart';
import 'package:test/test.dart';

void main() {
  group('$AnyArgParser', () {
    test('should add flag', () {
      final argParser = AnyArgParser()..addFlag('flag');
      expect(argParser.options, contains('flag'));
    });

    test('should parse flag', () {
      final argParser = AnyArgParser()..addFlag('flag');
      final result = argParser.parse(['--flag']);
      expect(result['flag'], isTrue);
    });

    test('should parse no flag', () {
      final argParser = AnyArgParser();
      final result = argParser.parse(['flag']);

      expect(result.rest, ['flag']);
    });

    test('should parse extra flags', () {
      final argParser = AnyArgParser();
      final result = argParser.parse(['--flag', '-c']);
      expect(
        () => result['flag'],
        throwsA(isA<ArgumentError>()),
      );

      expect(result.rest, ['--flag', '-c']);
    });

    test('should parse extra short flags', () {
      final argParser = AnyArgParser();
      final result = argParser.parse(['-f', '-c', '-de']);
      expect(
        () => result['f'],
        throwsA(isA<ArgumentError>()),
      );

      expect(result.rest, ['-f', '-c', '-d', '-e']);
    });

    test('should parse extra short flags with values', () {
      final argParser = AnyArgParser();
      final result = argParser.parse(['-f', '-c', '-de', 'hello']);
      expect(
        () => result['f'],
        throwsA(isA<ArgumentError>()),
      );

      expect(result.rest, ['-f', '-c', '-d', '-e', 'hello']);
    });

    group('should parse any flag with value', () {
      test('when separated by space', () {
        final argParser = AnyArgParser();
        final result = argParser.parse(['--flag']);
        expect(
          () => result['flag'],
          throwsA(isA<ArgumentError>()),
        );

        expect(result.rest, contains('--flag'));
      });

      test('when separated by equal sign', () {
        final argParser = AnyArgParser();
        final result = argParser.parse(['--flag=value']);
        expect(
          () => result['flag'],
          throwsA(isA<ArgumentError>()),
        );

        expect(result.rest, contains('--flag=value'));
      });
    });

    group('should parse actual flag after any flag', () {
      test('(1)', () {
        final argParser = AnyArgParser()..addFlag('flag');
        final result = argParser.parse(['--something', 'banana', '--flag']);

        expect(result['flag'], isTrue);

        expect(result.rest, ['--something', 'banana']);
      });

      test('(2)', () {
        final argParser = AnyArgParser()
          ..addFlag('list')
          ..addFlag('bail');
        final result =
            argParser.parse(['try', '--platform', 'banana', '--bail']);

        expect(result['bail'], isTrue);

        expect(result.rest, ['try', '--platform', 'banana']);
      });
    });
  });
}
