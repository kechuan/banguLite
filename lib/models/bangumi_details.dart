
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:bangu_lite/internal/convert.dart';

class BangumiDetails {

	int? id;
	String? coverUri;
	String? name;

	String? summary;
	Map<String,String> informationList = {};
	Map<String,int> tagsList = {};
	//  Map<String,dynamic> questionList = {};

	Map<String,num> ratingList = {
		"total": 0,
		"score": 0.0,
		"rank": 0.0,
	};

	Map<String,dynamic> epsInformationList = { 
      "airdate": "2024-11-30",
      "name": "知",
      "name_cn": "",
      "duration": "00:25:00",
      "desc": "ピャスト伯の死から数ヶ月――バデーニは膨大な観測記録を基に「地動説」の完成に没頭し、オクジーはヨレンタから文字を教わり自身の心境を綴るようになる。が、バデーニはオクジーのその行動に一切の価値を認めず、進まない研究に苛立ちを隠せずにいた。\r\n一方、同地区の教会では司教が異端審問官を増員し、いよいよ異端への弾圧を強めようとしていた。",
      "ep": 10,
      "sort": 10,
      "id": 1390988,
      "subject_id": 389156,
      "comment": 1,
      "type": 0,
      "disc": 0,
      "duration_seconds": 1500

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
              "rank": currentBangumi["rank"] ?? 0.0,
            };

			//debugPrint("date:${currentBangumi["date"]}");

            if(
				judgeInSeasonBangumi(currentBangumi["air_date"]) &&
				currentBangumi["rating"]["score"] > 7.0 && 
				currentBangumi["rating"]["total"] > 500
			){
              popularBangumis.add(bangumiDetails);
            }
          }

		  //rankBox 要素
		  /*
			"count": {
				"1": 3,
				"2": 1,
				...
				}
			*/
		//  "rankBox": currentBangumi["count"] ?? 0.0,

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
        "score": bangumiData["rating"]["score"] ?? 0,
        "rank": bangumiData["rating"]["rank"] ?? 0, //返回的是一个数值0
      };

	 //info collect

      bangumiDetails.informationList = {
        "eps":bangumiData["eps"].toString(),
        "alias":bangumiData["name_cn"].isNotEmpty ? bangumiData["name"] : "",
      };
	
      for(Map currentInformation in bangumiData["infobox"]){

        if(
			currentInformation["key"] != "放送星期" &&
			currentInformation["key"] != "放送开始"
		) continue;

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
		) break;


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
