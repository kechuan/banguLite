import 'dart:async';
import 'dart:io';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

//全局Model
class TimelineFlowModel extends ChangeNotifier {
  TimelineFlowModel();

  final Set<SurfTimelineDetails> timelinesData = {};

  final Set<SurfTimelineDetails> trendTimelinesData = {};

  Completer<bool>? requestTimelineCompleter;
  Completer<bool>? requestTrendTopicTimelineCompleter;

  // 上滑 或 初次载入时触发
  Future<bool> requestSelectedTimeLineType(
    BangumiSurfTimelineType timelineType,
    {
	    //bool? isAppend,
      List<Map<String,dynamic>>? queryParameters,
      Function(String message)? fallbackAction,
    }

  ) async {

    if(requestTimelineCompleter!=null) return requestTimelineCompleter!.future;
    requestTimelineCompleter = Completer();

    if(queryParameters == null){
      if(timelineType == BangumiSurfTimelineType.all){
        timelinesData.clear();
      }

      else{
        timelinesData.removeWhere(
          (currentTimeline)=>currentTimeline.bangumiSurfTimelineType == timelineType
        );
      }
      
    }

    //Completer<bool> requestTimelineCompleter = Completer();

    late Future<List<Response<dynamic>>> Function() timelineFuture;

    switch(timelineType){
      case BangumiSurfTimelineType.all:{
        timelineFuture = () => Future.wait(
          [
            HttpApiClient.client.get(
              BangumiAPIUrls.latestSubjectTopics(),
              queryParameters: queryParameters?.elementAtOrNull(0) ?? BangumiQuerys.topicsQuery
            ),
            HttpApiClient.client.get(
              BangumiAPIUrls.latestGroupTopics(),
              options: BangumiAPIUrls.bangumiAccessOption(),
              queryParameters: queryParameters?.elementAtOrNull(1) ?? BangumiQuerys.groupsTopicsQuery()
            ),
            HttpApiClient.client.get(
              BangumiAPIUrls.timeline(),
              options: BangumiAPIUrls.bangumiAccessOption(),
              queryParameters: queryParameters?.elementAtOrNull(2) ?? BangumiQuerys.timelineQuery()
            ),
          ]
        );
      }
        
      //不完整 缺失 Reviews/Blog 但没办法了
      case BangumiSurfTimelineType.subject:{
        timelineFuture = () async {
          final response = await HttpApiClient.client.get(
            BangumiAPIUrls.latestSubjectTopics(),
            queryParameters: queryParameters?.elementAtOrNull(0) ?? BangumiQuerys.topicsQuery
            
          );

          return [response];
        
        };
      }
        
      case BangumiSurfTimelineType.group:{

        timelineFuture = () async {
          final response = await HttpApiClient.client.get(
            BangumiAPIUrls.latestGroupTopics(),
            queryParameters: queryParameters?.elementAtOrNull(0) ?? BangumiQuerys.groupsTopicsQuery(),
            options: BangumiAPIUrls.bangumiAccessOption(),
          );

          return [response];

       };
      }
        
      case BangumiSurfTimelineType.timeline:{
        timelineFuture = () async {
          final response = await HttpApiClient.client.get(
            BangumiAPIUrls.timeline(),
            options: BangumiAPIUrls.bangumiAccessOption(),
            queryParameters: queryParameters?.elementAtOrNull(0) ?? BangumiQuerys.timelineQuery()
          );

          return [response];
        
        };
      }
       
    }

    await timelineFuture().then(
      (response){

        bool emptyResponseFlag = false;

        for(int responseIndex = 0; responseIndex < response.length; responseIndex++){
          if(response[responseIndex].statusCode == HttpStatus.ok){

            dynamic extractResponseData = 
              response[responseIndex].requestOptions.path.contains(BangumiAPIUrls.timeline()) ?
              response[responseIndex].data :
              response[responseIndex].data["data"]
            ;

            //数据返回为空——指定的时间线ID返回被服务器清空
            if(response[responseIndex].data.isEmpty){ 
              fallbackAction?.call(
                "请求 ${response[responseIndex].requestOptions.path} 失败" 
                " ${response[responseIndex].statusCode} ${response[responseIndex].data["message"]}"
              );
              emptyResponseFlag = true;
            }


            timelinesData.addAll(
              loadSurfTimelineDetails(
                extractResponseData,
                bangumiSurfTimelineType: 
                  timelineType == BangumiSurfTimelineType.all ?
                  BangumiSurfTimelineType.values[responseIndex+1] :
                  timelineType,

              )
            );
             
          }

          else{
            requestTimelineCompleter!.complete(false);
          }

         
        }

        if(emptyResponseFlag == true){
          requestTimelineCompleter!.complete(false);
          return;
        }

      notifyListeners();
      requestTimelineCompleter!.complete(true);
        
    });

    return requestTimelineCompleter!.future;
    
  }

  Future<bool> requestTrendTopicTimeline(
    {
      Map<String,dynamic>? queryParameters,
      Function(String message)? fallbackAction,
    }
  ) async {

    if(requestTrendTopicTimelineCompleter!=null) return requestTrendTopicTimelineCompleter!.future;
    requestTrendTopicTimelineCompleter = Completer();

    try {
      await HttpApiClient.client.get(
        BangumiAPIUrls.trendTopics(),
        queryParameters: queryParameters ?? BangumiQuerys.trendTopicQuery,
        
      ).then((response){

        if(response.statusCode == HttpStatus.ok){

          if(queryParameters == null) trendTimelinesData.clear();

          trendTimelinesData.addAll(
            loadSurfTimelineDetails(
              response.data["data"],
              //趋势话题里面都是subjectTopic
              bangumiSurfTimelineType: BangumiSurfTimelineType.subject
            )
          );

		  requestTrendTopicTimelineCompleter?.complete(true);
          

        }

        
      });
    }

    on DioException catch(e){
      debugPrint("[TrendTopics] ${e.response?.statusCode} error:${e.response?.data["message"]}");
      fallbackAction?.call('${e.response?.statusCode} ${e.response?.data["message"]}');
      return false;
    }

    return requestTrendTopicTimelineCompleter!.future;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

 

}