# auto_pigeon

AutoPigeon extended Pigeon to support configuring the directory for generation.  
It supports adding directory options on top of the base Pigeon options.

usage: `auto_pigeon --input_dir <input files dir path> --java_package <package name> [option]*`

example: `auto_pigeon --input_dir pigeons --java_package com.example`

options:

| Option           | Help                                                                          |
|------------------|-------------------------------------------------------------------------------|
| --suffix         | Directory model suffix for generated classes or files. (defaults to "pigeon") |
| --input_dir      | Path to pigeon directory. (defaults to "pigeons")                             |
| --dart_out_dir   | Path to generated Dart source directory. (defaults to "lib")                  |
| --objc_out_dir   | Path to generated Objective-C source and header directory.                    |
| --swift_out_dir  | Path to generated swift directory. (defaults to "ios/Classes")                |
| --java_out_dir   | Path to generated Java directory. (defaults to "android/src/main/java")       |
| --kotlin_out_dir | Path to generated kotlin directory.                                           |

## Install

Install to Project

```shell
# from pub
dart pub add --dev auto_pigeon
# from git
dart pub add --dev 'auto_pigeon:{"git":"https://github.com/eitanliu/auto_pigeon.git","ref":"main"}'
```

Install to global shell

```shell
# from pub
dart pub global activate auto_pigeon
# from git
dart pub global activate -sgit git@github.com:eitanliu/auto_pigeon.git
```

## Pigeon Issues

### iOS Swift

[Pigeon: error: type 'FlutterError' does not conform to protocol 'Error'](https://github.com/flutter/flutter/issues/137057#issuecomment-1776625693), Add the following code

```swift
// This extension of Error is required to do use FlutterError in any Swift code.
extension FlutterError: Error {}
```

### Android Kotlin

When encountering class with the same name `FlutterError`, it is recommended to use Java.

## Pigeon Option
```
Pigeon is a tool for generating type-safe communication code between Flutter
and the host platform.

usage: pigeon --input <pigeon path> --dart_out <dart path> [option]*

options:
--input                                 REQUIRED: Path to pigeon file.
--dart_out                              Path to generated Dart source file (.dart). Required if one_language is not specified.
--dart_test_out                         Path to generated library for Dart tests, when using @HostApi(dartHostTestHandler:).
--objc_source_out                       Path to generated Objective-C source file (.m).
--java_out                              Path to generated Java file (.java).
--java_package                          The package that generated Java code will be in.
--[no-]java_use_generated_annotation    Adds the java.annotation.Generated annotation to the output.
--swift_out                             Path to generated Swift file (.swift).
--kotlin_out                            Path to generated Kotlin file (.kt).
--kotlin_package                        The package that generated Kotlin code will be in.
--cpp_header_out                        Path to generated C++ header file (.h).
--cpp_source_out                        Path to generated C++ classes file (.cpp).
--cpp_namespace                         The namespace that generated C++ code will be in.
--objc_header_out                       Path to generated Objective-C header file (.h).
--objc_prefix                           Prefix for generated Objective-C classes and protocols.
--copyright_header                      Path to file with copyright header to be prepended to generated code.
--[no-]one_language                     Allow Pigeon to only generate code for one language.
--ast_out                               Path to generated AST debugging info. (Warning: format subject to change)
--[no-]debug_generators                 Print the line number of the generator in comments at newlines.
--package_name                          The package that generated code will be in.
```