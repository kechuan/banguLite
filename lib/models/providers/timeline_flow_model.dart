import 'dart:async';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/timeline_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TimelineFlowModel extends ChangeNotifier {
  TimelineFlowModel();

  final Map<BangumiTimelineType,List<TimelineDetails>> timelinesData = {};

   //上滑 与 初次载入时触发
  Future<bool> requestSelectedTimeLineType(
    BangumiTimelineType timelineType,
    {
      Map<String,dynamic>? queryParameters,
      Function(String message)? fallbackAction,
    }

  ) async {

    Completer<bool> requestTimelineCompleter = Completer();

    late Future<List<Response<dynamic>>> Function() timelineFuture;
    

    if(timelineType == BangumiTimelineType.all){
      timelinesData.clear();
    }

    else{
      timelinesData.remove(timelineType);
    }

    

    switch(timelineType){
      case BangumiTimelineType.all:{
        timelineFuture = () => Future.wait(
          [
            HttpApiClient.client.get(BangumiAPIUrls.latestSubjectTopics()),
            HttpApiClient.client.get(
              BangumiAPIUrls.latestGroupTopics(),
              queryParameters: BangumiQuerys.groupsTopicsQuery()
            ),
            HttpApiClient.client.get(BangumiAPIUrls.timeline()),
          ]
        );
      }
        
      //不完整 缺失 Reviews/Blog 但没办法了
      case BangumiTimelineType.subject:{
        timelineFuture = () async {
          final response = await HttpApiClient.client.get(
            BangumiAPIUrls.latestSubjectTopics(),
          );

          return [response];
        
        };
      }
        
        
      case BangumiTimelineType.group:{

        timelineFuture = () async {
          final response = await HttpApiClient.client.get(
            BangumiAPIUrls.latestGroupTopics(),
            queryParameters: queryParameters ?? BangumiQuerys.groupsTopicsQuery()
          );

          return [response];

       };
      }
        
        
      case BangumiTimelineType.timeline:{
        timelineFuture = () async {
          final response = await HttpApiClient.client.get(
            BangumiAPIUrls.timeline(),
          );

          return [response];
        
        };
      }
       
    }

    await timelineFuture().then((response){

      for(var currentResponse in response) {
        if(currentResponse.statusCode == 200){

          timelinesData[timelineType] = loadTimelineDetails(currentResponse.data);

          // load Response Data
          //if(timelineType == BangumiTimelineType.all){
          //  timelinesData[timelineType] = loadTimelineDetails(currentResponse.data);
          //}

          //else{
          //  timelinesData[timelineType] = loadTimelineDetails(currentResponse.data);
          //}
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