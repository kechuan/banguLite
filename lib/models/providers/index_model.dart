
import 'dart:async';

import 'package:bangu_lite/hive/config_model.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';

class IndexModel extends ChangeNotifier {
  IndexModel(){
    initModel();
  }


  DateTime dataTime = DateTime.now();
  int selectedYear = DateTime.now().year;
  int selectedWeekDay = DateTime.now().weekday;
  SeasonType selectedSeason = judgeSeasonRange(DateTime.now().month,currentTime:true);

  int starUpdateFlag = 0;

  Completer? loadFuture; //适用作用目标只有一个的对象里

  //除了 星期一-日之外 还有一个 最热门 的属性存放评分7.0+的番剧
  Map<String, List<BangumiDetails>> calendarBangumis = {
    "星期一":[],
    "星期二":[],
    "星期三":[],
    "星期四":[],
    "星期五":[],
    "星期六":[],
    "星期日":[],
    "最热门":[]
  }; 

  AppConfig userConfig = defaultAPPConfig();
  

//  List<Map<String,num>> starsUpdateRating = [];
  Map<int,Map<String,num>> starsUpdateRating = {};

  // 草稿箱 [标题:内容]
  // 当然标题不一定会存在 如果不存在直接置为空就好

  
  //理论上这样做的话 会有发布内容会被互相覆盖的问题
  //但我不应该响应这种情况 毕竟是DAU没两位数的项目
  //试试Record吧。。
  final Map<dynamic,(String,String)> draftContent = {};

  int cachedImageSize = 0;

  void initModel() async {
    loadConfigData();
    await updateStarDetail();
  }

  void loadConfigData(){
    userConfig = MyHive.appConfigDataBase.get("currentTheme") ?? defaultAPPConfig();
  }

  void loadHistoryData(){

  }

  void updateThemeMode(ThemeMode mode,{bool? config}) {
    userConfig.themeMode = mode;
    notifyListeners();
    if(config == true) updateConfig();    
  }

  void updateThemeColor(AppThemeColor themeColor){
    userConfig.currentThemeColor = themeColor;
	  userConfig.isSelectedCustomColor = false;
    updateConfig();
  }

  void updateCustomColor(Color customColor){
    userConfig.customColor = customColor;
    userConfig.isSelectedCustomColor = true;
    updateConfig();
  }

  void updateFontSize(ScaleType scale) {
    AppFontSize.scale = scale;
    userConfig.fontScale = scale;
    updateConfig();
  }

  void updateFollowThemeColor(bool detailfollowStatus){
    userConfig.isFollowThemeColor = detailfollowStatus;
    updateConfig();
  }

  void updateCommentImageLoadMode(bool imageLoadMode){
    userConfig.isManuallyImageLoad = imageLoadMode;
    updateConfig();
  }

  Future<void> updateStarDetail() async {
    List<int> starsList = [];

	if(MyHive.starBangumisDataBase.keys.isEmpty) return;
    
    for(dynamic bangumiID in MyHive.starBangumisDataBase.keys){
      starsList.add(bangumiID);
    }
    
    starsUpdateRating = await compute(
      loadStarsDetail,
      starsList
    );

    debugPrint("timestamp: ${DateTime.now()} update Star done");

  }

  void resetConfig(){
    MyHive.appConfigDataBase.clear();
    userConfig = defaultAPPConfig();
    AppFontSize.scale = ScaleType.medium;
    notifyListeners();
  }

  void updateConfig(){
    MyHive.appConfigDataBase.put("currentTheme", userConfig);
    notifyListeners();
  }

  Future<void> updateCachedSize() async {
    cachedImageSize = await compute(getTotalSizeOfFilesInDir, MyHive.cachedImageDir);
    updateConfig();
  }

  Future<void> reloadCalendar({Future<List<BangumiDetails>> Function()? switchCalendar}){
    loadFuture = null;
    return loadCalendar(switchCalendar:switchCalendar);
  }

  Future<void> loadCalendar({Future<List<BangumiDetails>> Function()? switchCalendar}) async {

    if(loadFuture!=null) return loadFuture!.future;

    Completer loadCompleter = Completer();

    debugPrint("timestamp: ${DateTime.now()} calendar start");
    loadFuture = loadCompleter;

    if(switchCalendar!=null){

      await switchCalendar().then((detailsList){
        debugPrint("timestamp: ${DateTime.now()} calendar get");
        calendarBangumis = searchDataAdapter(detailsList);
      });


    }

    else{

      await HttpApiClient.client.get(BangumiAPIUrls.calendar).then((response){
        debugPrint("timestamp: ${DateTime.now()} calendar get");
        calendarBangumis = loadCalendarData(response,animeFliter: true);
      });

    }

    dataTime = DateTime.now();
    debugPrint("timestamp: $dataTime calendar done");

    loadCompleter.complete();
    notifyListeners();
    //loadFuture = null;

    return loadCompleter.future;

  }

  void updateSelectedWeekDay(int newWeekDay){
    selectedWeekDay = newWeekDay;
    notifyListeners();
  }

  void updateStar(){
    starUpdateFlag+=1;
    notifyListeners();
  }

}

class AppFontSize {
  static ScaleType scale = ScaleType.medium;

  static double get s16 => 16 * scale.fontScale;
  static double get s14 => 14 * scale.fontScale;
  static double getScaledSize(double fontSize) => fontSize * scale.fontScale;

  static void init(){
    //Hive 存放
    scale = ScaleType.medium;
  }

}