import 'package:material_ui/material_ui.dart';
import 'package:apolune/pages/shared/widgets/elastic_scroll_physics.dart';
import 'package:apolune/core/db/database/database.dart';
import 'package:apolune/core/tools/traffic_format.dart';
import 'package:apolune/l10n/localizations/app_localizations.dart';
import 'package:apolune/pages/theme/font.dart';
import 'package:apolune/pages/theme/color.dart';
import 'package:apolune/pages/theme/layout.dart';
import 'package:apolune/pages/theme/theme.dart';
import 'package:apolune/pages/shared/widgets/responsive_content.dart';
import 'package:apolune/pages/shared/widgets/page_empty_state.dart';
import 'package:apolune/pages/shared/widgets/button_progress.dart';
import 'package:apolune/pages/connect/runtime_observatory.dart';
import 'package:apolune/service/connect/coordinator.dart';
import 'package:apolune/service/connect/failure.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ConnectView extends StatelessWidget {
  const ConnectView({
    super.key,
    required this.view,
    this.trafficBuilder,
    required this.hasServers,
    required this.expert,
    required this.raws,
    required this.activeRawId,
    this.pendingChange,
    this.deletingRawIds = const {},
    required this.location,
    this.runningPath,
    this.locationDetail,
    this.locationHealth,
    required this.method,
    this.methodDetail,
    this.methodEnabled = true,
    required this.onConnection,
    required this.onAddServers,
    required this.onExpert,
    required this.onServer,
    required this.onMethod,
    required this.onRawAdd,
    required this.onRawSelect,
    required this.onRawActions,
  });
  final ConnectionView view;
  final Widget Function(bool desktop)? trafficBuilder;
  final bool hasServers;
  final bool expert;
  final List<CoreConfigData> raws;
  final int? activeRawId;
  final String? pendingChange;
  final Set<int> deletingRawIds;
  final String location;
  final String? runningPath;
  final String? locationDetail, locationHealth, methodDetail;
  final String method;
  final bool methodEnabled;
  final VoidCallback onConnection,
      onAddServers,
      onServer,
      onMethod,
      onRawAdd;
  final ValueChanged<bool> onExpert;
  final ValueChanged<CoreConfigData> onRawSelect, onRawActions;

  bool get _connectionPending => pendingChange == 'connection';
  bool get _busy => view.busy || _connectionPending;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final empty =
        !hasServers &&
        !expert &&
        activeRawId == null &&
        !view.canDisconnect &&
        !_busy;
    if (empty) {
      return ResponsiveContent(
        child: PageEmptyState(
          title: l.prototypeStartUsingApolune,
          description: l.prototypeFirstConnectionHint,
          primaryLabel: l.prototypeAddServers,
          onPrimary: onAddServers,
          secondaryLabel: l.prototypeUseCompleteRawJson,
          onSecondary: () => onExpert(true),
        ),
      );
    }
    if (AppLayout.isWideSize(MediaQuery.sizeOf(context))) {
      return _desktop(context);
    }
    // На невысоких экранах отступы ужимаются: блок трафика должен быть
    // достижим без долгой прокрутки.
    final topInset = AppSpacing.connectPageTop * 0.55;
    final bottomInset = AppSpacing.connectPageBottom * 0.6;
    // Без резинового отскока: на iOS страница «улетала» вниз от одного движения.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const ElasticScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.connectPageHorizontal,
          topInset,
          AppSpacing.connectPageHorizontal,
          bottomInset,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                (constraints.maxHeight -
                        AppSpacing.connectPageTop -
                        AppSpacing.connectPageBottom)
                    .clamp(0, double.infinity),
          ),
          child: ResponsiveContent(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final main = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _status(context),
                    const SizedBox(height: 14),
                    if (expert)
                      Card(
                        margin: EdgeInsets.zero,
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: _raws(context),
                        ),
                      )

                  ],
                );
                final traffic = Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(13, 15, 13, 1),
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 29),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  l.prototypeTraffic,
                                  style: AppTypography.connectTrafficTitle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        trafficBuilder?.call(false) ??
                            TrafficReadout(view: view),
                      ],
                    ),
                  ),
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                main,
                const SizedBox(height: 10),
                traffic,
              ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _desktop(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = ColorManager.palette(context);
    final viewport = MediaQuery.sizeOf(context);
    final compact = viewport.width <= AppLayout.compactDesktopBreakpoint;
    final panelHeight =
        (viewport.height - AppLayout.connectDesktopPanelViewportInset).clamp(
          320.0,
          900.0,
        );
    final main = Card(
      key: const ValueKey('desktop-connection-panel'),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _status(context, desktop: true),
          if (expert)
            _raws(context, desktop: true)

        ],
      ),
    );
    final traffic = Card(
      key: const ValueKey('desktop-traffic-panel'),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 27, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: palette.border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      l.prototypeTraffic,
                      style: AppTypography.connectDesktopTrafficTitle,
                    ),
                  ),
                ],
              ),
            ),
            trafficBuilder?.call(true) ??
                TrafficReadout(view: view, desktop: true),
          ],
        ),
      ),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.desktopPageTop,
        AppSpacing.page,
        AppSpacing.desktopPageBottom,
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Без жёстких минимумов: на планшете они выталкивали трафик
                // за пределы экрана.
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: panelHeight * 0.62),
                  child: main,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 280),
                  child: traffic,
                ),
              ],
            )
          : ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    (viewport.height -
                            AppLayout.connectDesktopPanelViewportInset)
                        .clamp(0.0, double.infinity),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 104, child: main),
                    const SizedBox(width: 16),
                    Expanded(flex: 100, child: traffic),
                  ],
                ),
              ),
            ),
    );
  }



  Widget _status(BuildContext context, {bool desktop = false}) {
    final l = AppLocalizations.of(context)!;
    final connected = view.phase == ConnectionPhase.connected;
    final canDisconnect = view.canDisconnect;
    final failed = view.failed && !connected;
    final presentationPhase = failed ? ConnectionPhase.failed : view.phase;
    final title = switch (presentationPhase) {
      ConnectionPhase.disconnected => l.prototypeDisconnected,
      ConnectionPhase.preparing ||
      ConnectionPhase.connecting => l.prototypeConnecting,
      ConnectionPhase.connected => l.prototypeConnected,
      ConnectionPhase.disconnecting => l.prototypeDisconnecting,
      ConnectionPhase.failed => l.prototypeConnectionFailed,
    };
    final startedAt = view.runtime?.startedAt.millisecondsSinceEpoch;
    final elapsed = startedAt == null
        ? 0
        : DateTime.now()
              .difference(DateTime.fromMillisecondsSinceEpoch(startedAt))
              .inMinutes;
    final detail = switch (presentationPhase) {
      ConnectionPhase.disconnected => l.prototypeReadyToProtectConnection,
      ConnectionPhase.preparing ||
      ConnectionPhase.connecting => l.prototypePreparingSecureConnection,
      ConnectionPhase.connected =>
        elapsed < 1
            ? l.prototypeJustConnected
            : elapsed < 60
            ? l.prototypeProtectedMinutes(elapsed)
            : l.prototypeProtectedHoursMinutes(elapsed ~/ 60, elapsed % 60),
      ConnectionPhase.disconnecting => l.prototypeFinishingConnection,
      ConnectionPhase.failed => connectionFailureMessage(
        l,
        issue: view.issue,
        error: view.error,
        permission: view.permission,
      ),
    };
    final palette = ColorManager.palette(context);
    final color = failed
        ? palette.destructive
        : connected
        ? palette.running
        : _busy
        ? palette.primary
        : palette.mutedStrong;
    final waitingForPhase = _connectionPending && !view.busy;
    final button = FilledButton(
      onPressed:
          view.phase == ConnectionPhase.disconnecting ||
              (pendingChange != null && !view.busy)
          ? null
          : onConnection,
      style: desktop
          ? AppTheme.connectionButton(
              context,
              destructive: canDisconnect,
            ).copyWith(
              minimumSize: const WidgetStatePropertyAll(
                Size(
                  AppLayout.connectDesktopButtonWidth,
                  AppLayout.connectDesktopButtonMinHeight,
                ),
              ),
              textStyle: WidgetStatePropertyAll(
                AppTypography.connectDesktopAction,
              ),
            )
          : AppTheme.connectionButton(context, destructive: canDisconnect),
      child: ButtonProgress(
        busy: desktop && _busy,
        child: Text(
          waitingForPhase
              ? l.prototypePleaseWait
              : canDisconnect
              ? l.prototypeDisconnect
              : view.phase == ConnectionPhase.disconnecting
              ? l.prototypePleaseWait
              : view.busy
              ? l.prototypeCancel
              : failed
              ? l.prototypeTryAgain
              : l.prototypeConnect,
        ),
      ),
    );
    final content = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: desktop
            ? AppLayout.connectDesktopStatusMinHeight
            : AppLayout.connectStatusMinHeight,
      ),
      child: Padding(
        padding: desktop
            ? const EdgeInsets.fromLTRB(20, 66, 20, 39)
            : const EdgeInsets.fromLTRB(15, 25, 15, 17),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_busy)
                  SizedBox.square(
                    dimension: desktop ? 29 : 24,
                    child: MediaQuery.disableAnimationsOf(context)
                        ? Icon(
                            LucideIcons.loaderCircle,
                            color: color,
                            size: desktop ? 29 : 24,
                          )
                        : CircularProgressIndicator(
                            strokeWidth: 2,
                            color: color,
                          ),
                  )
                else if (connected)
                  Container(
                    width: desktop ? 29 : 24,
                    height: desktop ? 29 : 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.check,
                      size: desktop ? 19 : 14,
                      color: palette.primaryForeground,
                    ),
                  )
                else
                  Icon(
                    failed ? LucideIcons.circleAlert : LucideIcons.shield,
                    color: color,
                    size: desktop ? 29 : 24,
                  ),
                SizedBox(width: desktop ? 12 : 10),
                Flexible(
                  child: Text(
                    title,
                    style:
                        (desktop
                                ? AppTypography.connectDesktopStatusTitle
                                : AppTypography.connectStatusTitle)
                            .copyWith(color: color),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: desktop ? 16 : 8),
            Text(
              detail,
              textAlign: TextAlign.center,
              style:
                  (desktop
                          ? AppTypography.connectDesktopStatusDetail
                          : AppTypography.connectStatusDetail)
                      .copyWith(color: palette.mutedStrong),
            ),
            if (location.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: desktop ? 10 : 6),
                child: Text(
                  location,
                  textAlign: TextAlign.center,
                  style: AppTypography.metadata.copyWith(
                    color: palette.mutedForeground,
                  ),
                ),
              ),
            if (view.issue == 'selectionReset')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l.prototypeNameActive(l.prototypeAutomaticSelection),
                    textAlign: TextAlign.center,
                    style: AppTypography.metadata,
                  ),
                ),
              ),
            if (view.failed && !failed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l.prototypeCheckNetwork,
                  style: AppTypography.supporting.copyWith(
                    color: palette.destructive,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: desktop ? 30 : 18),
            if (desktop)
              Align(
                child: SizedBox(
                  width: AppLayout.connectDesktopButtonWidth,
                  child: button,
                ),
              )
            else
              button,
          ],
        ),
      ),
    );
    if (!desktop) return Card(margin: EdgeInsets.zero, child: content);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: content,
    );
  }


  Widget _raws(BuildContext context, {bool desktop = false}) {
    final l = AppLocalizations.of(context)!;
    final palette = ColorManager.palette(context);
    return Padding(
      padding: desktop
          ? const EdgeInsets.fromLTRB(18, 0, 18, 14)
          : const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: desktop ? 52 : 47),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Raw JSON',
                    style: desktop
                        ? AppTypography.connectDesktopRawTitle
                        : AppTypography.connectRawTitle,
                  ),
                ),
                Text(
                  '${raws.length} / 3',
                  textDirection: TextDirection.ltr,
                  style: AppTypography.connectRawCount.copyWith(
                    color: palette.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          if (view.phase == ConnectionPhase.connected && activeRawId == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                l.prototypeOrdinaryConnectionRunning,
                style: AppTypography.supporting.copyWith(
                  color: palette.mutedForeground,
                ),
              ),
            ),
          if (raws.isEmpty)
            Card(
              margin: EdgeInsets.zero,
              shape: AppDashedBorder(
                side: BorderSide(color: palette.borderStrong),
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: desktop
                      ? AppLayout.connectDesktopRawEmptyMinHeight
                      : 160,
                ),
                child: Padding(
                  padding: EdgeInsets.all(desktop ? 24 : 19),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: desktop
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: [
                      Icon(
                        LucideIcons.filePlus,
                        size: desktop ? 32 : 27,
                        color: palette.mutedStrong,
                      ),
                      const SizedBox(height: 11),
                      Text(
                        l.prototypeNoRawJson,
                        textAlign: TextAlign.center,
                        style: desktop
                            ? AppTypography.connectDesktopRawEmptyTitle
                            : AppTypography.connectRawEmptyTitle,
                      ),
                      const SizedBox(height: 9),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: desktop ? 330 : 270,
                        ),
                        child: Text(
                          l.prototypeAddRawJsonHint,
                          textAlign: TextAlign.center,
                          style:
                              (desktop
                                      ? AppTypography
                                            .connectDesktopRawEmptyDetail
                                      : AppTypography.connectRawEmptyDetail)
                                  .copyWith(color: palette.mutedForeground),
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: onRawAdd,
                        icon: const Icon(LucideIcons.plus, size: 17),
                        label: Text(l.prototypeAddRawJson),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (raws.isNotEmpty)
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final row in raws) ...[
                    if (row != raws.first) const Divider(),
                    _rawRow(context, row, desktop: desktop),
                  ],
                ],
              ),
            ),
          if (raws.isNotEmpty && raws.length < 3)
            Padding(
              padding: const EdgeInsets.only(top: 11),
              child: OutlinedButton.icon(
                onPressed: onRawAdd,
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.primary,
                  shape: AppDashedBorder(
                    borderRadius: BorderRadius.circular(AppRadii.control),
                  ),
                ),
                icon: const Icon(LucideIcons.plus, size: 17),
                label: Text(l.prototypeAddRawJson),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.info, size: 16, color: palette.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.prototypeRawRuntimeOverrideNotice,
                  style: AppTypography.connectRawNotice.copyWith(
                    color: palette.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rawRow(
    BuildContext context,
    CoreConfigData row, {
    bool desktop = false,
  }) {
    final l = AppLocalizations.of(context)!;
    final palette = ColorManager.palette(context);
    final active = activeRawId == row.id;
    return ColoredBox(
      color: active
          ? Color.lerp(palette.card, palette.selectedSurface, .6)!
          : palette.card,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: desktop ? 66 : 62),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap:
                    _busy ||
                        pendingChange != null ||
                        deletingRawIds.contains(row.id)
                    ? null
                    : () => onRawSelect(row),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: desktop ? 13 : 11,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      if (pendingChange == 'raw:${row.id}')
                        const ButtonProgressIndicator()
                      else
                        Icon(
                          LucideIcons.fileJson,
                          size: 21,
                          color: palette.primary,
                        ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.connectRawRowTitle,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              active
                                  ? l.prototypeActiveConfiguration
                                  : l.prototypeCompleteXrayConfiguration,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.connectRawRowDetail.copyWith(
                                color: palette.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 11),
                      Icon(
                        active ? LucideIcons.check : LucideIcons.circle,
                        size: active ? 19 : 18,
                        color: active
                            ? palette.primary
                            : palette.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: desktop ? 46 : 42,
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    border: BorderDirectional(
                      start: BorderSide(color: palette.border),
                    ),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: '${l.prototypeMoreActions}: ${row.name}',
                    onPressed: deletingRawIds.contains(row.id)
                        ? null
                        : () => onRawActions(row),
                    icon: deletingRawIds.contains(row.id)
                        ? const ButtonProgressIndicator()
                        : const Icon(LucideIcons.ellipsis, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrafficReadout extends StatelessWidget {
  const TrafficReadout({super.key, required this.view, this.desktop = false});
  final ConnectionView view;
  final bool desktop;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final live =
        view.phase == ConnectionPhase.connected && view.metricsAvailable;
    final traffic = view.traffic;
    return Column(
      children: [
        _group(
          context,
          l.prototypeCurrentSpeed,
          live
              ? '${formatTraffic(view.downloadSpeed, connection: true)}/s'
              : '—',
          live ? '${formatTraffic(view.uploadSpeed, connection: true)}/s' : '—',
        ),
        _group(
          context,
          l.prototypeThisConnection,
          formatTraffic(traffic?.downlink ?? 0, connection: true),
          formatTraffic(traffic?.uplink ?? 0, connection: true),
          divider: false,
        ),
        RuntimeObservatoryReadout(view: view, desktop: desktop),
      ],
    );
  }

  Widget _group(
    BuildContext context,
    String title,
    String download,
    String upload, {
    bool divider = true,
  }) {
    final l = AppLocalizations.of(context)!;
    final palette = ColorManager.palette(context);
    return Container(
      constraints: BoxConstraints(
        minHeight: desktop
            ? AppLayout.connectDesktopTrafficGroupMinHeight
            : AppLayout.connectTrafficGroupMinHeight,
      ),
      padding: EdgeInsets.symmetric(vertical: desktop ? 22 : 10.5),
      decoration: BoxDecoration(
        border: divider
            ? Border(bottom: BorderSide(color: palette.border))
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style:
                (desktop
                        ? AppTypography.connectDesktopTrafficGroupTitle
                        : AppTypography.connectTrafficGroupTitle)
                    .copyWith(color: palette.mutedStrong),
          ),
          SizedBox(height: desktop ? 24 : 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _metric(
                    context,
                    LucideIcons.arrowDown,
                    l.prototypeDownload,
                    download,
                    palette.primary,
                  ),
                ),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: BorderDirectional(
                        start: BorderSide(color: palette.border),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 1),
                      child: _metric(
                        context,
                        LucideIcons.arrowUp,
                        l.prototypeUpload,
                        upload,
                        palette.running,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) => Semantics(
    label: '$label $value',
    excludeSemantics: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.controlHorizontal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: desktop ? 24 : 19, color: color),
              const SizedBox(width: AppSpacing.actionRunGap),
              Expanded(
                child: Text(
                  label,
                  style:
                      (desktop
                              ? AppTypography.connectDesktopTrafficLabel
                              : AppTypography.connectTrafficLabel)
                          .copyWith(
                            color: ColorManager.palette(context).mutedStrong,
                          ),
                ),
              ),
            ],
          ),
          SizedBox(height: desktop ? 10 : 5),
          Text(
            value,
            textDirection: TextDirection.ltr,
            style: desktop
                ? AppTypography.metric
                : AppTypography.connectTrafficValue,
          ),
        ],
      ),
    ),
  );
}
