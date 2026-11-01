import 'package:material_ui/material_ui.dart';
import 'package:apolune/core/pigeon/flutter_api.dart';
import 'package:apolune/core/pigeon/host_api.dart';
import 'package:apolune/core/pigeon/messages.g.dart';
import 'package:apolune/core/tools/platform.dart';
import 'package:apolune/pages/main/router.dart';
import 'package:apolune/pages/shared/widgets/apolune_brand.dart';
import 'package:apolune/service/launch/app_startup.dart';
import 'package:apolune/service/shared/menu/short_cut/service.dart';
import 'package:apolune/service/shared/menu/settings/service.dart';
import 'package:apolune/service/shared/menu/window/service.dart';
import 'package:apolune/service/shared/share/service.dart';
import 'package:apolune/service/shared/apple_widget/service.dart';

const _desktopWindowSize = Size(1160, 720);
const _minimumDesktopWindowSize = Size(480, 600);

Future<void> main(List<String> _) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Первый кадр рисуем сразу: системная заставка сменяется знаком, пока
  // сервисы инициализируются. Иначе экран остаётся пустым всё время запуска.
  runApp(const _BootSplash());

  await ShortCutService().initialize();
  ShareService().startAppLinks();
  await _initBridge();
  await AppleWidgetService().initialize();
  final appStartup = AppStartupService();
  await appStartup.prepare();

  if (AppPlatform.isDesktop) {
    await WindowService().prepare(
      size: _desktopWindowSize,
      minimumSize: _minimumDesktopWindowSize,
    );
  }

  MacOSSettingsMenuService().initialize();
  runApp(GoRouteApp());
  // Hidden windows may not render frames. Keep visibility independent from
  // first-frame callbacks and preserve the existing hidden-start policy.
  await appStartup.onWindowReady();
}

/// Заставка первого кадра: только знак на бумаге, без зависимостей от темы.
class _BootSplash extends StatelessWidget {
  const _BootSplash();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0xFFEDE8DC),
    child: Center(child: ApoluneMark(size: 150, color: Color(0xFF16150F))),
  );
}

Future<void> _initBridge() async {
  BridgeFlutterApi.setUp(AppFlutterApi());
  await AppHostApi().initTunFilesDir();
}
