
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class AppConfig extends HiveObject{

  AppThemeColor? currentThemeColor = AppThemeColor.ruby;
  ScaleType? fontScale = ScaleType.medium;
  ThemeMode? themeMode = ThemeMode.system;
  Color? customColor;
  bool? isSelectedCustomColor = false;
  bool? isFollowThemeColor = false;
  bool? isManuallyImageLoad = true;
  bool? isUpdateAlert = true;
  bool? isPureDarkMode = true;

  String? currentProxyAddress = '';
  bool? isImgTagProxy = true;

  //登入凭证

  @override
  String toString() {
    //debugPrint("config:[$currentThemeColor/$fontScale/$themeMode/$customColor]");
    return """config:[
      currentThemeColor:$currentThemeColor
      fontScale:$fontScale
      themeMode:$themeMode
      isPureDarkMode:$isPureDarkMode
      customColor:$customColor
      isSelectedCustomColor:$isSelectedCustomColor
      follow:$isFollowThemeColor
      ManuallyImageLoad:$isManuallyImageLoad
      isUpdateAlert:$isUpdateAlert
      currentProxyAddress:$currentProxyAddress
      isImgProxy:$isImgTagProxy
    ]""";
  }
}

AppConfig defaultAPPConfig() => AppConfig();
