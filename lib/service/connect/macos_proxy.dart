import 'dart:convert';
import 'dart:io';

import 'package:apolune/core/ffi/base_ffi_api.dart';
import 'package:apolune/core/pigeon/messages.g.dart';
import 'package:apolune/core/tools/platform.dart';
import 'package:apolune/service/connect/runtime.dart';

/// macOS без подписи не может поднять Network Extension: система не выдаёт
/// ни профиль, ни групповой контейнер. Тогда ядро запускается внутри процесса
/// и слушает локальный SOCKS-порт — трафик идёт так же, как через туннель,
/// только вход не системный, а прокси-адрес.
///
/// Это не замена туннелю: приложения, которые не умеют SOCKS, мимо него пройдут.
class MacosProxySession {
  bool _running = false;
  int? _port;

  bool get enabled => AppPlatform.isMacOS;
  bool get running => _running;
  int? get port => _port;

  /// Готовит конфигурацию ядра: единственный вход — SOCKS на localhost.
  /// Остальное (выходы, маршрутизация, метрики) берётся из собранной
  /// конфигурации туннеля без изменений.
  static Map<String, dynamic> localConfig({
    required String xrayJson,
    required int socksPort,
  }) {
    final decoded = jsonDecode(xrayJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Xray configuration is not an object');
    }
    // Туннельный вход больше не нужен, остальные (локальные входы, метрики)
    // остаются на месте.
    final inbounds = [
      for (final inbound in (decoded['inbounds'] as List? ?? const []))
        if (!_isTunnelInbound(inbound)) inbound,
      {
        'tag': 'socks-in',
        'listen': '127.0.0.1',
        'port': socksPort,
        'protocol': 'socks',
        'settings': {'auth': 'noauth', 'udp': true},
      },
    ];
    return {...decoded, 'inbounds': inbounds};
  }

  static bool _isTunnelInbound(Object? inbound) {
    if (inbound is! Map) return false;
    if (inbound['protocol'] != 'dokodemo-door') return false;
    return '${inbound['tag'] ?? ''}'.toLowerCase().contains('tun');
  }

  static Future<int> freePort() async {
    final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = socket.port;
    await socket.close();
    return port;
  }

  Future<NativeVpnCommandResult> start(ConnectionRuntime runtime) async {
    var socksPort = int.tryParse(runtime.request.socksPort ?? '');
    if (socksPort == null || socksPort <= 0) {
      // На macOS порт для SOCKS не выделяется, потому что им владеет туннель.
      socksPort = await freePort();
      runtime.request.socksPort = '$socksPort';
    }
    final config = localConfig(xrayJson: runtime.xrayJson, socksPort: socksPort);
    final response = await invokeLibXray(
      jsonEncode({
        'apiVersion': 3,
        'method': 'runXray',
        'payload': {'xrayJson': jsonEncode(config)},
      }),
    );
    final decoded = jsonDecode(response);
    if (decoded is! Map || decoded['success'] != true) {
      final error = decoded is Map ? decoded['error'] : null;
      throw FormatException(
        error is String && error.isNotEmpty ? error : 'Core failed to start',
      );
    }
    _running = true;
    _port = socksPort;
    return NativeVpnCommandResult(
      state: NativeVpnCommandState.success,
      status: VpnStatus.connected,
    );
  }

  Future<NativeVpnCommandResult> stop() async {
    if (_running) {
      final response = await invokeLibXray(
        jsonEncode({'apiVersion': 3, 'method': 'stopXray', 'payload': {}}),
      );
      final decoded = jsonDecode(response);
      if (decoded is! Map || decoded['success'] != true) {
        final error = decoded is Map ? decoded['error'] : null;
        throw FormatException(
          error is String && error.isNotEmpty ? error : 'Core failed to stop',
        );
      }
    }
    _running = false;
    _port = null;
    return NativeVpnCommandResult(
      state: NativeVpnCommandState.success,
      status: VpnStatus.disconnected,
    );
  }

  /// Локальный SOCKS живёт, пока живёт процесс: после падения приложения
  /// туннель не остаётся поднятым.
  Future<VpnStatus> status() async =>
      _running ? VpnStatus.connected : VpnStatus.disconnected;
}
