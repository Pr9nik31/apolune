import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_layer_dependencies.dart';

void main() {
  test('finds package imports and exports with leading whitespace', () {
    const source = '''
import 'package:apolune/core/model/example.dart';
  import "package:apolune/service/example.dart";
\texport 'package:apolune/pages/example.dart';
export 'package:other/package.dart';
''';

    expect(packageDirectiveLayers(source), ['core', 'service', 'pages']);
  });
}
