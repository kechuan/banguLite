import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/get.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:flutter/foundation.dart';

/// 番剧放送日历与季度切换状态（从 [IndexModel] 拆分独立，避免切星期/刷新日历波及全局配置订阅者）。
class CalendarModel extends ChangeNotifier {
  DateTime dataTime = DateTime.now();

  int selectedYear = DateTime.now().year;
  int selectedWeekDay = DateTime.now().weekday;
  SeasonType selectedSeason = getSeasonRange(DateTime.now().month, currentTime: true);

  Future<void>? loadingCalendarFuture;

  // 除了 星期一-日之外 还有一个 最热门 的属性存放评分7.0+的番剧
  Map<String, List<BangumiDetails>> calendarBangumis = {
    for (var weekday in WeekDay.values) '星期${weekday.dayText}': [],
    "最热门": [],
  };

  List<BangumiDetails> get hotBangumis => calendarBangumis["最热门"] ?? const [];

  List<BangumiDetails> getWeekdayBangumis(int weekdayIndex) {
    final weekday = WeekDay.values.elementAtOrNull(weekdayIndex - 1);

    if (weekday == null) return const [];

    return calendarBangumis['星期${weekday.dayText}'] ?? const [];
  }

  Future<void> reloadCalendar({Future<List<BangumiDetails>> Function()? switchCalendar}) {
    loadingCalendarFuture = null;

    return loadCalendar(switchCalendar: switchCalendar);
  }

  Future<void> loadCalendar({Future<List<BangumiDetails>> Function()? switchCalendar}) {
    if (loadingCalendarFuture != null) return loadingCalendarFuture!;

    final requestFuture = requestCalendarData(switchCalendar: switchCalendar);
    loadingCalendarFuture = requestFuture;

    return requestFuture;
  }

  Future<void> requestCalendarData({Future<List<BangumiDetails>> Function()? switchCalendar}) async {
    debugPrint("timestamp: ${DateTime.now()} calendar start");

    try {
      if (switchCalendar != null) {
        final detailsList = await switchCalendar();
        debugPrint("timestamp: ${DateTime.now()} calendar get");

        calendarBangumis = searchDataAdapter(detailsList);
      }

      else {
        final response = await HttpApiClient.client.get(BangumiAPIUrls.calendar);
        debugPrint("timestamp: ${DateTime.now()} calendar get");

        calendarBangumis = loadCalendarData(response, animeFilter: true);
      }

      dataTime = DateTime.now();
      debugPrint("timestamp: $dataTime calendar done");

      notifyListeners();
    }

    catch (e) {
      loadingCalendarFuture = null;
      debugPrint("[CalendarModel] loadCalendar error: $e");
    }
  }

  void updateSelectedWeekDay(int newWeekDay) {
    selectedWeekDay = newWeekDay;
    notifyListeners();
  }

  void updateSeason(int year, SeasonType season) {
    selectedYear = year;
    selectedSeason = season;
    notifyListeners();
  }
}
