import 'package:material_ui/material_ui.dart';
import 'package:apolune/core/db/database/constants.dart';

@immutable
class AppPalette {
  // The confirmation overlay is shared by both prototype themes.
  static const restoreOverlay = Color.fromRGBO(5, 12, 30, 0.4);

  const AppPalette({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.primary,
    required this.primaryHover,
    required this.primaryText,
    required this.primarySolid,
    required this.primarySolidHover,
    required this.primaryForeground,
    required this.surfaceHover,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.mutedStrong,
    required this.accent,
    required this.accentForeground,
    required this.destructive,
    required this.destructiveSolid,
    required this.destructiveSolidHover,
    required this.destructiveForeground,
    required this.border,
    required this.borderStrong,
    required this.input,
    required this.ring,
    required this.selection,
    required this.scannerBackground,
    required this.overlay,
    required this.header,
    required this.brand,
    required this.sidebar,
    required this.sidebarForeground,
    required this.sidebarPrimary,
    required this.sidebarPrimaryForeground,
    required this.sidebarAccent,
    required this.sidebarAccentForeground,
    required this.sidebarBorder,
    required this.sidebarRing,
    required this.selectedSurface,
    required this.running,
    required this.runningText,
    required this.runningBadge,
    required this.runningBadgeForeground,
    required this.runningForeground,
    required this.runningSurface,
    required this.restarting,
    required this.restartingText,
    required this.warningSurface,
    required this.destructiveSurface,
    required this.chart1,
    required this.chart2,
    required this.chart3,
    required this.chart4,
    required this.chart5,
  });

  // Semantic mapping of references/apolune-app-prototype/src/theme/tokens.json.
  // Interactive colors and solid button fills differ in the dark theme.
  static const light = AppPalette(
    overlay: Color.fromRGBO(22, 21, 15, 0.48),
    background: Color(0xFFEDE8DC),
    foreground: Color(0xFF16150F),
    card: Color(0xFFF5F0E4),
    cardForeground: Color(0xFF16150F),
    popover: Color(0xFFF5F0E4),
    popoverForeground: Color(0xFF16150F),
    primary: Color(0xFFC0402B),
    primaryHover: Color(0xFFA63623),
    primaryText: Color(0xFFA63623),
    primarySolid: Color(0xFFC0402B),
    primarySolidHover: Color(0xFFA63623),
    primaryForeground: Color(0xFFF7F2E7),
    surfaceHover: Color(0xFFE7E0D0),
    secondary: Color(0xFFE3DCCB),
    secondaryForeground: Color(0xFF16150F),
    muted: Color(0xFFE3DCCB),
    mutedForeground: Color(0xFF6B6555),
    mutedStrong: Color(0xFF4A4538),
    accent: Color(0xFFF3E2D9),
    accentForeground: Color(0xFFA63623),
    destructive: Color(0xFFA63623),
    destructiveSolid: Color(0xFFC0402B),
    destructiveSolidHover: Color(0xFFA63623),
    destructiveForeground: Color(0xFFF7F2E7),
    border: Color(0xFFD3C9B4),
    borderStrong: Color(0xFFC2B79F),
    input: Color(0xFFD3C9B4),
    ring: Color(0xFFC0402B),
    selection: Color(0xFFF3E2D9),
    scannerBackground: Color(0xFF16211F),
    header: Color(0xFFEDE8DC),
    brand: Color(0xFF16150F),
    sidebar: Color(0xFF243F3C),
    sidebarForeground: Color(0xFFD9D2C2),
    sidebarPrimary: Color(0xFFC0402B),
    sidebarPrimaryForeground: Color(0xFFF7F2E7),
    sidebarAccent: Color(0xFF35544F),
    sidebarAccentForeground: Color(0xFFEDE8DC),
    sidebarBorder: Color(0xFF1B302E),
    sidebarRing: Color(0xFFC0402B),
    selectedSurface: Color(0xFFF3E2D9),
    running: Color(0xFF4F6B3A),
    runningText: Color(0xFF3F5730),
    runningBadge: Color(0xFF4F6B3A),
    runningBadgeForeground: Color(0xFFF7F2E7),
    runningForeground: Color(0xFF10140F),
    runningSurface: Color(0xFFE8EBDD),
    restarting: Color(0xFFB06A12),
    restartingText: Color(0xFF8A5310),
    warningSurface: Color(0xFFF2E4CF),
    destructiveSurface: Color(0xFFF3DAD3),
    chart1: Color(0xFF2C4A47),
    chart2: Color(0xFFC0402B),
    chart3: Color(0xFFC9A227),
    chart4: Color(0xFF5A5A33),
    chart5: Color(0xFFC9761F),
  );

  static const dark = AppPalette(
    overlay: Color.fromRGBO(0, 0, 0, 0.62),
    background: Color(0xFF12110E),
    foreground: Color(0xFFEDE8DC),
    card: Color(0xFF1A1813),
    cardForeground: Color(0xFFEDE8DC),
    popover: Color(0xFF1A1813),
    popoverForeground: Color(0xFFEDE8DC),
    primary: Color(0xFFD4503A),
    primaryHover: Color(0xFFE0634C),
    primaryText: Color(0xFFE0634C),
    primarySolid: Color(0xFFD4503A),
    primarySolidHover: Color(0xFFE0634C),
    primaryForeground: Color(0xFF14130F),
    surfaceHover: Color(0xFF232019),
    secondary: Color(0xFF1F1C16),
    secondaryForeground: Color(0xFFEDE8DC),
    muted: Color(0xFF232019),
    mutedForeground: Color(0xFFA9A292),
    mutedStrong: Color(0xFF8F887A),
    accent: Color(0xFF2A211C),
    accentForeground: Color(0xFFE0634C),
    destructive: Color(0xFFD4584A),
    destructiveSolid: Color(0xFFC0402B),
    destructiveSolidHover: Color(0xFFA63623),
    destructiveForeground: Color(0xFF14130F),
    border: Color(0xFF332F26),
    borderStrong: Color(0xFF443F33),
    input: Color(0xFF332F26),
    ring: Color(0xFFD4503A),
    selection: Color(0xFF2A211C),
    scannerBackground: Color(0xFF0B0A08),
    header: Color(0xFF12110E),
    brand: Color(0xFFEDE8DC),
    sidebar: Color(0xFF0E0D0A),
    sidebarForeground: Color(0xFFB7AF9F),
    sidebarPrimary: Color(0xFFD4503A),
    sidebarPrimaryForeground: Color(0xFF14130F),
    sidebarAccent: Color(0xFF1F1C16),
    sidebarAccentForeground: Color(0xFFEDE8DC),
    sidebarBorder: Color(0xFF262319),
    sidebarRing: Color(0xFFD4503A),
    selectedSurface: Color(0xFF2A211C),
    running: Color(0xFF6E8C4F),
    runningText: Color(0xFF8FAF6C),
    runningBadge: Color(0xFF6E8C4F),
    runningBadgeForeground: Color(0xFF10140F),
    runningForeground: Color(0xFF10140F),
    runningSurface: Color(0xFF1C2416),
    restarting: Color(0xFFD08A2E),
    restartingText: Color(0xFFE0A050),
    warningSurface: Color(0xFF2A2113),
    destructiveSurface: Color(0xFF2B1613),
    chart1: Color(0xFF6FA39C),
    chart2: Color(0xFFE0634C),
    chart3: Color(0xFFD9B44A),
    chart4: Color(0xFF8E8E5E),
    chart5: Color(0xFFE08A3C),
  );

  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color popover;
  final Color popoverForeground;
  final Color primary;
  final Color primaryHover;
  // Opaque small text on selectedSurface, independent of interaction state.
  final Color primaryText;
  final Color primarySolid;
  final Color primarySolidHover;
  // Foregrounds pair with solid fills, not the dark theme's interactive colors.
  final Color primaryForeground;
  final Color surfaceHover;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color mutedStrong;
  final Color accent;
  final Color accentForeground;
  final Color destructive;
  final Color destructiveSolid;
  final Color destructiveSolidHover;
  final Color destructiveForeground;
  final Color border;
  final Color borderStrong;
  final Color input;
  final Color ring;
  final Color selection;
  final Color scannerBackground;
  final Color overlay;
  final Color header;
  final Color sidebar;
  final Color brand;
  final Color sidebarForeground;
  final Color sidebarPrimary;
  final Color sidebarPrimaryForeground;
  final Color sidebarAccent;
  final Color sidebarAccentForeground;
  final Color sidebarBorder;
  final Color sidebarRing;
  final Color selectedSurface;
  final Color running;
  final Color runningText;
  final Color runningBadge;
  final Color runningBadgeForeground;
  final Color runningForeground;
  final Color runningSurface;
  final Color restarting;
  final Color restartingText;
  final Color warningSurface;
  final Color destructiveSurface;
  final Color chart1;
  final Color chart2;
  final Color chart3;
  final Color chart4;
  final Color chart5;

  static AppPalette lerp(AppPalette begin, AppPalette end, double t) {
    Color color(Color a, Color b) => Color.lerp(a, b, t) ?? b;

    return AppPalette(
      background: color(begin.background, end.background),
      foreground: color(begin.foreground, end.foreground),
      card: color(begin.card, end.card),
      cardForeground: color(begin.cardForeground, end.cardForeground),
      popover: color(begin.popover, end.popover),
      popoverForeground: color(begin.popoverForeground, end.popoverForeground),
      primary: color(begin.primary, end.primary),
      primaryHover: color(begin.primaryHover, end.primaryHover),
      primaryText: color(begin.primaryText, end.primaryText),
      primarySolid: color(begin.primarySolid, end.primarySolid),
      primarySolidHover: color(begin.primarySolidHover, end.primarySolidHover),
      primaryForeground: color(begin.primaryForeground, end.primaryForeground),
      surfaceHover: color(begin.surfaceHover, end.surfaceHover),
      secondary: color(begin.secondary, end.secondary),
      secondaryForeground: color(
        begin.secondaryForeground,
        end.secondaryForeground,
      ),
      muted: color(begin.muted, end.muted),
      mutedForeground: color(begin.mutedForeground, end.mutedForeground),
      mutedStrong: color(begin.mutedStrong, end.mutedStrong),
      accent: color(begin.accent, end.accent),
      accentForeground: color(begin.accentForeground, end.accentForeground),
      destructive: color(begin.destructive, end.destructive),
      destructiveSolid: color(begin.destructiveSolid, end.destructiveSolid),
      destructiveSolidHover: color(
        begin.destructiveSolidHover,
        end.destructiveSolidHover,
      ),
      destructiveForeground: color(
        begin.destructiveForeground,
        end.destructiveForeground,
      ),
      border: color(begin.border, end.border),
      borderStrong: color(begin.borderStrong, end.borderStrong),
      input: color(begin.input, end.input),
      ring: color(begin.ring, end.ring),
      selection: color(begin.selection, end.selection),
      scannerBackground: color(begin.scannerBackground, end.scannerBackground),
      overlay: color(begin.overlay, end.overlay),
      header: color(begin.header, end.header),
      sidebar: color(begin.sidebar, end.sidebar),
      brand: color(begin.brand, end.brand),
      sidebarForeground: color(begin.sidebarForeground, end.sidebarForeground),
      sidebarPrimary: color(begin.sidebarPrimary, end.sidebarPrimary),
      sidebarPrimaryForeground: color(
        begin.sidebarPrimaryForeground,
        end.sidebarPrimaryForeground,
      ),
      sidebarAccent: color(begin.sidebarAccent, end.sidebarAccent),
      sidebarAccentForeground: color(
        begin.sidebarAccentForeground,
        end.sidebarAccentForeground,
      ),
      sidebarBorder: color(begin.sidebarBorder, end.sidebarBorder),
      sidebarRing: color(begin.sidebarRing, end.sidebarRing),
      selectedSurface: color(begin.selectedSurface, end.selectedSurface),
      running: color(begin.running, end.running),
      runningText: color(begin.runningText, end.runningText),
      runningBadge: color(begin.runningBadge, end.runningBadge),
      runningBadgeForeground: color(
        begin.runningBadgeForeground,
        end.runningBadgeForeground,
      ),
      runningForeground: color(begin.runningForeground, end.runningForeground),
      runningSurface: color(begin.runningSurface, end.runningSurface),
      restarting: color(begin.restarting, end.restarting),
      restartingText: color(begin.restartingText, end.restartingText),
      warningSurface: color(begin.warningSurface, end.warningSurface),
      destructiveSurface: color(
        begin.destructiveSurface,
        end.destructiveSurface,
      ),
      chart1: color(begin.chart1, end.chart1),
      chart2: color(begin.chart2, end.chart2),
      chart3: color(begin.chart3, end.chart3),
      chart4: color(begin.chart4, end.chart4),
      chart5: color(begin.chart5, end.chart5),
    );
  }
}

class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens(this.palette);

  static const light = AppColorTokens(AppPalette.light);
  static const dark = AppColorTokens(AppPalette.dark);

  final AppPalette palette;

  Color get surface => palette.card;
  Color get surfaceBorder => palette.border;
  Color get primaryText => palette.foreground;
  Color get secondaryText => palette.mutedForeground;
  Color get tagBackground => palette.muted;
  Color get selectedBackground => palette.selectedSurface;

  static AppColorTokens fallback(Brightness brightness) {
    return brightness == Brightness.light ? light : dark;
  }

  @override
  AppColorTokens copyWith({AppPalette? palette}) {
    return AppColorTokens(palette ?? this.palette);
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) {
      return this;
    }
    return AppColorTokens(AppPalette.lerp(palette, other.palette, t));
  }
}

class ColorManager {
  static AppColorTokens tokens(BuildContext context) {
    return Theme.of(context).extension<AppColorTokens>() ??
        AppColorTokens.fallback(Theme.of(context).brightness);
  }

  static AppPalette palette(BuildContext context) => tokens(context).palette;

  static Color surface(BuildContext context) => tokens(context).surface;

  static Color primaryText(BuildContext context) => tokens(context).primaryText;

  static Color secondaryText(BuildContext context) {
    return tokens(context).secondaryText;
  }

  static Color nodeLatency(BuildContext context, int delay) {
    final colors = palette(context);
    if (!PingDelayConstants.isSuccessful(delay)) return colors.mutedForeground;
    // These tones remain legible as small text on normal and selected cards.
    return delay <= 500
        ? colors.runningBadge
        : delay <= 1000
        ? colors.restartingText
        : colors.primaryHover;
  }

  static Color tagBackground(BuildContext context) {
    return tokens(context).tagBackground;
  }

  static Color border(BuildContext context) => tokens(context).surfaceBorder;

  static Color selected(BuildContext context) {
    return tokens(context).selectedBackground;
  }
}
