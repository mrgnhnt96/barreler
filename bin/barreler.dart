import 'dart:io';

import 'package:barreler/barreler_runner.dart';
import 'package:file/local.dart';
import 'package:mason_logger/mason_logger.dart';

void main(List<String> rawArgs) async {
  await flushThenExit(await run(rawArgs));
}

Future<int> run(List<String> rawArgs) async {
  final args = List<String>.from(rawArgs);

  var loud = false;
  var quiet = false;
  if (args.contains('--quiet')) {
    quiet = true;
  } else if (args.contains('--loud')) {
    loud = true;
  }

  final logger = Logger(
    level: quiet
        ? Level.quiet
        : loud
            ? Level.verbose
            : Level.info,
  );

  final fs = LocalFileSystem();

  final exitCode = await BarrelerRunner(
    logger: logger,
    fs: fs,
  ).run(args);

  logger.flush();

  return exitCode;
}

/// Flushes the stdout and stderr streams, then exits the program with the given
/// status code.
///
/// This returns a Future that will never complete, since the program will have
/// exited already. This is useful to prevent Future chains from proceeding
/// after you've decided to exit.
Future<dynamic> flushThenExit(int status) {
  return Future.wait<void>([stdout.close(), stderr.close()])
      .then<void>((_) => exit(status));
}