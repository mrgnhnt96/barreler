import 'dart:io';

import 'package:barreler/barreler.dart';
import 'package:barreler/commands/example_command.dart';

void main() {
  createBarrelerExample();
}

Future<void> createBarrelerExample() async {
  final example = ExampleCommand.createExampleContent();

  File('barreler-example.yaml').writeAsStringSync(example);
}
