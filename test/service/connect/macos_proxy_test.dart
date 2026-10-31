import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:apolune/service/connect/macos_proxy.dart';

void main() {
  test('replaces tunnel inbound with a local SOCKS inbound', () {
    final original = jsonEncode({
      'inbounds': [
        {'tag': 'tunIn', 'port': 10808, 'protocol': 'dokodemo-door'},
      ],
      'outbounds': [
        {'tag': 'proxy', 'protocol': 'vless'},
        {'tag': 'direct', 'protocol': 'freedom'},
      ],
      'routing': {'rules': <dynamic>[]},
    });

    final config = MacosProxySession.localConfig(
      xrayJson: original,
      socksPort: 20801,
    );
    final inbounds = config['inbounds'] as List<dynamic>;

    expect(inbounds, hasLength(1));
    final inbound = inbounds.single as Map<String, dynamic>;
    expect(inbound['protocol'], 'socks');
    expect(inbound['listen'], '127.0.0.1');
    expect(inbound['port'], 20801);
    expect((inbound['settings'] as Map)['udp'], isTrue);

    // Выходы и маршрутизация переносятся без изменений.
    expect(config['outbounds'], hasLength(2));
    expect(config['routing'], isNotNull);
  });

  test('keeps the rest of the compiled configuration untouched', () {
    final original = jsonEncode({
      'log': {'loglevel': 'warning'},
      'inbounds': <dynamic>[],
      'outbounds': [
        {'tag': 'proxy', 'protocol': 'vless'},
      ],
      'policy': {
        'system': {'statsInboundUplink': true},
      },
    });

    final config = MacosProxySession.localConfig(
      xrayJson: original,
      socksPort: 1080,
    );

    expect(config['log'], {'loglevel': 'warning'});
    expect(config['policy'], isNotNull);
  });

  test('rejects a configuration that is not an object', () {
    expect(
      () => MacosProxySession.localConfig(xrayJson: '[]', socksPort: 1080),
      throwsFormatException,
    );
  });
}
