
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/bangumi_details.dart';

class IndexModel extends ChangeNotifier {
  IndexModel();

  DateTime dataTime = DateTime.now();

  static Completer? loadFuture;

  Map<String, List<BangumiDetails>> calendarBangumis = {}; //除了 星期一-日之外 还有一个 最热门 的属性存放评分7.0+的番剧

  int selectedWeekDay = DateTime.now().weekday;

  Future<void> reloadCalendar(){
    loadFuture = null;
    return loadCalendar();
  }

  Future<void> loadCalendar() async {

    if(loadFuture!=null){
      return loadFuture!.future;
    }

    Completer loadCompleter = Completer();

    debugPrint("timestamp: ${DateTime.now()} calendar start");

    loadFuture = loadCompleter;

    await HttpApiClient.client.get(BangumiAPIUrls.calendar).then((response){
      debugPrint("timestamp: ${DateTime.now()} calendar get");

      calendarBangumis = loadCalendarData(response,animeFliter: true);
      //dataTime = DateTime.now();

      debugPrint("timestamp: ${DateTime.now()} calendar done");

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