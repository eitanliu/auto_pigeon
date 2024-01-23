import 'dart:io';

import 'package:auto_pigeon/auto_pigeon_config.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:pigeon/pigeon_cl.dart' as pigeon;
import 'package:pigeon/pigeon_lib.dart';

/// Command Line
Future<int> runCommandLine(
  List<String> arguments, {
  Uri? packageConfig,
  String? sdkPath,
}) async {
  final args = [...arguments];
  if (args.contains('--help') || args.contains('-h')) {
    print(AutoPigeonOptions.usage);
    return 0;
  }
  final AutoPigeonOptions dirOptions = AutoPigeonOptions.parseArgs(args);

  print('Pigeon Base Args: $args');
  final PigeonOptions options = Pigeon.parseArgs(args);

  final inputDirStr = dirOptions.inputDir;
  if (inputDirStr == null || inputDirStr.isEmpty) {
    print('--input_dir option is empty');
    return exitCode;
  }
  final Directory inputDir = Directory(inputDirStr);
  if (!inputDir.existsSync()) {
    print('no find input_dir $inputDir');
    exit(exitCode);
  }

  String suffix = dirOptions.suffix ?? '';
  if (suffix.isNotEmpty) suffix = '_$suffix';

  String? dartOutDir = dirOptions.dartOutDir;
  if (dartOutDir == null || dartOutDir.isEmpty) {
    print('--dart_dir option is empty');
    return exitCode;
  }
  final javaOutDir = dirOptions.javaOutDir;
  final kotlinOutDir = dirOptions.kotlinOutDir;
  final objcOutDir = dirOptions.objcOutDir;
  final swiftOutDir = dirOptions.swiftOutDir;

  final List<FileSystemEntity> list = inputDir.listSync(recursive: true);
  final List<String> inputDirs = path.split(inputDirStr);
  for (FileSystemEntity element in list) {
    if (element is File) {
      final String input = element.path;
      final List<String> fileParents = path.split(input);
      final String fileName = path.basenameWithoutExtension(input);
      final String snakeCaseName = _replaceNoStandardKey('$fileName$suffix');
      final String pascalCaseName = snakeToPascalCase(snakeCaseName);

      final List<String> middle = fileParents.sublist(
        inputDirs.length,
        fileParents.length - 1,
      );

      final dartFile = path.join(
        dartOutDir.replaceAll('/', path.separator),
        middle.join(path.separator),
        '$snakeCaseName.dart',
      );

      List<String> addJavaArgs() {
        if (javaOutDir == null || javaOutDir.isEmpty) return List.empty();

        final package = options.javaOptions?.package;
        final javaFile = path.join(
          javaOutDir.replaceAll('/', path.separator),
          package?.replaceAll('.', path.separator) ?? '',
          middle.join(path.separator),
          '$pascalCaseName.java',
        );
        _createParentDirs(javaFile);

        return [
          '--java_out',
          javaFile,
          if (package != null && middle.isNotEmpty) ...[
            '--java_package',
            '$package.${middle.join('.')}',
          ]
        ];
      }

      List<String> addKotlinArgs() {
        if (kotlinOutDir == null || kotlinOutDir.isEmpty) return List.empty();

        final package = options.kotlinOptions?.package;
        final kotlinFile = path.join(
          kotlinOutDir.replaceAll('/', path.separator),
          package?.replaceAll('.', path.separator) ?? '',
          middle.join(path.separator),
          '$pascalCaseName.kt',
        );
        _createParentDirs(kotlinFile);

        return [
          '--kotlin_out',
          kotlinFile,
          if (package != null && middle.isNotEmpty) ...[
            '--kotlin_package',
            '$package.${middle.join('.')}',
          ]
        ];
      }

      List<String> addObjcArgs() {
        if (objcOutDir == null || objcOutDir.isEmpty) return List.empty();

        final objcHeaderFile = path.join(
          objcOutDir.replaceAll('/', path.separator),
          middle.join(path.separator),
          '$pascalCaseName.h',
        );
        final objcSourceFile = path.join(
          objcOutDir.replaceAll('/', path.separator),
          middle.join(path.separator),
          '$pascalCaseName.m',
        );
        _createParentDirs(objcHeaderFile);
        _createParentDirs(objcSourceFile);

        return [
          '--objc_header_out',
          objcHeaderFile,
          '--objc_source_out',
          objcSourceFile,
        ];
      }

      List<String> addSwiftArgs() {
        if (swiftOutDir == null || swiftOutDir.isEmpty) return List.empty();

        final swiftFile = path.join(
          swiftOutDir.replaceAll('/', path.separator),
          middle.join(path.separator),
          '$pascalCaseName.swift',
        );
        _createParentDirs(swiftFile);

        return [
          '--swift_out',
          swiftFile,
        ];
      }

      _createParentDirs(dartFile);

      final List<String> fileArgs = <String>[
        ...args,
        '--input',
        input,
        '--dart_out',
        dartFile,
        if (_isNotNullAndEmpty(javaOutDir)) ...addJavaArgs(),
        if (_isNotNullAndEmpty(kotlinOutDir)) ...addKotlinArgs(),
        if (_isNotNullAndEmpty(objcOutDir)) ...addObjcArgs(),
        if (_isNotNullAndEmpty(swiftOutDir)) ...addSwiftArgs(),
      ];

      print('============================');
      print('Pigeon file $input');
      print('Pigeon args $fileArgs');
      final code = await pigeon.runCommandLine(fileArgs);
      print('Pigeon result $code $input');
    }
  }
  return exitCode;
}

/// 驼峰转下划线
/// AaBbCc -> aa_bb_cc
String pascalToSnakeCase(String str) {
  return str.replaceAllMapped(RegExp(r'(^[A-Z])|([A-Z])'), (Match match) {
    if (match[2] != null) {
      return '_${match[2]?.toLowerCase()}';
    } else {
      return match[1]?.toLowerCase() ?? '';
    }
  });
}

/// aa_bb_cc -> AaBbCc
String snakeToPascalCase(String snakeCase) {
  return snakeToCamelCase(snakeCase, firstWord: true);
}

/// aa_bb_cc -> aaBbCc
String snakeToCamelCase(String snakeCase, {bool firstWord = false}) {
  final words = snakeCase.split("_");
  final camelCase = words.mapIndexed((index, word) {
    if (word.isEmpty) return word;
    if (index == 0 && !firstWord) {
      return word;
    } else {
      return word.replaceRange(0, 1, word[0].toUpperCase());
    }
  }).join();
  return camelCase;
}

String _replaceNoStandardKey(String value, {String replacement = '_'}) {
  final regex = RegExp("[^a-zA-Z0-9]+");
  return value.replaceAll(regex, replacement);
}

void _createParentDirs(String path) {
  if (path != 'stdout') {
    File file = File(path);
    file.parent.createSync(recursive: true);
  }
}

bool _isNullOrEmpty(String? str) => str == null || str.isEmpty;

bool _isNotNullAndEmpty(String? str) => str != null && str.isNotEmpty;
