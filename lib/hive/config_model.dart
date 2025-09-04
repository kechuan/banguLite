
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:bangu_lite/internal/utils/const.dart';

class AppConfig extends HiveObject{
  
  AppThemeColor? currentThemeColor = AppThemeColor.ruby;
  ScaleType? fontScale = ScaleType.medium;
  ThemeMode? themeMode = ThemeMode.system;
  Color? customColor;
  bool? isSelectedCustomColor = false;
  bool? isFollowThemeColor = false;
  bool? isManuallyImageLoad = true;
  //登入凭证
  

  @override
  String toString() {
    //debugPrint("config:[$currentThemeColor/$fontScale/$themeMode/$customColor]");
    return """config:[
      currentThemeColor:$currentThemeColor
      fontScale:$fontScale
      themeMode:$themeMode
      customColor:$customColor
      isSelectedCustomColor:$isSelectedCustomColor
      follow:$isFollowThemeColor
      ManuallyImageLoad:$isManuallyImageLoad
    ]""";
  }
}

AppConfig defaultAPPConfig() => AppConfig();