import 'package:flutter/material.dart';
import 'package:tatlacas_flutter_core/src/models/app_theme_entity.dart';
import 'package:tatlacas_sql_storage/tatlacas_sql_storage.dart';

import 'models/app_theme_bundle.dart';
import 'models/app_theme_properties.dart';

abstract class AppThemeRepository<TEntity extends AppThemeEntity> {
  final SqlStorage _storage;

  TEntity get type;

  static const String _darkThemePrefix = '#MaterialAppTheme_Dark#';
  static const String _highContrastDarkThemePrefix =
      '#MaterialAppTheme_HighContrastDark#';
  static const String _highContrastThemePrefix =
      '#MaterialAppTheme_HighContrast#';



  late ThemeProperties _properties;

  ThemeProperties get properties => _properties;



  AppThemeBundle<TEntity> createUpgradeTheme(
      ThemeProperties themeProperties, int version);

  Future<AppThemeBundle<TEntity>> changeTheme(ThemeProperties themeProperties) async {
    var themeBundle = await getThemeNamed(themeProperties.name);
    if (themeBundle == null) {
      print('ERROR: Theme $themeProperties not found'); //todo Log
      //try insert theme
      themeBundle = await insertOrUpdateTheme(
        createUpgradeTheme(themeProperties, 0),
      );
      notifyAndSaveKeys(
          ThemeProperties(themeBundle.theme.themeName!, themeBundle.theme.themeVersion));
    } else {
      //If versions dont match, upgrade
      if (themeProperties.version != themeBundle.theme.themeVersion) {
        themeBundle = await insertOrUpdateTheme(
          createUpgradeTheme(themeProperties, themeBundle.theme.themeVersion),
        );
      } else {
        themeBundle = themeBundle;
      }
      notifyAndSaveKeys(
          ThemeProperties(themeBundle.theme.themeName!, themeBundle.theme.themeVersion));
    }
    return themeBundle;
  }

  Future saveThemeInUse(ThemeProperties themeProperties);

  Future notifyAndSaveKeys(ThemeProperties themeProperties) async {
    await saveThemeInUse(themeProperties);
    this._properties = themeProperties;
  }


  static AppThemeBundle<TEntity> createTheme<TEntity extends AppThemeEntity>(
      AppThemeBundle<TEntity> themeBundle, ThemeProperties properties) {
    themeBundle.theme.themeName = properties.name;
    themeBundle.theme.themeVersion = properties.version;
    themeBundle.theme.themeMode = themeBundle.themeMode;
    return themeBundle;
  }
  

  AppThemeRepository({
    required SqlStorage storage,
  }) : this._storage = storage;

  TEntity? fromJson(Map<String, dynamic>? json);

  Future<AppThemeBundle<TEntity>?> getThemeNamed(String themeName) async {
    var themeMap = await _storage.getEntity(type,
        where: SqlWhere(AppThemeEntity.columnThemeName, value: themeName));
    final theme = fromJson(themeMap);
    if (theme == null) return null;
    var darkTheme = fromJson(await _storage.getEntity(type,
        where: SqlWhere(AppThemeEntity.columnThemeName,
            value: '$_darkThemePrefix$themeName')));
    var highContrastTheme = fromJson(await _storage.getEntity(type,
        where: SqlWhere(AppThemeEntity.columnThemeName,
            value: '$_highContrastThemePrefix$themeName')));
    var highContrastDarkTheme = fromJson(await _storage.getEntity(type,
        where: SqlWhere(AppThemeEntity.columnThemeName,
            value: '$_highContrastDarkThemePrefix$themeName')));
    return AppThemeBundle<TEntity>(
      theme: theme,
      themeMode: theme.themeMode ?? ThemeMode.system,
      darkTheme: darkTheme,
      highContrastDarkTheme: highContrastDarkTheme,
      highContrastTheme: highContrastTheme,
    );
  }

  Future<AppThemeBundle<TEntity>> insertOrUpdateTheme(
      AppThemeBundle<TEntity> themeBundle) async {
    var theme = await _storage.insertOrUpdate(themeBundle.theme) as TEntity;
    TEntity? darkTheme, highContrastDarkTheme, highContrastTheme;
    if (themeBundle.darkTheme != null) {
      themeBundle.darkTheme!.themeName =
          '$_darkThemePrefix${themeBundle.theme.themeName}';
      darkTheme =
          (await _storage.insertOrUpdate(themeBundle.darkTheme!)) as TEntity?;
    }
    if (themeBundle.highContrastDarkTheme != null) {
      themeBundle.darkTheme!.themeName =
          '$_darkThemePrefix${themeBundle.theme.themeName}';
      highContrastDarkTheme = (await _storage
          .insertOrUpdate(themeBundle.highContrastDarkTheme!)) as TEntity?;
    }
    if (themeBundle.highContrastTheme != null) {
      themeBundle.darkTheme!.themeName =
          '$_darkThemePrefix${themeBundle.theme.themeName}';
      highContrastTheme = (await _storage
          .insertOrUpdate(themeBundle.highContrastTheme!)) as TEntity?;
    }
    return AppThemeBundle<TEntity>(
      theme: theme,
      themeMode: theme.themeMode ?? ThemeMode.system,
      darkTheme: darkTheme,
      highContrastDarkTheme: highContrastDarkTheme,
      highContrastTheme: highContrastTheme,
    );
  }
}
