## Use this package as an executable

**Install it**

You can install the package from the command line:

```shell
dart pub global activate auto_pigeon
```

**Use it**

The package has the following executables:

```shell
auto_pigeon --input_dir pigeons --java_package com.example
```

## Use this package as a library

**Depend on it**

Run this command:

With Dart:

```shell
dart pub add --dev auto_pigeon
```

This will add a line like this to your package's pubspec.yaml (and run an implicit dart pub get):

```yaml
dependencies_dev:
  auto_pigeon: ^1.0.1
```

Alternatively, your editor might support `dart pub get`. Check the docs for your editor to learn more.

**Use it**

Now, you can run this command:

```shell
dart run auto_pigeon
```