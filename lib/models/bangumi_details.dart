
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:bangu_lite/internal/convert.dart';

class BangumiDetails {

	int? id;
	String? coverUri;
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
    List<BangumiDetails> popularBangumis = [];

    //理论来说 你只需要获取id/coverUrl/name就足够了
    if(bangumiCalendarResponse.data!=null){

      List<dynamic> calendarData = bangumiCalendarResponse.data;

      for(Map currentDayBangumis in calendarData){
        //debugPrint("timestamp: outside ${currentDayBangumis.runtimeType}");

        List<BangumiDetails> weekdayBangumis = [];
        
        List todayBangumis = currentDayBangumis["items"];

        for(Map currentBangumi in todayBangumis){

          //debugPrint("timestamp: inside ${currentBangumi.runtimeType}");

          BangumiDetails bangumiDetails = BangumiDetails();

          //debugPrint("bangumi name: ${currentBangumi["name_cn"].isEmpty ? currentBangumi["name"] : currentBangumi["name_cn"]}");

          if(animeFliter!=null && animeFliter==true){
            if(currentBangumi["name_cn"] == "") continue;
          }

          bangumiDetails.coverUri = currentBangumi["images"]["large"];
          bangumiDetails.id = currentBangumi["id"];

          bangumiDetails.name = currentBangumi["name_cn"].isEmpty ?
           currentBangumi["name"] :
           currentBangumi["name_cn"] ?? "暂无名称";

          //前端处理法
          bangumiDetails.name = convertAmpsSymbol(bangumiDetails.name);

          if(currentBangumi["rating"]!=null){
            bangumiDetails.ratingList = {
              "total": currentBangumi["rating"]["total"],
              "score": currentBangumi["rating"]["score"],
              "rank": currentBangumi["rank"] ?? 0,
              "count":currentBangumi["rating"]["count"]
            };

			

            if(
              judgeInSeasonBangumi(currentBangumi["air_date"]) &&
              currentBangumi["rating"]["score"] > 7.0 && 
              currentBangumi["rating"]["total"] > 500
            ){
               popularBangumis.add(bangumiDetails);
            }
          }


          weekdayBangumis.add(bangumiDetails);

        }

        //debugPrint("${currentDayBangumis["weekday"]["cn"]}: ${weekdayBangumis.length} ");

        weekCalender.addAll({
          currentDayBangumis["weekday"]["cn"]:weekdayBangumis //星期X: 当日番剧添加
        });

        
        
      }

      weekCalender.addAll({
        "最热门":popularBangumis
      });

      //debugPrint("timestamp calendar done:${weekCalender.length}");

    }

    return weekCalender;
  }


BangumiDetails loadDetailsData(Response bangumiDetailResponse) {

    Map<String,dynamic> bangumiData = bangumiDetailResponse.data;

    //debugPrint("currentBangumiData: ${bangumiData}");

    final BangumiDetails bangumiDetails = BangumiDetails();

      bangumiDetails.coverUri = bangumiData["images"]["large"];
      bangumiDetails.summary = bangumiData["summary"];
      bangumiDetails.name = bangumiData["name_cn"].isNotEmpty ? bangumiData["name_cn"] : bangumiData["name"];
      bangumiDetails.id = bangumiData["id"];

    //  debugPrint("rating:${bangumiData["rating"]["total"]}");

      bangumiDetails.ratingList = {
        "total": bangumiData["rating"]["total"] ?? 0,
        "score": bangumiData["rating"]["score"] ?? 0.0,
        "rank": bangumiData["rating"]["rank"] ?? 0, //返回的是一个数值0
        "count":bangumiData["rating"]["count"] ?? {}
      };

	 //info collect

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

      debugPrint("bangumiDetails.informationList:${bangumiDetails.informationList}");

      debugPrint("model parse done:${DateTime.now()}. reloadInformation");

    return bangumiDetails;
  }
