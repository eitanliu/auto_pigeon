import 'package:auto_pigeon/auto_pigeon.dart';
import 'package:test/test.dart';

void main() {
  test('test args', () async {
    await runCommandLine([
      ...['--dart_out_dir', 'build/dart'],
      ...['--java_out_dir', 'build/java'],
      ...['--kotlin_out_dir', 'build/kotlin'],
      ...['--objc_out_dir', 'build/objc'],
      ...['--swift_out_dir', 'build/swift'],
    ]);
  });
}
