import 'package:apolune/service/shared/failure.dart';
import 'package:apolune/core/pigeon/host_api.dart';
import 'package:apolune/gen/assets.gen.dart';
import 'package:apolune/l10n/localizations/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:apolune/pages/shared/page_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:apolune/pages/shared/alert.dart';

enum AppIcon {
  light("IconBlue"),
  dark("IconBlack"),
  green("IconGreen"),
  red("IconRed");

  const AppIcon(this.name);

  final String name;

  @override
  String toString() => name;

  static AppIcon? fromString(String name) {
    for (final value in AppIcon.values) {
      if (value.name == name) return value;
    }
    return null;
  }

  static List<String> get names {
    return AppIcon.values.map((e) => e.name).toList();
  }

  AssetGenImage get assetImage {
    switch (this) {
      case AppIcon.light:
        return Assets.appIcon.light;
      case AppIcon.dark:
        return Assets.appIcon.dark;
      case AppIcon.green:
        return Assets.appIcon.green;
      case AppIcon.red:
        return Assets.appIcon.red;
    }
  }

  AssetGenImage get dockAssetImage {
    switch (this) {
      case AppIcon.light:
        return Assets.macosIcon.light;
      case AppIcon.dark:
        return Assets.macosIcon.dark;
      case AppIcon.green:
        return Assets.macosIcon.green;
      case AppIcon.red:
        return Assets.macosIcon.red;
    }
  }
}

class AppIconPageState {
  final AppIcon appIcon;
  final bool loading;
  final bool saving;

  const AppIconPageState({
    this.appIcon = AppIcon.light,
    this.loading = true,
    this.saving = false,
  });

  AppIconPageState copyWith({AppIcon? appIcon, bool? loading, bool? saving}) {
    return AppIconPageState(
      appIcon: appIcon ?? this.appIcon,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
    );
  }
}

class AppIconController extends PageCubit<AppIconPageState> {
  AppIconController() : super(const AppIconPageState()) {
    _readCurrentIcon();
  }

  Future<void> _readCurrentIcon() async {
    try {
      final currentIcon = await AppHostApi().getCurrentAppIcon();
      emit(
        state.copyWith(
          appIcon: AppIcon.fromString(currentIcon) ?? AppIcon.light,
        ),
      );
    } catch (error) {
      // Keep the default preview if the optional native icon query fails.
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  void updateIcon(AppIcon value) {
    if (state.loading || state.saving) return;
    emit(state.copyWith(appIcon: value));
  }

  Future<void> save(BuildContext context) async {
    if (state.loading || state.saving) return;
    emit(state.copyWith(saving: true));
    var name = state.appIcon.name;
    if (state.appIcon == AppIcon.light) {
      name = "";
    }
    try {
      if (!await AppHostApi().setAppIcon(name)) {
        throw StateError('Icon update failed');
      }
      if (context.mounted) {
        ContextAlert.showToast(
          context,
          AppLocalizations.of(context)!.prototypeSettingsSaved,
        );
        if (ModalRoute.of(context)?.isCurrent == true) context.pop();
      }
    } catch (error) {
      if (context.mounted) {
        ContextAlert.showToast(
          context,
          appFailureMessage(
            AppLocalizations.of(context)!,
            error,
            operation: AppLocalizations.of(context)!.appIconPageSetFailed,
          ),
        );
      }
    } finally {
      emit(state.copyWith(saving: false));
    }
  }

  void cancel(BuildContext context) {
    context.pop();
  }
}
