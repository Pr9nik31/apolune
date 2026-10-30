import 'dart:io';

Future<Directory> createTestDirectory(String prefix) async {
  final root = Directory('../references/apolune-tests/dart').absolute;
  await root.create(recursive: true);
  return root.createTemp(prefix);
}
