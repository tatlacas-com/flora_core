import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tatlacas_sql_storage/tatlacas_sql_storage.dart';

abstract class AppThemeEntity extends Entity {
  ThemeData? _themeData;

  ThemeData get themeData => _themeData ??= generateTheme();

  //#region Main ThemeData
  ThemeMode? themeMode;

  //Brightness
  String? brightness, primaryColorBrightness, accentColorBrightness;

  //Colors
  Color? primaryColor,
      primaryColorLight,
      primaryColorDark,
      accentColor,
      canvasColor,
      shadowColor,
      scaffoldBackgroundColor,
      bottomAppBarColor,
      cardColor,
      dividerColor,
      focusColor,
      hoverColor,
      highlightColor,
      splashColor,
      selectedRowColor,
      unselectedWidgetColor,
      disabledColor,
      buttonColor,
      backgroundColor,
      dialogBackgroundColor,
      indicatorColor,
      hintColor,
      errorColor,
      toggleableActiveColor,
      secondaryHeaderColor;

  int themeVersion = 1;

  //Other
  String? visualDensity, primarySwatch, themeName, fontFamily;
  Color? primaryColorForPrimarySwatch, statusBarBackgroundColor;

  //Enums
  String? platform, materialTapTargetSize;

  //Booleans
  bool? applyElevationOverlayColor, fixTextFieldOutlineLabel;

//#endregion

  //#region Columns

  //#region Column Definitions
  //Brightness

  static final SqlColumn<AppThemeEntity, String> columnThemeMode =
      SqlColumn<AppThemeEntity, String>(
    'themeMode',
    read: (entity) {
      if (entity.themeMode == null) return 'system';
      switch (entity.themeMode) {
        case ThemeMode.system:
          return 'system';
        case ThemeMode.light:
          return 'light';
        case ThemeMode.dark:
          return 'dark';
        default:
          return 'system';
      }
    },
  );

  static final SqlColumn<AppThemeEntity, String> columnBrightness =
      SqlColumn<AppThemeEntity, String>(
    'brightness',
    read: (entity) => entity.brightness,
  );
  static final SqlColumn<AppThemeEntity, String> columnPrimaryColorBrightness =
      SqlColumn<AppThemeEntity, String>(
    'primaryColorBrightness',
    read: (entity) => entity.primaryColorBrightness,
  );
  static final SqlColumn<AppThemeEntity, String> columnAccentColorBrightness =
      SqlColumn<AppThemeEntity, String>(
    'accentColorBrightness',
    read: (entity) => entity.accentColorBrightness,
  );

//Colors
  static final SqlColumn<AppThemeEntity, int> columnPrimaryColor =
      SqlColumn<AppThemeEntity, int>(
    'primaryColor',
    read: (entity) => entity.primaryColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnThemeVersion =
      SqlColumn<AppThemeEntity, int>(
    'themeVersion',
    read: (entity) => entity.themeVersion,
  );
  static final SqlColumn<AppThemeEntity, int> columnPrimaryColorLight =
      SqlColumn<AppThemeEntity, int>(
    'primaryColorLight',
    read: (entity) => entity.primaryColorLight?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnPrimaryColorDark =
      SqlColumn<AppThemeEntity, int>(
    'primaryColorDark',
    read: (entity) => entity.primaryColorDark?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnAccentColor =
      SqlColumn<AppThemeEntity, int>(
    'accentColor',
    read: (entity) => entity.accentColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnCanvasColor =
      SqlColumn<AppThemeEntity, int>(
    'canvasColor',
    read: (entity) => entity.canvasColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnShadowColor =
      SqlColumn<AppThemeEntity, int>(
    'shadowColor',
    read: (entity) => entity.shadowColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnScaffoldBackgroundColor =
      SqlColumn<AppThemeEntity, int>(
    'scaffoldBackgroundColor',
    read: (entity) => entity.scaffoldBackgroundColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnBottomAppBarColor =
      SqlColumn<AppThemeEntity, int>(
    'bottomAppBarColor',
    read: (entity) => entity.bottomAppBarColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnCardColor =
      SqlColumn<AppThemeEntity, int>(
    'cardColor',
    read: (entity) => entity.cardColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnDividerColor =
      SqlColumn<AppThemeEntity, int>(
    'dividerColor',
    read: (entity) => entity.dividerColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnFocusColor =
      SqlColumn<AppThemeEntity, int>(
    'focusColor',
    read: (entity) => entity.focusColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnHoverColor =
      SqlColumn<AppThemeEntity, int>(
    'hoverColor',
    read: (entity) => entity.hoverColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnHighlightColor =
      SqlColumn<AppThemeEntity, int>(
    'highlightColor',
    read: (entity) => entity.highlightColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnSplashColor =
      SqlColumn<AppThemeEntity, int>(
    'splashColor',
    read: (entity) => entity.splashColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnSelectedRowColor =
      SqlColumn<AppThemeEntity, int>(
    'selectedRowColor',
    read: (entity) => entity.selectedRowColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnUnselectedWidgetColor =
      SqlColumn<AppThemeEntity, int>(
    'unselectedWidgetColor',
    read: (entity) => entity.unselectedWidgetColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnDisabledColor =
      SqlColumn<AppThemeEntity, int>(
    'disabledColor',
    read: (entity) => entity.disabledColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnButtonColor =
      SqlColumn<AppThemeEntity, int>(
    'buttonColor',
    read: (entity) => entity.buttonColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnBackgroundColor =
      SqlColumn<AppThemeEntity, int>(
    'backgroundColor',
    read: (entity) => entity.backgroundColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnDialogBackgroundColor =
      SqlColumn<AppThemeEntity, int>(
    'dialogBackgroundColor',
    read: (entity) => entity.dialogBackgroundColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnIndicatorColor =
      SqlColumn<AppThemeEntity, int>(
    'indicatorColor',
    read: (entity) => entity.indicatorColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnHintColor =
      SqlColumn<AppThemeEntity, int>(
    'hintColor',
    read: (entity) => entity.hintColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnErrorColor =
      SqlColumn<AppThemeEntity, int>(
    'errorColor',
    read: (entity) => entity.errorColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnToggleableActiveColor =
      SqlColumn<AppThemeEntity, int>(
    'toggleableActiveColor',
    read: (entity) => entity.toggleableActiveColor?.value,
  );
  static final SqlColumn<AppThemeEntity, int> columnSecondaryHeaderColor =
      SqlColumn<AppThemeEntity, int>(
    'secondaryHeaderColor',
    read: (entity) => entity.secondaryHeaderColor?.value,
  );

  //Other
  static final SqlColumn<AppThemeEntity, String> columnFontFamily =
      SqlColumn<AppThemeEntity, String>(
    'fontFamily',
    read: (entity) => entity.fontFamily,
  );
  static final SqlColumn<AppThemeEntity, String> columnVisualDensity =
      SqlColumn<AppThemeEntity, String>(
    'visualDensity',
    read: (entity) => entity.visualDensity,
  );
  static final SqlColumn<AppThemeEntity, String> columnPrimarySwatch =
      SqlColumn<AppThemeEntity, String>(
    'primarySwatch',
    read: (entity) => entity.primarySwatch,
  );
  static final SqlColumn<AppThemeEntity, String> columnThemeName =
      SqlColumn<AppThemeEntity, String>(
    'themeName',
    notNull: true,
    unique: true,
    read: (entity) => entity.themeName,
  );
  static final SqlColumn<AppThemeEntity, int>
      columnPrimaryColorForPrimarySwatch = SqlColumn<AppThemeEntity, int>(
    'primaryColorForPrimarySwatch',
    read: (entity) => entity.primaryColorForPrimarySwatch?.value,
  );

  static final SqlColumn<AppThemeEntity, int> columnStatusBarBackgroundColor =
      SqlColumn<AppThemeEntity, int>(
    'statusBarBackgroundColor',
    read: (entity) => entity.statusBarBackgroundColor?.value,
  );

  //Enums
  static final SqlColumn<AppThemeEntity, String> columnPlatform =
      SqlColumn<AppThemeEntity, String>(
    'platform',
    read: (entity) => entity.platform,
  );
  static final SqlColumn<AppThemeEntity, String> columnMaterialTapTargetSize =
      SqlColumn<AppThemeEntity, String>(
    'materialTapTargetSize',
    read: (entity) => entity.materialTapTargetSize,
  );

  //Booleans
  static final SqlColumn<AppThemeEntity, bool>
      columnApplyElevationOverlayColor = SqlColumn<AppThemeEntity, bool>(
    'applyElevationOverlayColor',
    read: (entity) => entity.applyElevationOverlayColor,
  );
  static final SqlColumn<AppThemeEntity, bool> columnFixTextFieldOutlineLabel =
      SqlColumn<AppThemeEntity, bool>(
    'fixTextFieldOutlineLabel',
    read: (entity) => entity.fixTextFieldOutlineLabel,
  );

//#endregion

  //#region Columns List
  @override
  List<SqlColumn> get columns => [
        columnId,
        columnBrightness,
        columnPrimaryColorBrightness,
        columnAccentColorBrightness,
        columnPrimaryColor,
        columnPrimaryColorLight,
        columnPrimaryColorDark,
        columnThemeMode,
        columnAccentColor,
        columnCanvasColor,
        columnStatusBarBackgroundColor,
        columnShadowColor,
        columnScaffoldBackgroundColor,
        columnBottomAppBarColor,
        columnCardColor,
        columnDividerColor,
        columnFocusColor,
        columnHoverColor,
        columnHighlightColor,
        columnSplashColor,
        columnSelectedRowColor,
        columnUnselectedWidgetColor,
        columnDisabledColor,
        columnThemeVersion,
        columnButtonColor,
        columnBackgroundColor,
        columnDialogBackgroundColor,
        columnIndicatorColor,
        columnHintColor,
        columnErrorColor,
        columnToggleableActiveColor,
        columnSecondaryHeaderColor,
        columnFontFamily,
        columnVisualDensity,
        columnPrimarySwatch,
        columnThemeName,
        columnPrimaryColorForPrimarySwatch,
        columnPlatform,
        columnMaterialTapTargetSize,
        columnApplyElevationOverlayColor,
        columnFixTextFieldOutlineLabel,
      ];

//#endregion

  //#endregion

//#region Constructor
  AppThemeEntity({
    String? id,
    //Brightness
    this.brightness,
    this.primaryColorBrightness,
    this.accentColorBrightness,

//Colors
    this.primaryColor,
    this.primaryColorLight,
    this.primaryColorDark,
    this.accentColor,
    this.canvasColor,
    this.shadowColor,
    this.scaffoldBackgroundColor,
    this.bottomAppBarColor,
    this.cardColor,
    this.dividerColor,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.selectedRowColor,
    this.unselectedWidgetColor,
    this.disabledColor,
    this.buttonColor,
    this.backgroundColor,
    this.dialogBackgroundColor,
    this.indicatorColor,
    this.hintColor,
    this.errorColor,
    this.toggleableActiveColor,
    this.secondaryHeaderColor,

    //Other
    this.fontFamily,
    this.visualDensity,
    this.primarySwatch,
    this.themeName,
    this.primaryColorForPrimarySwatch,
    this.statusBarBackgroundColor,

    //Enums
    this.platform,
    this.materialTapTargetSize,

    //Booleans
    this.applyElevationOverlayColor,
    this.fixTextFieldOutlineLabel,
  }) : super(id: id);

// #endregion

//#region Generate Entity From ThemeData values
  void generateFrom({
    Brightness? brightness,
    VisualDensity? visualDensity,
    Color? primaryColorForPrimarySwatch,
    Map<int, Color>? primarySwatch,
    Color? primaryColor,
    Brightness? primaryColorBrightness,
    Color? primaryColorLight,
    Color? primaryColorDark,
    Color? accentColor,
    Brightness? accentColorBrightness,
    Color? canvasColor,
    Color? shadowColor,
    Color? scaffoldBackgroundColor,
    Color? statusBarBackgroundColor,
    Color? bottomAppBarColor,
    Color? cardColor,
    Color? dividerColor,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    Color? selectedRowColor,
    Color? unselectedWidgetColor,
    Color? disabledColor,
    Color? buttonColor,
    Color? secondaryHeaderColor,
    Color? backgroundColor,
    Color? dialogBackgroundColor,
    Color? indicatorColor,
    Color? hintColor,
    Color? errorColor,
    int themeVersion = 1,
    String? themeName,
    Color? toggleableActiveColor,
    String? fontFamily,
    TargetPlatform? platform,
    MaterialTapTargetSize? materialTapTargetSize,
    bool? applyElevationOverlayColor,
    bool? fixTextFieldOutlineLabel,
  }) {
    this.brightness = brightness != null
        ? (brightness == Brightness.dark ? 'dark' : 'light')
        : null;
    this.primaryColorBrightness = primaryColorBrightness != null
        ? (primaryColorBrightness == Brightness.dark ? 'dark' : 'light')
        : null;
    this.accentColorBrightness = accentColorBrightness != null
        ? (accentColorBrightness == Brightness.dark ? 'dark' : 'light')
        : null;
    if (visualDensity != null) {
      Map<String, dynamic> de = {
        'horizontal': visualDensity.horizontal,
        'vertical': visualDensity.vertical
      };
      this.visualDensity = json.encode(de);
    }
    if (primaryColorForPrimarySwatch != null)
      this.primaryColorForPrimarySwatch = primaryColorForPrimarySwatch;
    if (statusBarBackgroundColor != null)
      this.statusBarBackgroundColor = statusBarBackgroundColor;
    if (primarySwatch != null) {
      Map<String, int> swatch = {};
      for (var val in primarySwatch.entries) {
        swatch['${val.key}'] = val.value.value;
      }
      this.primarySwatch = json.encode(swatch);
    }
    this.primaryColor = primaryColor;

    this.primaryColorLight = primaryColorLight;
    this.primaryColorDark = primaryColorDark;
    this.themeVersion = themeVersion;
    this.accentColor = accentColor;
    this.canvasColor = canvasColor;
    this.shadowColor = shadowColor;
    this.scaffoldBackgroundColor = scaffoldBackgroundColor;
    this.bottomAppBarColor = bottomAppBarColor;
    this.cardColor = cardColor;
    this.dividerColor = dividerColor;
    this.focusColor = focusColor;
    this.hoverColor = hoverColor;
    this.highlightColor = highlightColor;
    this.themeName = themeName;
    this.splashColor = splashColor;
    // if (splashFactory != null)

    this.selectedRowColor = selectedRowColor;

    this.unselectedWidgetColor = unselectedWidgetColor;
    this.disabledColor = disabledColor;
    this.buttonColor = buttonColor;

    /*if (toggleButtonsTheme != null)
      this.toggleButtonsTheme = json.encode(toggleButtonsTheme.toJson());*/

    this.secondaryHeaderColor = secondaryHeaderColor;
    this.backgroundColor = backgroundColor;

    this.dialogBackgroundColor = dialogBackgroundColor;
    this.indicatorColor = indicatorColor;
    this.hintColor = hintColor;
    this.errorColor = errorColor;

    this.toggleableActiveColor = toggleableActiveColor;
    if (fontFamily != null) this.fontFamily = fontFamily;

    if (platform != null) this.platform = targetPlatformString(platform);
    if (materialTapTargetSize != null)
      this.materialTapTargetSize =
          materialTapTargetSize == MaterialTapTargetSize.padded
              ? 'padded'
              : 'shrinkWrap';
    if (applyElevationOverlayColor != null)
      this.applyElevationOverlayColor = applyElevationOverlayColor;

    if (fixTextFieldOutlineLabel != null)
      this.fixTextFieldOutlineLabel = fixTextFieldOutlineLabel;
  }

//#endregion

  //#region Generate ThemeData from Entity

  @protected
  ThemeData generateTheme() {
    // InteractiveInkFeatureFactory? splashFactory; todo
    //ColorScheme? colorScheme; todo

    Brightness? brightness;
    VisualDensity? visualDensity;
    MaterialColor? primarySwatch;
    Color? primaryColor = this.primaryColor;
    Brightness? primaryColorBrightness;
    Color? primaryColorLight = this.primaryColorLight;
    Color? primaryColorDark = this.primaryColorDark;
    Color? accentColor = this.accentColor;
    Brightness? accentColorBrightness;
    Color? canvasColor = this.canvasColor;
    Color? shadowColor = this.shadowColor;
    Color? scaffoldBackgroundColor = this.scaffoldBackgroundColor;
    Color? bottomAppBarColor = this.bottomAppBarColor;
    Color? cardColor = this.cardColor;
    Color? dividerColor = this.dividerColor;
    Color? focusColor = this.focusColor;
    Color? hoverColor = this.hoverColor;
    Color? highlightColor = this.highlightColor;
    Color? splashColor = this.splashColor;
    Color? selectedRowColor = this.selectedRowColor;
    Color? unselectedWidgetColor = this.unselectedWidgetColor;
    Color? disabledColor = this.disabledColor;
    Color? buttonColor = this.buttonColor;
    Color? secondaryHeaderColor = this.secondaryHeaderColor;
    Color? backgroundColor = this.backgroundColor;
    Color? dialogBackgroundColor = this.dialogBackgroundColor;
    Color? indicatorColor = this.indicatorColor;
    Color? hintColor = this.hintColor;
    Color? errorColor = this.errorColor;
    Color? toggleableActiveColor = this.toggleableActiveColor;
    String? fontFamily;
    TargetPlatform? platform;
    MaterialTapTargetSize? materialTapTargetSize;
    bool? applyElevationOverlayColor;

    bool? fixTextFieldOutlineLabel;
    if (this.brightness != null) {
      brightness =
          this.brightness == 'dark' ? Brightness.dark : Brightness.light;
    }
    if (this.visualDensity != null) {
      var de = jsonDecode(this.visualDensity!);
      visualDensity = VisualDensity(
        horizontal: de['horizontal'],
        vertical: de['vertical'],
      );
    }
    if (this.primarySwatch != null &&
        this.primaryColorForPrimarySwatch != null) {
      Map<String, dynamic> swatch = jsonDecode(this.primarySwatch!);
      Map<int, Color> ps = {};
      for (var sw in swatch.entries) {
        ps[int.parse(sw.key)] = Color(sw.value);
      }
      primarySwatch =
          MaterialColor(this.primaryColorForPrimarySwatch!.value, ps);
    }
    if (this.primaryColorBrightness != null) {
      primaryColorBrightness = this.primaryColorBrightness == 'dark'
          ? Brightness.dark
          : Brightness.light;
    }
    if (this.accentColorBrightness != null) {
      accentColorBrightness = this.accentColorBrightness == 'dark'
          ? Brightness.dark
          : Brightness.light;
    }

    if (this.fontFamily != null) {
      fontFamily = this.fontFamily;
    }

    if (this.platform != null) {
      targetPlatformFrom(this.platform!);
    }
    if (this.materialTapTargetSize != null) {
      materialTapTargetSize = this.materialTapTargetSize == 'padded'
          ? MaterialTapTargetSize.padded
          : MaterialTapTargetSize.shrinkWrap;
    }
    if (this.applyElevationOverlayColor != null) {
      applyElevationOverlayColor = this.applyElevationOverlayColor;
    }

    if (this.fixTextFieldOutlineLabel != null) {
      fixTextFieldOutlineLabel = this.fixTextFieldOutlineLabel;
    }

    return ThemeData(
      brightness: brightness,
      visualDensity: visualDensity,
      primarySwatch: primarySwatch,
      primaryColor: primaryColor,
      primaryColorBrightness: primaryColorBrightness,
      primaryColorLight: primaryColorLight,
      primaryColorDark: primaryColorDark,
      accentColor: accentColor,
      accentColorBrightness: accentColorBrightness,
      canvasColor: canvasColor,
      shadowColor: shadowColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      bottomAppBarColor: bottomAppBarColor,
      cardColor: cardColor,
      dividerColor: dividerColor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      splashColor: splashColor,
      selectedRowColor: selectedRowColor,
      unselectedWidgetColor: unselectedWidgetColor,
      disabledColor: disabledColor,
      buttonColor: buttonColor,
      secondaryHeaderColor: secondaryHeaderColor,
      backgroundColor: backgroundColor,
      dialogBackgroundColor: dialogBackgroundColor,
      indicatorColor: indicatorColor,
      hintColor: hintColor,
      errorColor: errorColor,
      toggleableActiveColor: toggleableActiveColor,
      fontFamily: fontFamily,
      platform: platform,
      materialTapTargetSize: materialTapTargetSize,
      applyElevationOverlayColor: applyElevationOverlayColor,
      fixTextFieldOutlineLabel: fixTextFieldOutlineLabel,
    );
  }

  String targetPlatformString(TargetPlatform platform) {
    return platform.toString().split('.').last;
  }

  TargetPlatform targetPlatformFrom(String platform) {
    switch (platform) {
      case 'android':
        return TargetPlatform.android;
      case 'fuchsia':
        return TargetPlatform.fuchsia;
      case 'iOS':
        return TargetPlatform.iOS;
      case 'linux':
        return TargetPlatform.linux;
      case 'macOS':
        return TargetPlatform.macOS;
      case 'windows':
        return TargetPlatform.windows;
    }
    return TargetPlatform.android;
  }

//#endregion

@override
  String toString() => 'AppThemeEntity {themeName:$themeName}';
}
