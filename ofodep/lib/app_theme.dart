import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// The [AppTheme] defines light and dark themes for the app.
///
/// Theme setup for FlexColorScheme package v8.
/// Use same major flex_color_scheme package version. If you use a
/// lower minor version, some properties may not be supported.
/// In that case, remove them after copying this theme to your
/// app or upgrade the package to version 8.2.0.
///
/// Use it in a [MaterialApp] like this:
///
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
/// );
abstract final class AppTheme {
  // The FlexColorScheme defined light mode ThemeData.
  static ThemeData light = FlexThemeData.light(
    // Using FlexColorScheme built-in FlexScheme enum based colors
    scheme: FlexScheme.deepBlue,
    // Input color modifiers.
    usedColors: 3,
    swapLegacyOnMaterial3: true,
    // Component theme configurations for light mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      adaptiveSplash: FlexAdaptive.all(),
      splashType: FlexSplashType.inkSplash,
      splashTypeAdaptive: FlexSplashType.inkSparkle,
      adaptiveRadius: FlexAdaptive.desktop(),
      adaptiveInputDecoratorRadius: FlexAdaptive.iOSAndDesktop(),
      textButtonRadius: 10.0,
      filledButtonRadius: 10.0,
      elevatedButtonRadius: 10.0,
      elevatedButtonSecondarySchemeColor: SchemeColor.onPrimaryFixed,
      outlinedButtonRadius: 10.0,
      inputDecoratorIsFilled: true,
      inputDecoratorIsDense: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorRadius: 6.0,
      inputDecoratorUnfocusedBorderIsColored: true,
      listTileStyle: ListTileStyle.drawer,
      alignedDropdown: true,
      snackBarRadius: 10,
      snackBarElevation: 10,
      appBarCenterTitle: true,
      navigationBarSelectedIconSchemeColor: SchemeColor.primaryFixedDim,
      navigationBarIndicatorOpacity: 0.00,
      navigationBarIndicatorRadius: 15.0,
      navigationBarHeight: 55.0,
      navigationBarLabelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      navigationRailUseIndicator: true,
    ),
    // ColorScheme seed generation configuration for light mode.
    keyColors: const FlexKeyColors(),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  // The FlexColorScheme defined dark mode ThemeData.
  static ThemeData dark = FlexThemeData.dark(
    // Using FlexColorScheme built-in FlexScheme enum based colors.
    scheme: FlexScheme.deepBlue,
    // Input color modifiers.
    usedColors: 3,
    swapLegacyOnMaterial3: true,
    // Component theme configurations for dark mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      adaptiveSplash: FlexAdaptive.all(),
      splashType: FlexSplashType.inkSplash,
      splashTypeAdaptive: FlexSplashType.inkSparkle,
      adaptiveAppBarScrollUnderOff: FlexAdaptive.all(),
      adaptiveRadius: FlexAdaptive.desktop(),
      adaptiveInputDecoratorRadius: FlexAdaptive.iOSAndDesktop(),
      textButtonRadius: 10.0,
      filledButtonRadius: 10.0,
      elevatedButtonRadius: 10.0,
      elevatedButtonSecondarySchemeColor: SchemeColor.onPrimaryFixed,
      outlinedButtonRadius: 10.0,
      inputDecoratorIsFilled: true,
      inputDecoratorIsDense: true,
      inputDecoratorBackgroundAlpha: 28,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorRadius: 6.0,
      inputDecoratorUnfocusedBorderIsColored: true,
      listTileStyle: ListTileStyle.drawer,
      alignedDropdown: true,
      snackBarRadius: 10,
      snackBarElevation: 10,
      appBarBackgroundSchemeColor: SchemeColor.onPrimary,
      appBarForegroundSchemeColor: SchemeColor.primaryFixed,
      appBarCenterTitle: true,
      navigationBarSelectedIconSchemeColor: SchemeColor.primaryFixedDim,
      navigationBarIndicatorOpacity: 0.00,
      navigationBarIndicatorRadius: 15.0,
      navigationBarHeight: 55.0,
      navigationBarLabelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      navigationRailUseIndicator: true,
    ),
    // ColorScheme seed configuration setup for dark mode.
    keyColors: const FlexKeyColors(),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}
