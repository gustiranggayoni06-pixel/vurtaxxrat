import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeColors {
  final String name;
  final Color background;
  final Color card;
  final Color accent;
  final String? wallpaperPath;

  const AppThemeColors({
    required this.name,
    required this.background,
    required this.card,
    required this.accent,
    this.wallpaperPath,
  });

  ThemeData toTheme(ThemeData base) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    final isDark = brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF172033);
    final muted = isDark ? Colors.white70 : const Color(0xFF526174);

    return base.copyWith(
      brightness: brightness,
      scaffoldBackgroundColor: background,
      canvasColor: card,
      cardColor: card,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: brightness,
        primary: accent,
        secondary: accent,
        surface: card,
        onSurface: foreground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: card,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: accent),
        titleTextStyle: TextStyle(
          color: foreground,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: accent.withOpacity(.35)),
        ),
      ),
      dividerTheme: DividerThemeData(color: accent.withOpacity(.25)),
      iconTheme: IconThemeData(color: accent),
      textTheme: base.textTheme.apply(
        bodyColor: foreground,
        displayColor: foreground,
      ).copyWith(
        bodySmall: base.textTheme.bodySmall?.copyWith(color: muted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: accent.withOpacity(.35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: accent.withOpacity(.18),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? accent : muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected) ? accent : muted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: accent,
        unselectedItemColor: muted,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: accent,
        thumbColor: accent,
      ),
    );
  }
}

class AppThemeController {
  AppThemeController._();

  static const _nameKey = 'vurtax_global_theme_name';
  static const _bgKey = 'vurtax_global_theme_bg';
  static const _cardKey = 'vurtax_global_theme_card';
  static const _accentKey = 'vurtax_global_theme_accent';
  static const _wallpaperKey = 'vurtax_global_theme_wallpaper';

  static final ValueNotifier<AppThemeColors> notifier =
      ValueNotifier<AppThemeColors>(_defaultTheme);

  static const AppThemeColors _defaultTheme = AppThemeColors(
    name: 'Ocean',
    background: Color(0xFFDCEEFB),
    card: Color(0xFFFFFFFF),
    accent: Color(0xFF1565C0),
  );

  static AppThemeColors get current => notifier.value;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    notifier.value = AppThemeColors(
      name: prefs.getString(_nameKey) ?? _defaultTheme.name,
      background: Color(prefs.getInt(_bgKey) ?? _defaultTheme.background.value),
      card: Color(prefs.getInt(_cardKey) ?? _defaultTheme.card.value),
      accent: Color(prefs.getInt(_accentKey) ?? _defaultTheme.accent.value),
      wallpaperPath: prefs.getString(_wallpaperKey),
    );
  }

  static Future<void> setTheme({
    required String name,
    required Color background,
    required Color card,
    required Color accent,
    String? wallpaperPath,
  }) async {
    notifier.value = AppThemeColors(
      name: name,
      background: background,
      card: card,
      accent: accent,
      wallpaperPath: wallpaperPath ?? current.wallpaperPath,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setInt(_bgKey, background.value);
    await prefs.setInt(_cardKey, card.value);
    await prefs.setInt(_accentKey, accent.value);
    final path = notifier.value.wallpaperPath;
    if (path == null || path.isEmpty) {
      await prefs.remove(_wallpaperKey);
    } else {
      await prefs.setString(_wallpaperKey, path);
    }
  }

  static Future<void> setWallpaper(String? path) async {
    notifier.value = AppThemeColors(
      name: current.name,
      background: current.background,
      card: current.card,
      accent: current.accent,
      wallpaperPath: path,
    );
    final prefs = await SharedPreferences.getInstance();
    if (path == null || path.isEmpty) {
      await prefs.remove(_wallpaperKey);
    } else {
      await prefs.setString(_wallpaperKey, path);
    }
  }
}
