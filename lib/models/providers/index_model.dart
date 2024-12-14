
import 'dart:async';

import 'package:bangu_lite/internal/const.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/bangumi_details.dart';

class IndexModel extends ChangeNotifier {
  IndexModel();

  DateTime dataTime = DateTime.now();
  BangumiThemeColor currentThemeColor = BangumiThemeColor.sea;
  ThemeMode themeMode = ThemeMode.system;
  int selectedWeekDay = DateTime.now().weekday;


  static Completer? loadFuture; //适用作用目标只有一个的对象里

  Map<String, List<BangumiDetails>> calendarBangumis = {}; //除了 星期一-日之外 还有一个 最热门 的属性存放评分7.0+的番剧

  

  void updateThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
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
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

}