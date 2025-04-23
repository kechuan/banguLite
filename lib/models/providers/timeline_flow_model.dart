import 'dart:async';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/surf_timeline_details.dart';
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
              queryParameters: queryParameters ?? BangumiQuerys.groupsTopicsQuery()
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

        // (skip)all /subject / groups / timeline

        if(response.length>1){
          for(int responseIndex = 0; responseIndex < response.length; responseIndex++){
            if(response[responseIndex].statusCode == 200){
              timelinesData[BangumiTimelineType.values[responseIndex+1]] = loadSurfTimelineDetails(
                response[responseIndex].data,
                bangumiTimelineType: BangumiTimelineType.values[responseIndex+1]
              );
            }
          }
        }

        else{

          if(timelineType != BangumiTimelineType.timeline){
            timelinesData[timelineType] = loadSurfTimelineDetails(
              response[0].data["data"],
              bangumiTimelineType: timelineType
            );
          }

          else{
            timelinesData[timelineType] = loadSurfTimelineDetails(
              response[0].data,
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