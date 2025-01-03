
import 'dart:async';

import 'package:bangu_lite/hive/config_model.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/bangumi_details.dart';

class IndexModel extends ChangeNotifier {
  IndexModel(){
    initModel();
  }

  DateTime dataTime = DateTime.now();
  int selectedWeekDay = DateTime.now().weekday;

  static Completer? loadFuture; //适用作用目标只有一个的对象里

  int cachedImageSize = 0;

  //除了 星期一-日之外 还有一个 最热门 的属性存放评分7.0+的番剧
  Map<String, List<BangumiDetails>> calendarBangumis = {}; 
  AppConfig userConfig = defaultAPPConfig();

  void initModel() async {
    loadConfigData();
    
  }

  void loadConfigData(){

    for(AppConfig currentConfig in MyHive.appConfigDataBase.values){
      userConfig = currentConfig;
    }

  }

  void updateThemeMode(ThemeMode mode,{bool? config}) {
    userConfig.themeMode = mode;
    notifyListeners();
    if(config == true) updateConfig();
    
  }

  void updateThemeColor(BangumiThemeColor themeColor){
    userConfig.currentThemeColor = themeColor;
	userConfig.isSelectedCustomColor = false;
    notifyListeners();
    updateConfig();
  }

  void updateCustomColor(Color customColor){
	userConfig.customColor = customColor;
	userConfig.isSelectedCustomColor = true;
    notifyListeners();
    updateConfig();
  }

  void updateFontSize(ScaleType scale) {
    AppFontSize.scale = scale;
    userConfig.fontScale = scale;
    notifyListeners();
    updateConfig();
  }

  void updateFollowThemeColor(bool detailfollowStatus){
    userConfig.isfollowThemeColor = detailfollowStatus;
    notifyListeners();
    updateConfig();
  }

  void resetConfig(){
    MyHive.appConfigDataBase.clear();
    userConfig = defaultAPPConfig();
    AppFontSize.scale = ScaleType.medium;
    notifyListeners();
  }

  void updateConfig(){
	  MyHive.appConfigDataBase.put("currentTheme", userConfig);
  }

  Future<void> updateCachedSize() async {
    cachedImageSize = await compute(getTotalSizeOfFilesInDir, MyHive.cachedImageDir);
    notifyListeners();
    updateConfig();
  }

  Future<void> reloadCalendar(){
    loadFuture = null;
    return loadCalendar();
  }

  Future<void> loadCalendar() async {

    if(loadFuture!=null) return loadFuture!.future;

    Completer loadCompleter = Completer();

    debugPrint("timestamp: ${DateTime.now()} calendar start");
    loadFuture = loadCompleter;

    await HttpApiClient.client.get(BangumiAPIUrls.calendar).then((response){
      debugPrint("timestamp: ${DateTime.now()} calendar get");

      calendarBangumis = loadCalendarData(response,animeFliter: true);

      debugPrint("timestamp: ${DateTime.now()} calendar done");

      dataTime = DateTime.now();

      loadCompleter.complete();
      notifyListeners();
      loadFuture = null;

    });

    

    return loadCompleter.future;

  }

  void updateSelectedWeekDay(int newWeekDay){
    selectedWeekDay = newWeekDay;
    notifyListeners();
    updateConfig();
  }



  @override
  void notifyListeners() {
	
    super.notifyListeners();
  }

}

class AppFontSize {
  static ScaleType scale = ScaleType.medium;

  static double get s16 => 16 * scale.fontScale;
  static double getScaledSize(double fontSize) => fontSize * scale.fontScale;

  static init(){
    //Hive 存放
    scale = ScaleType.medium;
  }

}