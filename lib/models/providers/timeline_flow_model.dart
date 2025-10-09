import 'dart:async';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

//全局Model
class TimelineFlowModel extends ChangeNotifier {
  TimelineFlowModel();

  final Map<BangumiSurfTimelineType,List<SurfTimelineDetails>> timelinesData = {
    BangumiSurfTimelineType.all: [],
    BangumiSurfTimelineType.subject: [],
    BangumiSurfTimelineType.group: [],
    BangumiSurfTimelineType.timeline: [],
  };

   //上滑 或 初次载入时触发
  Future<bool> requestSelectedTimeLineType(
    BangumiSurfTimelineType timelineType,
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
      case BangumiSurfTimelineType.all:{
        timelineFuture = () => Future.wait(
          [
            HttpApiClient.client.get(
              BangumiAPIUrls.latestSubjectTopics(),
              queryParameters: BangumiQuerys.groupTopicQuery
            ),
            HttpApiClient.client.get(
              BangumiAPIUrls.latestGroupTopics(),
              options: BangumiAPIUrls.bangumiAccessOption(),
              queryParameters: BangumiQuerys.groupsTopicsQuery(),
            ),
            HttpApiClient.client.get(
              BangumiAPIUrls.timeline(),
              options: BangumiAPIUrls.bangumiAccessOption(),
              queryParameters:BangumiQuerys.timelineQuery()
            ),
          ]
        );
      }
        
      //不完整 缺失 Reviews/Blog 但没办法了
      case BangumiSurfTimelineType.subject:{
        timelineFuture = () async {
          final response = await HttpApiClient.client.get(
            BangumiAPIUrls.latestSubjectTopics(),
            queryParameters: queryParameters
          );

          return [response];
        
        };
      }
        
      case BangumiSurfTimelineType.group:{

        timelineFuture = () async {
          final response = await HttpApiClient.client.get(
            BangumiAPIUrls.latestGroupTopics(),
            queryParameters: queryParameters ?? BangumiQuerys.groupsTopicsQuery(),
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
            queryParameters: queryParameters ?? BangumiQuerys.timelineQuery()
          );

          return [response];
        
        };
      }
       
    }

    await timelineFuture().then(
      (response){
      
      //All状态
      if(response.length>1){
        
        for(int responseIndex = 0; responseIndex < response.length; responseIndex++){
          if(response[responseIndex].statusCode == 200){

            dynamic extractResponseData = 
              responseIndex != response.length-1 ?
              response[responseIndex].data["data"] :
              response[responseIndex].data ;

            //数据返回为空——指定的时间线ID返回被服务器清空
            if(response[responseIndex].data.isEmpty){ 
              
              requestTimelineCompleter.complete(false);
              return;
            }


            timelinesData[BangumiSurfTimelineType.values[responseIndex+1]] = loadSurfTimelineDetails(
              extractResponseData,
              bangumiSurfTimelineType: BangumiSurfTimelineType.values[responseIndex+1]
            );
          }

          else{
            requestTimelineCompleter.complete(false);
          }
        }

        //新数据合并环节

        if(isAppend == true){
          for( int index = BangumiSurfTimelineType.subject.index ; index < BangumiSurfTimelineType.values.length; index++){
            //新获得的数据的最慢ID如果存在于All列表内 则不应该进行任何处理
            if(timelinesData[BangumiSurfTimelineType.all]!.any((element)=>element.detailID == timelinesData.values.elementAt(index).last.detailID)){
              continue;
            }

            else{
              //否则开始以最末尾的数据开始进行合并 如果寻找到数据 则从这个下标开始合并数据
              int combineIndex = timelinesData.values.elementAt(index).indexWhere(
                (element)=> timelinesData[BangumiSurfTimelineType.all]!.any((allListElement)=>allListElement.detailID == element.detailID)
              );

              if(combineIndex != -1){
                timelinesData[BangumiSurfTimelineType.all]!.addAll(
                  timelinesData.values.elementAt(index).skip(combineIndex-1)
                );
              }

              else{

                timelinesData[BangumiSurfTimelineType.all]!.addAll(
                  index == BangumiSurfTimelineType.timeline.index ?
                  timelinesData[BangumiSurfTimelineType.timeline]!.where((currentTimeline){
                    return currentTimeline.commentDetails?.comment != null;
                  }).toList() :
                  timelinesData.values.elementAt(index)
                );

               
                
              }

            }
 
          }

        }

        //否则直接允许覆盖
        else{
          timelinesData[BangumiSurfTimelineType.all]!.addAll(
            timelinesData[BangumiSurfTimelineType.subject]! +
            timelinesData[BangumiSurfTimelineType.group]! +

            //对于Timeline类型 则需筛选无Comment数据 
            //这也导致 数据并不完整 不打算实现onLoad逻辑 只实现onRefresh逻辑
            timelinesData[BangumiSurfTimelineType.timeline]!.where((currentTimeline){
              return currentTimeline.commentDetails?.comment != null;
            }).toList()
          );
        }

        timelinesData[BangumiSurfTimelineType.all]!.sort(
          (prev,next) => next.updatedAt?.compareTo(prev.updatedAt ?? 0) ?? 0
        );
      }

      //单个项目
      else{

        if(response[0].statusCode != 200){
          fallbackAction?.call("请求失败 ${response[0].statusCode} ${response[0].data["message"]}");
          requestTimelineCompleter.complete(false);
          return;
        }

        dynamic extractResponseData = 
          timelineType != BangumiSurfTimelineType.timeline ?
          response[0].data["data"] :
          response[0].data 
        ;

        if(isAppend == true){
          timelinesData[timelineType]?.addAll(
            loadSurfTimelineDetails(
				extractResponseData,
				bangumiSurfTimelineType: timelineType
			));
        }

        else{
          timelinesData[timelineType] = loadSurfTimelineDetails(
            extractResponseData,
            bangumiSurfTimelineType: timelineType
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