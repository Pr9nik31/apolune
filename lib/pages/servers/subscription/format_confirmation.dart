import 'package:material_ui/material_ui.dart';
import 'package:apolune/l10n/localizations/app_localizations.dart';
import 'package:apolune/pages/shared/alert.dart';

Future<bool> confirmOrdinarySubscription(
  BuildContext context,
  String name,
) async {
  if (!context.mounted ||
      !TickerMode.valuesOf(context).enabled ||
      !(ModalRoute.of(context)?.isCurrent ?? true)) {
    return false;
  }
  final l = AppLocalizations.of(context)!;
  final confirmed = await ContextAlert.showConfirmDialog(
    context,
    title: l.subscriptionRemnawaveFormatTitle,
    content: l.subscriptionConvertToOrdinaryMessage(name),
    confirmLabel: l.subscriptionConvertToOrdinary,
  );
  return confirmed && context.mounted;
}
