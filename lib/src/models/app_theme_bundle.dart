import 'package:flutter/material.dart';
import 'package:tatlacas_flutter_core/src/models/app_theme_entity.dart';


class AppThemeBundle<TEntity extends AppThemeEntity> {
  final TEntity theme;
  final TEntity? darkTheme;
  final TEntity? highContrastDarkTheme;
  final TEntity? highContrastTheme;
  final ThemeMode themeMode;

  AppThemeBundle({
    required this.theme,
    this.themeMode = ThemeMode.system,
    this.darkTheme,
    this.highContrastDarkTheme,
    this.highContrastTheme,
  });

  @override
  String toString()=> 'AppThemeBundle {theme:$theme, darkTheme:$darkTheme, highContrastDarkTheme:$highContrastDarkTheme, highContrastTheme:$highContrastTheme, themeMode:$themeMode}';
}
