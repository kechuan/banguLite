import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/topic_details.dart';
import 'package:bangu_lite/models/topic_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TopicModel extends ChangeNotifier{
  TopicModel({
    required this.subjectID
  }){
    loadSubjectTopics();
  }

  final int subjectID;

  final List<TopicInfo> topicInfoData = [];
  //final Map<int,TopicInfo> topicInfoData = {};

  // topicID => topicDetail
  final Map<int,TopicDetails> topicDetailData = {};  
  int topicsLength = 0;

  Future<void> loadSubjectTopics({int? offset = 0}) async {

    if(subjectID == 0) return;

    if(topicInfoData.isNotEmpty){
      debugPrint("topics already loaded");
      return;
    }

    try{

      await HttpApiClient.client.get(
        BangumiAPIUrls.topics(subjectID),
        queryParameters: 
          BangumiQuerys.topicsQuery..["offset"] = offset!
      ).then((response){
        if(response.data != null){
          topicsLength = response.data["total"] ?? 0;

          if(topicsLength == 0){
            debugPrint("subject $subjectID has no topics");
            topicInfoData.addAll([TopicInfo()..topicID = 0]);
            //topicInfoData.addAll({0:TopicInfo()});
          }

          else{
            topicInfoData.addAll(loadTopicsInfo(response));
          }

          notifyListeners();

        }


      });


    }

    on DioException catch(e){
      debugPrint("Request Error:${e.toString()}");
    }

  }

  Future<void> loadTopic(int topicID) async {

    if(topicID == 0) return;

    if(topicDetailData[topicID] != null){
      debugPrint("topic: $topicID already loaded or in processing");
      return;
    }

    //初始化占位
    topicDetailData.addAll({topicID:TopicDetails()});

    try{

      await HttpApiClient.client.get(
        BangumiAPIUrls.topicComment(topicID),
      ).then((response){
        if(response.data != null){
          topicDetailData.addAll({topicID:loadTopicDetails(response)});

          debugPrint("$topicID load topic done");
          
          notifyListeners();
        }

      });
    }

    on DioException catch(e){
      debugPrint("Request Error:${e.toString()}");
    }
  }


}