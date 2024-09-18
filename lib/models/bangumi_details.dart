
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bangumi/internal/convert.dart';

class BangumiDetails {

  int? id;
  String? coverUri;
  String? name;

  String? summary;
  Map<String,String> informationList = {};
  Map<String,int> tagsList = {};
  Map<String,dynamic> questionList = {};
  Map<String,num> ratingList = {};
  
  //recommand by ep

  static BangumiDetails loadDetailsData(Response bangumiDetailResponse) {

    Map<String,dynamic> bangumiData = bangumiDetailResponse.data;
    final BangumiDetails bangumiDetails = BangumiDetails();

      bangumiDetails.coverUri = bangumiData["images"]["large"];
      bangumiDetails.summary = bangumiData["summary"];

      bangumiDetails.name = bangumiData["name_cn"].isNotEmpty ? bangumiData["name_cn"] : bangumiData["name"];
      bangumiDetails.id = bangumiData["id"];

      debugPrint("rating:${bangumiData["rating"]["total"]}");

      bangumiDetails.ratingList = {
        "total": bangumiData["rating"]["total"] ?? 0,
        "score": bangumiData["rating"]["score"] ?? 0,
        "rank": bangumiData["rating"]["rank"], //返回的是一个数值0
      };

      bangumiDetails.informationList = {
        "eps":bangumiData["eps"].toString(),
        "alias":bangumiData["name_cn"].isNotEmpty ? bangumiData["name"] : "",
      };

      for(Map currentInfoMation in bangumiData["infobox"]){
        if(currentInfoMation["key"] != "放送星期") continue;
        if(currentInfoMation["key"] == "放送星期"){
          bangumiDetails.informationList.addAll({
            "air_weekday": currentInfoMation["value"].toString()
          });
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

  //期望获取的是每日的所有番剧 然后加个遮罩 背景cover 前置显示name/Rank
  static Map<String,List<BangumiDetails>> loadCalendarData(Response bangumiCalendarResponse,{bool? animeFliter}){

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
          bangumiDetails.name = convertAmps(bangumiDetails.name);

          if(currentBangumi["rating"]!=null){
            bangumiDetails.ratingList = {
              "total": currentBangumi["rating"]["total"],
              "score": currentBangumi["rating"]["score"],
              "rank": currentBangumi["rank"] ?? 0.0,
            };

            if(currentBangumi["rating"]["score"] > 7.0 && currentBangumi["rating"]["total"] > 500){
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

}

//设想 Map追加最后一列 高人气: 实际上则是把评分高于某个阈值(8.0)添加进去 直到15个为止 如不满则放宽(7.5)
