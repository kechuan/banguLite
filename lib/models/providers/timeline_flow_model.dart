import 'dart:async';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

//全局Model
class TimelineFlowModel extends ChangeNotifier {
  TimelineFlowModel();

  final Map<BangumiTimelineType,List<SurfTimelineDetails>> timelinesData = {
    BangumiTimelineType.all: [],
    BangumiTimelineType.subject: [],
    BangumiTimelineType.group: [],
    BangumiTimelineType.timeline: [],
  };

   //上滑 或 初次载入时触发
  Future<bool> requestSelectedTimeLineType(
    BangumiTimelineType timelineType,
    {
	    bool? isAppend,
      Map<String,dynamic>? queryParameters,
      Function(String message)? fallbackAction,
    }

  ) async {

    if(isAppend != true){
      timelinesData[timelineType] = [];
    }

    Completer<bool> requestTimelineCompleter = Completer();

    late Future<List<Response<dynamic>>> Function() timelineFuture;

    switch(timelineType){
      case BangumiTimelineType.all:{
        timelineFuture = () => Future.wait(
          [
            HttpApiClient.client.get(
              BangumiAPIUrls.latestSubjectTopics(),
              queryParameters: BangumiQuerys.groupTopicQuery
            ),
            HttpApiClient.client.get(
              BangumiAPIUrls.latestGroupTopics(),
              options: BangumiAPIUrls.bangumiAccessOption,
              queryParameters: BangumiQuerys.groupsTopicsQuery(),
            ),
            HttpApiClient.client.get(
              BangumiAPIUrls.timeline(),
              queryParameters:BangumiQuerys.timelineQuery
            ),
          ]
        );
      }
        
      //不完整 缺失 Reviews/Blog 但没办法了
      case BangumiTimelineType.subject:{
        timelineFuture = () async {
          final response = await HttpApiClient.client.get(
            BangumiAPIUrls.latestSubjectTopics(),
            queryParameters: queryParameters
          );

          return [response];
        
        };
      }
        
      case BangumiTimelineType.group:{

        timelineFuture = () async {
          final response = await HttpApiClient.client.get(
            BangumiAPIUrls.latestGroupTopics(),
            queryParameters: queryParameters ?? BangumiQuerys.groupsTopicsQuery(),
            options: BangumiAPIUrls.bangumiAccessOption,
          );

          return [response];

       };
      }
        
        
      case BangumiTimelineType.timeline:{
        timelineFuture = () async {
          final response = await HttpApiClient.client.get(
            BangumiAPIUrls.timeline(),
            queryParameters: queryParameters ?? BangumiQuerys.timelineQuery
          );

          return [response];
        
        };
      }
       
    }

    await timelineFuture().then(
      (response){

      if(response.length>1){

        for(int responseIndex = 0; responseIndex < response.length; responseIndex++){
          if(response[responseIndex].statusCode == 200){

            dynamic extractResponseData = 
              responseIndex != response.length-1 ?
              response[responseIndex].data["data"] :
              response[responseIndex].data ;


            timelinesData[BangumiTimelineType.values[responseIndex+1]] = loadSurfTimelineDetails(
              extractResponseData,
              bangumiTimelineType: BangumiTimelineType.values[responseIndex+1]
            );
          }

          else{
            requestTimelineCompleter.complete(false);
          }
        }

        timelinesData[BangumiTimelineType.all]!.addAll(
          timelinesData[BangumiTimelineType.subject]! +
          timelinesData[BangumiTimelineType.group]! +

          //对于Timeline类型 则需筛选无Comment数据 
          //这也导致 数据并不完整 不打算实现onLoad逻辑 只实现onRefresh逻辑
          timelinesData[BangumiTimelineType.timeline]!.where((currentTimeline){
            return currentTimeline.commentDetails?.comment != null;
          }).toList()
        );

        timelinesData[BangumiTimelineType.all]!.sort(
          (prev,next) => next.updatedAt?.compareTo(prev.updatedAt ?? 0) ?? 0
        );
      }

      else{

        if(response[0].statusCode != 200){
          fallbackAction?.call("请求失败 ${response[0].statusCode} ${response[0].data["message"]}");
          requestTimelineCompleter.complete(false);
          return;
        }

        dynamic extractResponseData = 
          timelineType != BangumiTimelineType.timeline ?
          response[0].data["data"] :
          response[0].data 
        ;

        if(isAppend == true){
          timelinesData[timelineType]?.addAll(
            loadSurfTimelineDetails(
            extractResponseData,
            bangumiTimelineType: timelineType
          ));
        }

        else{
          timelinesData[timelineType] = loadSurfTimelineDetails(
            extractResponseData,
            bangumiTimelineType: timelineType
          );
        }
        
      }


      notifyListeners();
      requestTimelineCompleter.complete(true);
        
    });

    return requestTimelineCompleter.future;
    
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

 

}