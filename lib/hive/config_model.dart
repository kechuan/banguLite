
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:bangu_lite/internal/const.dart';

class AppConfig extends HiveObject{
  
  BangumiThemeColor? currentThemeColor;
  ScaleType? fontScale;
  ThemeMode? themeMode;
  Color? customColor;
  bool? detailfollowThemeColor;

  @override
  String toString() {
    //debugPrint("config:[$currentThemeColor/$fontScale/$themeMode/$customColor]");
    return """config:[
      currentThemeColor:$currentThemeColor
      fontScale:$fontScale
      themeMode:$themeMode
      customColor:$customColor
      follow:$detailfollowThemeColor
    ]""";
  }
}


AppConfig defaultAPPConfig(){
  return AppConfig()
    ..currentThemeColor = BangumiThemeColor.sea
    ..fontScale = ScaleType.medium
    ..themeMode = ThemeMode.system
    ..detailfollowThemeColor = false
  ;
}