
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:bangu_lite/internal/judge_condition.dart';

///打开 subjectID 之后对应的details信息返回
class BangumiDetails {

	int? id;
  int? type;
	String? coverUrl;
	String? name;

	String? summary;
	Map<String,dynamic> informationList = {};
	Map<String,int> tagsList = {};
	//  Map<String,dynamic> questionList = {};

	Map<String,dynamic> ratingList = {
		"total": 0,
		"score": 0.0,
		"rank": 0.0,
    "count":{
      "1": 0,
      "2": 0,
      "3": 0,
      "4": 0,
      "5": 0,
      "6": 0,
      "7": 0,
      "8": 0,
      "9": 0,
      "10": 0
    }
	};


}

Map<String,List<BangumiDetails>> loadCalendarData(Response bangumiCalendarResponse,{bool? animeFliter}){

    Map<String,List<BangumiDetails>> weekCalender = {};
    List<BangumiDetails> popularInSeasonBangumis = [];

    if(bangumiCalendarResponse.data!=null){

      List<dynamic> calendarData = bangumiCalendarResponse.data;

      for(Map currentDayBangumis in calendarData){
        //debugPrint("timestamp: outside ${currentDayBangumis.runtimeType}");

        List<BangumiDetails> weekdayBangumis = [];
        
        List currentDayBangumiList = currentDayBangumis["items"];

        for(Map<String,dynamic> currentBangumi in currentDayBangumiList){

          BangumiDetails bangumiDetails = BangumiDetails();

          bangumiDetails = loadDetailsData(currentBangumi);

          if(
            judgeInSeasonBangumi(currentBangumi["air_date"]) &&
            bangumiDetails.ratingList["score"] > 7.0 && 
            bangumiDetails.ratingList["total"] > (judgeTransitionalSeason() ? 10 : 25)
          ){
              popularInSeasonBangumis.add(bangumiDetails);
          }

          weekdayBangumis.add(bangumiDetails);

        }

        //debugPrint("${currentDayBangumis["weekday"]["cn"]}: ${weekdayBangumis.length} ");

        weekCalender.addAll({
          currentDayBangumis["weekday"]["cn"]:weekdayBangumis //星期X: 当日番剧添加
        });
        
      }

      weekCalender.addAll({
        "最热门":popularInSeasonBangumis
      });

      //debugPrint("timestamp calendar done:${weekCalender.length}");

    }

    return weekCalender;
  }

List<BangumiDetails> loadSearchData(Map<String,dynamic> bangumiData){

  List<BangumiDetails> searchResult = [];

  List<dynamic> bangumiList = bangumiData["data"];

    for(Map currentBangumi in bangumiList){
      BangumiDetails bangumiDetail = BangumiDetails();

      bangumiDetail.name = currentBangumi["name_cn"].isEmpty ? currentBangumi["name"] : currentBangumi["name_cn"];
      bangumiDetail.id = currentBangumi["id"];
      bangumiDetail.coverUrl = currentBangumi["image"];
      bangumiDetail.informationList = {
        "air_date": currentBangumi["date"]
      };

      bangumiDetail.ratingList = {
        "total": currentBangumi["rating"]["total"] ?? 0,
        "score": currentBangumi["rating"]["score"] ?? 0,
        "rank": currentBangumi["rating"]["rank"] ?? 0, //返回的是一个数值0
      };

      searchResult.add(bangumiDetail);
    }

  return searchResult;

}

Map<String,List<BangumiDetails>> searchDataAdapter(List<BangumiDetails> bangumiSearchDetailsList){

  final Map<String,List<BangumiDetails>> searchWeekList = {
    "星期一":[],
    "星期二":[],
    "星期三":[],
    "星期四":[],
    "星期五":[],
    "星期六":[],
    "星期日":[],
    "最热门":[]
  };


  for(BangumiDetails currentBangumi in bangumiSearchDetailsList){
    
    
  int weekday = DateTime.tryParse(currentBangumi.informationList["air_date"] ?? "")?.weekday ?? 0;

    switch(weekday){
      case 1: {searchWeekList["星期一"]!.add(currentBangumi);break;}
      case 2: {searchWeekList["星期二"]!.add(currentBangumi);break;}
      case 3: {searchWeekList["星期三"]!.add(currentBangumi);break;}
      case 4: {searchWeekList["星期四"]!.add(currentBangumi);break;}
      case 5: {searchWeekList["星期五"]!.add(currentBangumi);break;}
      case 6: {searchWeekList["星期六"]!.add(currentBangumi);break;}
      case 7: {searchWeekList["星期日"]!.add(currentBangumi);break;}
      default: break;
    }

    if(
      currentBangumi.ratingList["score"] > 7.0 && 
      currentBangumi.ratingList["total"] > 500
      )
    {
      searchWeekList["最热门"]!.add(currentBangumi);
    }
    

  }


  return searchWeekList;

}

BangumiDetails loadDetailsData(Map<String,dynamic> bangumiData,{bool detailFlag = false}) {

    final BangumiDetails bangumiDetails = BangumiDetails();

    bangumiDetails.coverUrl = bangumiData["images"]?["large"];
    bangumiDetails.summary = bangumiData["summary"];
    bangumiDetails.name = bangumiData["name_cn"].isNotEmpty ? bangumiData["name_cn"] : bangumiData["name"];
    bangumiDetails.id = bangumiData["id"];
    bangumiDetails.type = bangumiData["type"];

    bangumiDetails.ratingList = {
      "total": bangumiData["rating"]?["total"] ?? 0,
      "score": bangumiData["rating"]?["score"] ?? 0.0,
      "rank": bangumiData["rating"]?["rank"] ?? 0, //返回的是一个数值0
      "count": bangumiData["rating"]?["count"] ?? {}
    };

	 //info collect

   if(detailFlag){
      bangumiDetails.informationList = {
        "eps":bangumiData["eps"] == 0 ? bangumiData["total_episodes"] : bangumiData["eps"],
        "alias":bangumiData["name_cn"].isNotEmpty ? bangumiData["name"] : "",
      };
	
      for(Map currentInformation in bangumiData["infobox"]){

        if(
          currentInformation["key"] != "放送星期" &&
          currentInformation["key"] != "放送开始"
        ) {
          continue;
        }

        switch(currentInformation["key"]){
          case "放送开始": {
            bangumiDetails.informationList.addAll({
              "air_date": bangumiData["date"].toString()
            });
            break;
          }

          case "放送星期": {
            bangumiDetails.informationList.addAll({
              "air_weekday": currentInformation["value"].toString()
            });
            break;
          }
        }

        if(
          bangumiDetails.informationList["air_date"] != null && 
          bangumiDetails.informationList["air_weekday"] != null
        ) {
          break;
        }


      }

      debugPrint("${bangumiData["name_cn"]} => ${bangumiData["name"]}");


      for(int tagIndex = 0; tagIndex<min(8,bangumiData["tags"].length); tagIndex++){
        bangumiDetails.tagsList.addAll({
          bangumiData["tags"][tagIndex]["name"].toString():bangumiData["tags"][tagIndex]["count"]
        });
      }
   }

      

    //debugPrint("bangumiDetails.informationList:${bangumiDetails.informationList}");

    //debugPrint("model parse done:${DateTime.now()}. reloadInformation");

    return bangumiDetails;
  }




enum SubjectType {
  book(1), // 书籍
  anime(2), // 动画
  music(3), // 音乐
  game(4), // 游戏
  real(6); // 三次元

  final int subjectType;

  const SubjectType(this.subjectType);
}
