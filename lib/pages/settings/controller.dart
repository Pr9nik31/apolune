import 'package:apolune/service/shared/failure.dart';
import 'package:material_ui/material_ui.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:apolune/core/constants/preferences.dart';
import 'package:apolune/core/pigeon/host_api.dart';
import 'package:apolune/core/tools/platform.dart';
import 'package:apolune/l10n/localizations/app_localizations.dart';
import 'package:apolune/pages/main/navigation.dart';
import 'package:apolune/pages/shared/alert.dart';
import 'package:apolune/pages/shared/connection_action.dart';
import 'package:apolune/service/connect/coordinator.dart';
import 'package:apolune/pages/shared/page_cubit.dart';
import 'package:apolune/pages/settings/app_icon/controller.dart';
import 'package:apolune/pages/shared/widgets/settings_page.dart';
import 'package:apolune/service/settings/app_update/service.dart';
import 'package:apolune/service/settings/data_cleanup.dart';
import 'package:apolune/service/settings/traffic_widget.dart';
import 'package:apolune/service/launch/app_startup.dart';
import 'package:apolune/service/shared/doc/helper.dart';
import 'package:apolune/service/shared/event_bus/enum.dart';
import 'package:apolune/service/shared/event_bus/service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPageState {
  final String appVersion;
  final String xrayVersion;
  final AppIcon appIcon;
  final bool connectOnLaunch;
  final bool expert;
  final bool loading;
  final bool saving;
  final bool checkingUpdate;
  final bool clearingData;
  final bool addingWidget;
  final Object? failure;
  const SettingsPageState({
    this.appVersion = '—',
    this.xrayVersion = '—',
    this.appIcon = AppIcon.light,
    this.connectOnLaunch = false,
    this.expert = false,
    this.loading = true,
    this.saving = false,
    this.checkingUpdate = false,
    this.clearingData = false,
    this.addingWidget = false,
    this.failure,
  });

  SettingsPageState copyWith({
    String? appVersion,
    String? xrayVersion,
    AppIcon? appIcon,
    bool? connectOnLaunch,
    bool? expert,
    bool? loading,
    bool? saving,
    bool? checkingUpdate,
    bool? clearingData,
    bool? addingWidget,
    Object? failure,
    bool clearFailure = false,
  }) => SettingsPageState(
    appVersion: appVersion ?? this.appVersion,
    xrayVersion: xrayVersion ?? this.xrayVersion,
    appIcon: appIcon ?? this.appIcon,
    connectOnLaunch: connectOnLaunch ?? this.connectOnLaunch,
    expert: expert ?? this.expert,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    checkingUpdate: checkingUpdate ?? this.checkingUpdate,
    clearingData: clearingData ?? this.clearingData,
    addingWidget: addingWidget ?? this.addingWidget,
    failure: clearFailure ? null : failure ?? this.failure,
  );
}

enum SettingsLink {
  documentation,
  review,
  community,
  feedback,
  source,
  credits,
  privacy,
}

class SettingsController extends PageCubit<SettingsPageState> {
  SettingsController() : super(const SettingsPageState()) {
    _readVersions();
    _readPreferences();
  }

  bool get showAppIcon => AppPlatform.isIOS || AppPlatform.isMacOS;

  Future<void> addTrafficWidget(BuildContext context) async {
    if (state.addingWidget) return;
    emit(state.copyWith(addingWidget: true));
    try {
      final requested = await TrafficWidgetService().requestPin();
      if (!requested && context.mounted) {
        ContextAlert.showToast(
          context,
          AppLocalizations.of(context)!.trafficWidgetManualHint,
        );
      }
    } catch (error) {
      if (context.mounted) _showUnavailable(context, error);
    } finally {
      emit(state.copyWith(addingWidget: false));
    }
  }

  Future<void> _readVersions() async {
    var appVersion = '—';
    var xrayVersion = '—';
    try {
      appVersion = (await PackageInfo.fromPlatform()).version;
    } catch (error) {
      // Optional display facts remain unavailable instead of using demo values.
    }
    try {
      final version = await AppHostApi().xrayVersion();
      if (version.isNotEmpty) xrayVersion = version;
    } catch (error) {
      // App metadata can still be shown when the native version call fails.
    }
    emit(state.copyWith(appVersion: appVersion, xrayVersion: xrayVersion));
  }

  Future<void> _readPreferences() async {
    try {
      final connect = await PreferencesKey().readConnectOnAppLaunch();
      final connection = await ConnectionCoordinator.instance.configuration;
      final icon = showAppIcon
          ? AppIcon.fromString(await AppHostApi().getCurrentAppIcon())
          : null;
      emit(
        state.copyWith(
          connectOnLaunch: connect,
          expert: connection.connection.expert,
          appIcon: icon ?? AppIcon.light,
          loading: false,
        ),
      );
    } catch (error) {
      emit(state.copyWith(loading: false, failure: error));
    }
  }

  /// «Режим уверенного пользователя»: включает экспертные поля на экране
  /// подключения. Хранится в той же конфигурации, что читает этот экран.
  Future<void> setExpert(BuildContext context, bool value) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true));
    try {
      await applyConnectionChange(
        context,
        ConnectionCoordinator.instance,
        {'expert': value},
        label: (_) => AppLocalizations.of(context)!.prototypeExpertMode,
      );
      emit(state.copyWith(expert: value, saving: false));
    } catch (error) {
      if (context.mounted) _showUnavailable(context, error);
      emit(state.copyWith(saving: false));
    }
  }

  Future<void> openSetting(
    BuildContext context,
    AppPageDestination destination,
  ) async {
    await context.pushScoped(destination);
    if (isPageActive && destination == AppPageDestination.appIcon) {
      await _readPreferences();
    }
  }

  Future<void> setConnectOnLaunch(BuildContext context, bool value) async {
    if (state.saving || state.loading) return;
    emit(state.copyWith(saving: true, clearFailure: true));
    try {
      await PreferencesKey().saveConnectOnAppLaunch(value);
      emit(state.copyWith(connectOnLaunch: value));
    } catch (error) {
      if (context.mounted) _showUnavailable(context, error);
    } finally {
      emit(state.copyWith(saving: false));
    }
  }

  Future<void> checkUpdate(BuildContext context) async {
    if (state.checkingUpdate) return;
    emit(state.copyWith(checkingUpdate: true));
    try {
      final result = await AppUpdateService().checkForUpdate();
      if (!context.mounted) return;
      switch (result.status) {
        case AppUpdateCheckStatus.available:
          final update = result.updateInfo!;
          AppEventBus.instance.updateAppUpdateInfo(update);
          await context.pushAppUpdateDialog(update);
        case AppUpdateCheckStatus.upToDate:
          AppEventBus.instance.updateAppUpdateInfo(null);
          ContextAlert.showToast(
            context,
            AppLocalizations.of(context)!.appUpdateAlreadyLatest,
          );
        case AppUpdateCheckStatus.failed:
          ContextAlert.showToast(
            context,
            appFailureMessage(
              AppLocalizations.of(context)!,
              result.error,
              operation: AppLocalizations.of(context)!.appUpdateCheckFailed,
            ),
          );
      }
    } catch (error) {
      if (context.mounted) {
        ContextAlert.showToast(
          context,
          appFailureMessage(
            AppLocalizations.of(context)!,
            error,
            operation: AppLocalizations.of(context)!.appUpdateCheckFailed,
          ),
        );
      }
    } finally {
      emit(state.copyWith(checkingUpdate: false));
    }
  }

  Future<void> clearData(BuildContext context) async {
    if (state.clearingData) return;
    final l10n = AppLocalizations.of(context)!;
    emit(state.copyWith(clearingData: true, clearFailure: true));
    try {
      if (!await AppConfirmationDialog(
            title: l10n.prototypeClearAllDataQuestion,
            content: l10n.prototypeClearAllDataWarning,
            cancelLabel: l10n.prototypeCancel,
            confirmLabel: l10n.prototypeConfirmClearData,
            destructive: true,
            barrierDismissible: false,
          ).show(context) ||
          !context.mounted) {
        return;
      }
      if (await AppDataCleanupService().clearFromSettings()) {
        AppStartupService().suppressConnectOnAppLaunch();
        emit(state.copyWith(connectOnLaunch: false));
      } else if (context.mounted) {
        _showUnavailable(context);
      }
    } catch (error) {
      if (context.mounted) _showUnavailable(context, error);
    } finally {
      emit(state.copyWith(clearingData: false));
    }
  }

  Future<void> setTheme(BuildContext context, ThemeCode theme) async {
    emit(state.copyWith(clearFailure: true));
    try {
      await AppEventBus.instance.updateThemeCode(theme);
    } catch (error) {
      if (context.mounted) _showUnavailable(context, error);
    }
  }

  Future<void> openLink(BuildContext context, SettingsLink link) async {
    emit(state.copyWith(clearFailure: true));
    final uri = switch (link) {
      SettingsLink.documentation => DocURLHelper.docUri(),
      SettingsLink.review => null,
      SettingsLink.community => Uri.parse('https://t.me/Pr9nik31'),
      SettingsLink.feedback => Uri.parse(
        'https://github.com/Pr9nik31/apolune/issues/new',
      ),
      SettingsLink.source => Uri.parse(
        'https://github.com/Pr9nik31/apolune',
      ),
      SettingsLink.credits => DocURLHelper.creditsUri(),
      SettingsLink.privacy => DocURLHelper.privacyUri(),
    };
    try {
      if (uri == null) {
        final review = InAppReview.instance;
        if (await review.isAvailable()) {
          await review.requestReview();
        } else if (context.mounted) {
          _showUnavailable(context);
        }
        return;
      }
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          _showUnavailable(context, 'No application could open this link.');
        }
      }
    } catch (error) {
      if (context.mounted) _showUnavailable(context, error);
    }
  }

  void _showUnavailable(BuildContext context, [Object? error]) {
    if (context.mounted) {
      emit(state.copyWith(failure: error));
      ContextAlert.showToast(
        context,
        appFailureMessage(AppLocalizations.of(context)!, error),
      );
    }
  }
}
