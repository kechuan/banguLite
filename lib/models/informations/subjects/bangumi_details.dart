
import 'dart:async';
import 'dart:math';

import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/models/informations/local/star_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/judge_condition.dart';

const excludeTagsList = [
  "日本","TV","WEB"
];

///打开 subjectID 之后对应的details信息返回
class BangumiDetails {

	int? id;
  int? type;
  
	String? coverUrl;
	String? name;

	String? summary;
	Map<String,dynamic> informationList = {};
	Map<String,int> tagsList = {};

	Map<String,dynamic> ratingList = {
		"total": 0,
		"score": 0.0,
		"rank": 0.0,
    "count":{}
	};

}

Map<String,List<BangumiDetails>> loadCalendarData(Response bangumiCalendarResponse,{bool? animeFilter}){

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

          if(animeFilter==true){
            if(!animationFilter(currentBangumi)) continue;
          }

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


List<BangumiDetails> loadSearchData(Map<String,dynamic> bangumiData,{bool? animateFilter}){

  List<BangumiDetails> searchResult = [];

  List<dynamic> bangumiList = bangumiData["data"];

    for(Map currentBangumi in bangumiList){

      if(animateFilter==true){
        if(!animationFilter(currentBangumi)){
           continue;
        }
      }

      BangumiDetails bangumiDetail = BangumiDetails();

      bangumiDetail.name = currentBangumi["name_cn"].isEmpty ? currentBangumi["name"] : currentBangumi["name_cn"];
      bangumiDetail.id = currentBangumi["id"];
      bangumiDetail.coverUrl = currentBangumi["image"];

      //仅用于 搜索页面 的 tag 展现 
      for(String currentTagName in currentBangumi["meta_tags"]){
        if(!excludeTagsList.contains(currentTagName)){
          bangumiDetail.tagsList.addAll({
            currentTagName : 0
          });
        }
      }

      bangumiDetail.informationList = {
        "air_date": currentBangumi["date"],
        "eps": currentBangumi["eps"]
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

Map<String,List<BangumiDetails>> searchDataAdapter(
  List<BangumiDetails> bangumiSearchDetailsList,
){

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

    if(weekday != 0){
      searchWeekList.values.elementAt(weekday-1).add(currentBangumi);
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

    bangumiDetails.name = convertAmpsSymbol(
      (bangumiData["nameCN"] ?? bangumiData["name_cn"]).isNotEmpty ? 
      (bangumiData["nameCN"] ?? bangumiData["name_cn"]) : 
      bangumiData["name"]
    );

    bangumiDetails.id = bangumiData["id"];
    bangumiDetails.type = bangumiData["type"];

    bangumiDetails.ratingList = {
      "rank": bangumiData["rating"]?["rank"] ?? 0, //返回的是一个数值0
      "total": bangumiData["rating"]?["total"] ?? 0,
      "score": bangumiData["rating"]?["score"] ?? 0.0,

      // v0 v1的数据返回不同 
      // v0(主页信息) 为倒序map v0 实际信息 却是正序map
      // v1(relation信息)则是正序List
      "count": convertRankList(bangumiData["rating"]?["count"] ?? [])

    };


      bangumiDetails.informationList = {
        "air_date":bangumiData["air_date"],
        "air_weekday":'星期${WeekDay.values.elementAtOrNull((bangumiData["air_weekday"] ?? 1)-1)?.dayText}',
        "alias":bangumiData["name"],
      };
    

	 //info collect

   if(detailFlag){
      bangumiDetails.informationList = {
        //"eps":bangumiData["eps"] == 0 ? bangumiData["total_episodes"] : bangumiData["eps"],
        "eps":bangumiData["total_episodes"],
        "alias":bangumiData["name_cn"].isNotEmpty ? bangumiData["name"] : "",
        "air_date": bangumiData["date"].toString()
      };
	
      for(Map currentInformation in bangumiData["infobox"]){

        if(
          currentInformation["key"] != "放送星期" &&
          currentInformation["key"] != "放送开始"
        ) {
          continue;
        }

        switch(currentInformation["key"]){

          case "放送星期": {
            bangumiDetails.informationList.addAll({
              "air_weekday": currentInformation["value"].toString()
            });

            break;
          }
        }

        if(bangumiDetails.informationList["air_weekday"] != null) break;


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

BangumiDetails loadRelationsData(Map<String,dynamic> bangumiData){
  final BangumiDetails bangumiDetails = BangumiDetails();

    bangumiDetails.coverUrl = bangumiData["images"]?["large"];
    bangumiDetails.name = bangumiData["nameCN"].isNotEmpty ? bangumiData["nameCN"] : bangumiData["name"];
    bangumiDetails.id = bangumiData["id"];
    bangumiDetails.type = bangumiData["type"];

    bangumiDetails.ratingList = {
      "total": bangumiData["rating"]?["total"] ?? 0,
      "score": bangumiData["rating"]?["score"] ?? 0.0,
      "rank": bangumiData["rating"]?["rank"] ?? 0, //返回的是一个数值0
      "count": convertRankList(bangumiData["rating"]?["count"] ?? [])
    };

  return bangumiDetails;
}

BangumiDetails loadStarDetailsData(StarBangumiDetails starBangumiData){
  final BangumiDetails bangumiDetails = BangumiDetails();

    bangumiDetails
      ..id = starBangumiData.bangumiID
      ..name = starBangumiData.name
      ..coverUrl = starBangumiData.coverUrl
      
    ;

    bangumiDetails.ratingList = {
      "total": 0,
      "score": starBangumiData.score,
      "rank": starBangumiData.rank,
      "count": 0
    };

    bangumiDetails.informationList = {
      "eps":starBangumiData.eps,
      "air_date": starBangumiData.airDate
    };

  return bangumiDetails;
}


bool animationFilter(Map currentBangumi){

  //calendar 数据不包含 ["tags"]
  if(currentBangumi["tags"] == null){
    return true;
  }

  if(
    currentBangumi["name_cn"].isEmpty ||
    currentBangumi["tags"].any((currentTag) => notAnimeFilterTag.contains(currentTag["name"])) ||
    currentBangumi["tags"].length < 6
  ){
    //debugPrint("[Denied]: ${currentBangumi["name"]}");
    return false;
  }

  else{
    //debugPrint("[Allow]: ${currentBangumi["name"]}");
    return true;
  }

  
}

//获取 收藏 番剧的信息 以后可能需要分批次请求。。 以免出现429错误
Future<Map<int,Map<String,num>>> loadStarsDetail(List<int> starsIDList) async {

  Completer<Map<int,Map<String,num>>> starUpdateCompleter = Completer();

  int completeFlag = starsIDList.length;

  final resultRating = {
    for(int bangumiID in starsIDList)
      bangumiID:{
        "score":0.0,
        "rank":0
      }
  };


  await Future.wait(
    List.generate(
      starsIDList.length,
      (index) async {
        await HttpApiClient.client.get("${BangumiAPIUrls.subject}/${starsIDList[index]}").then((response){
          final ratingList = loadDetailsData(response.data).ratingList;

          resultRating.values.elementAt(index)["score"] = ratingList["score"];
          resultRating.values.elementAt(index)["rank"] = ratingList["rank"];

          completeFlag -= 1;
          if(completeFlag==0) starUpdateCompleter.complete(resultRating);
        });
      }
      )
  );

  return starUpdateCompleter.future;

}

