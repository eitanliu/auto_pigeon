import 'dart:io' show exit;

import 'package:auto_pigeon/auto_pigeon.dart' as auto_pigeon;

Future<void> main(List<String> arguments) async {
  exit(await auto_pigeon.runCommandLine(arguments));
}
