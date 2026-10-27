import 'package:flutter/material.dart';

/// One complete colour set. The app ships five of them, taken from the
/// design references (Sacred Light, Midnight Ottoman, Glass 3D, Masjid, Dark Emerald).
class AzkarPalette {
  const AzkarPalette({
    required this.name,
    required this.isDark,
    required this.bg,
    required this.card,
    required this.cardDeep,
    required this.navBg,
    required this.gold,
    required this.goldSoft,
    required this.goldDark,
    required this.orange,
    required this.accent,
    required this.text,
    required this.textSoft,
    required this.muted,
    required this.border,
    required this.onGold,
  });

  final String name;
  final bool isDark;
  final Color bg;
  final Color card;
  final Color cardDeep;
  final Color navBg;
  final Color gold; // main accent (titles, icons, selected items)
  final Color goldSoft;
  final Color goldDark;
  final Color orange;
  final Color accent;
  final Color text;
  final Color textSoft;
  final Color muted;
  final Color border;
  final Color onGold; // text drawn on top of `gold`
}

const List<AzkarPalette> azkarPalettes = [
  // 0 - Sacred Light
  AzkarPalette(
    name: 'Sacred Light',
    isDark: false,
    bg: Color(0xFFF9F6F0),
    card: Color(0xFFFFFFFF),
    cardDeep: Color(0xFFF3ECD9),
    navBg: Color(0xFFFFFFFF),
    gold: Color(0xFFB8862B),
    goldSoft: Color(0xFFD4A94F),
    goldDark: Color(0xFF8C6417),
    orange: Color(0xFFC9793B),
    accent: Color(0xFF1F7A5C),
    text: Color(0xFF1E2A24),
    textSoft: Color(0xFF3B4A42),
    muted: Color(0xFF6B7A70),
    border: Color(0xFFE2D3A8),
    onGold: Color(0xFFFFFFFF),
  ),
  // 1 - Midnight Ottoman
  AzkarPalette(
    name: 'Midnight Ottoman',
    isDark: true,
    bg: Color(0xFF0B1A3A),
    card: Color(0xFF13275A),
    cardDeep: Color(0xFF0E2046),
    navBg: Color(0xFF0A1630),
    gold: Color(0xFFE8C15A),
    goldSoft: Color(0xFFF2D27D),
    goldDark: Color(0xFFA8832E),
    orange: Color(0xFFE08A3C),
    accent: Color(0xFF7FA6FF),
    text: Color(0xFFF5F1E6),
    textSoft: Color(0xFFD7DDEB),
    muted: Color(0xFF9AA8C7),
    border: Color(0xFF2E4A8A),
    onGold: Color(0xFF1B1200),
  ),
  // 2 - Glassmorphism & 3D
  AzkarPalette(
    name: 'Glass 3D',
    isDark: true,
    bg: Color(0xFF0B2B20),
    card: Color(0xFF16483C),
    cardDeep: Color(0xFF0E3328),
    navBg: Color(0xFF0A2A21),
    gold: Color(0xFFF0CD72),
    goldSoft: Color(0xFFF5DC95),
    goldDark: Color(0xFFA07C2C),
    orange: Color(0xFFF4A261),
    accent: Color(0xFF6FD3A8),
    text: Color(0xFFF4FBF6),
    textSoft: Color(0xFFD2EBDD),
    muted: Color(0xFF9CCDB5),
    border: Color(0xFF3D7B66),
    onGold: Color(0xFF2A1700),
  ),
  // 3 - Masjid Architecture
  AzkarPalette(
    name: 'Masjid',
    isDark: false,
    bg: Color(0xFFF6F1E4),
    card: Color(0xFFFFFBF2),
    cardDeep: Color(0xFFEFE6CF),
    navBg: Color(0xFFFFFBF2),
    gold: Color(0xFF14603F),
    goldSoft: Color(0xFF2E7D5B),
    goldDark: Color(0xFF0E4A30),
    orange: Color(0xFFB8862B),
    accent: Color(0xFFB8862B),
    text: Color(0xFF1D3B2F),
    textSoft: Color(0xFF3E5A4C),
    muted: Color(0xFF6E8277),
    border: Color(0xFFC9B98E),
    onGold: Color(0xFFFFFFFF),
  ),
  // 4 - Dark Emerald & Neon (default)
  AzkarPalette(
    name: 'Dark Emerald',
    isDark: true,
    bg: Color(0xFF021A14),
    card: Color(0xFF0A3228),
    cardDeep: Color(0xFF082418),
    navBg: Color(0xFF021A14),
    gold: Color(0xFFF7D774),
    goldSoft: Color(0xFFFFE9A0),
    goldDark: Color(0xFFB08D2A),
    orange: Color(0xFFFF9F43),
    accent: Color(0xFF39FF88),
    text: Color(0xFFF0FFF6),
    textSoft: Color(0xFFC9F5DC),
    muted: Color(0xFF86D9B3),
    border: Color(0xFF1F7A55),
    onGold: Color(0xFF2A1700),
  ),
];

/// Index of the palette used when the user has not chosen one.
const int defaultPaletteIndex = 4;

/// The colours the screens read. Values follow the palette chosen in Settings.
/// Widgets read them during build, so the app is rebuilt after a change.
class AppColors {
  AppColors._();

  static AzkarPalette _p = azkarPalettes[defaultPaletteIndex];

  static void select(int index) {
    if (index < 0 || index >= azkarPalettes.length) return;
    _p = azkarPalettes[index];
  }

  static bool get isDark => _p.isDark;
  static Color get bg => _p.bg;
  static Color get card => _p.card;
  static Color get cardDeep => _p.cardDeep;
  static Color get navBg => _p.navBg;
  static Color get gold => _p.gold;
  static Color get goldSoft => _p.goldSoft;
  static Color get goldDark => _p.goldDark;
  static Color get orange => _p.orange;
  static Color get accent => _p.accent;
  static Color get text => _p.text;
  static Color get textSoft => _p.textSoft;
  static Color get muted => _p.muted;
  static Color get border => _p.border;
  static Color get onGold => _p.onGold;

  /// Gradient colours for a tile or card. Dark themes keep the [tinted]
  /// colours; light themes use the card colours, so the text on top stays
  /// readable.
  static List<Color> tile(List<Color> tinted) =>
      _p.isDark ? tinted : [_p.card, _p.cardDeep];
}

ThemeData buildTheme() {
  final brightness = AppColors.isDark ? Brightness.dark : Brightness.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: AppColors.gold,
    onPrimary: AppColors.onGold,
    secondary: AppColors.goldSoft,
    onSecondary: AppColors.onGold,
    error: const Color(0xFFD64545),
    onError: Colors.white,
    surface: AppColors.card,
    onSurface: AppColors.text,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.gold,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.gold,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.navBg,
      indicatorColor: AppColors.gold.withAlpha(45),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          color: states.contains(WidgetState.selected)
              ? AppColors.gold
              : AppColors.muted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.gold
              : AppColors.muted,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.goldDark),
      ),
    ),
  );
}
