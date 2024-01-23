import 'package:args/args.dart';
import 'package:pigeon/pigeon.dart';
import 'package:collection/collection.dart';

class AutoPigeonOptions {
  /// Directory model suffix that will be appended after all generated classes or file.
  final String? suffix;

  /// Path to the directory which will be processed.
  final String? inputDir;

  /// Path to the dart directory that will be generated.
  final String? dartOutDir;

  /// Path to the Objective-C source and header directory will be generated.
  final String? objcOutDir;

  /// Path to the java directory that will be generated.
  final String? javaOutDir;

  /// Path to the swift directory that will be generated.
  final String? swiftOutDir;

  /// Path to the kotlin directory that will be generated.
  final String? kotlinOutDir;

  AutoPigeonOptions({
    required this.suffix,
    required this.inputDir,
    required this.dartOutDir,
    required this.objcOutDir,
    required this.javaOutDir,
    required this.swiftOutDir,
    required this.kotlinOutDir,
  });

  static AutoPigeonOptions parseArgs(List<String> args) =>
      AutoPigeonArgParser.parseArgs(args);

  static String get usage => '''
AutoPigeon extended Pigeon to support configuring the directory for generation.
It supports adding directory options on top of the base Pigeon options.

usage: auto_pigeon --kotlin_out_dir <kotlin dir path> --package_name <package name> [option]*

options:
${AutoPigeonArgParser.usage}

${Pigeon.usage}''';
}

class AutoPigeonArgParser {
  static String get usage => _argParser.usage;

  static final ArgParser _argParser = ArgParser()
    ..addOption(
      'suffix',
      defaultsTo: 'pigeon',
      help: 'Directory model suffix for generated classes or files.',
    )
    ..addOption(
      'input_dir',
      defaultsTo: 'pigeons',
      help: 'Path to pigeon.',
    )
    ..addOption(
      'dart_out_dir',
      defaultsTo: 'lib',
      help: 'Path to generated Dart source directory.',
    )
    ..addOption(
      'objc_out_dir',
      help: 'Path to generated Objective-C source and header directory.',
    )
    ..addOption(
      'swift_out_dir',
      defaultsTo: 'ios/Classes',
      help: 'Path to generated swift directory.',
    )
    ..addOption(
      'java_out_dir',
      defaultsTo: 'android/src/main/java',
      help: 'Path to generated Java directory.',
    )
    ..addOption(
      'kotlin_out_dir',
      help: 'Path to generated kotlin directory.',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Print this usage information.',
      negatable: false,
      hide: true,
    );

  /// Convert command-line arguments to [AutoPigeonOptions].
  static AutoPigeonOptions parseArgs(List<String> args) {
    final entries = _argParser.options.entries;
    final curArgs = entries
        .map((element) {
          args.contains(element.key);
          final option = element.value;
          final name = '--${option.name}';
          final abbrName = '-${option.abbr}';
          final values = <String>[];
          for (var i = 0; i < args.length; i++) {
            final param = args[i];
            if (param == name || param == abbrName) {
              switch (option.type) {
                case OptionType.flag:
                  final value = args.removeAt(i);
                  values.add(value);
                  break;
                default:
                  final start = i;
                  final end = i + 2;
                  final value = args.sublist(start, end);
                  args.removeRange(start, end);
                  values.addAll(value);
              }
            }
          }
          return values;
        })
        .flattened
        .toList();
    print("AutoPigeon Args: $curArgs");
    final ArgResults results = _argParser.parse(curArgs);

    final AutoPigeonOptions opts = AutoPigeonOptions(
      suffix: results['suffix'],
      inputDir: results['input_dir'],
      dartOutDir: results['dart_out_dir'],
      objcOutDir: results['objc_out_dir'],
      swiftOutDir: results['swift_out_dir'],
      javaOutDir: results['java_out_dir'],
      kotlinOutDir: results['kotlin_out_dir'],
    );
    return opts;
  }
}
