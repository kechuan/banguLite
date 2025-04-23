import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/extract.dart';
import 'package:bangu_lite/models/base_details.dart';
import 'package:bangu_lite/models/comment_details.dart';
import 'package:bangu_lite/models/group_details.dart';
import 'package:bangu_lite/models/group_topic_details.dart';
import 'package:bangu_lite/models/group_topic_info.dart';
import 'package:bangu_lite/models/timeline_details.dart';
import 'package:bangu_lite/models/topic_info.dart';
import 'package:bangu_lite/models/user_details.dart';

class SurfTimelineDetails extends BaseDetails {
  SurfTimelineDetails({
    super.detailID
  });

  CommentDetails? commentDetails;

  String? title;
  
  BangumiTimelineType? bangumiTimelineType;
  String? sourceTitle; // Subject&Group
  int? sourceID;
  
  int? replies;
  int? updatedAt;

}

List<SurfTimelineDetails> loadSurfTimelineDetails(
  List surfTimelineListData,
  {BangumiTimelineType bangumiTimelineType = BangumiTimelineType.timeline}
){

  List<SurfTimelineDetails> surfTimelineDetailsList = [];

  switch(bangumiTimelineType){
    
    case BangumiTimelineType.subject:{
      List<TopicInfo> infoDataList = loadTopicsInfo(surfTimelineListData);

      for(int index = 0; index < infoDataList.length; index++){
        SurfTimelineDetails surfTimelineDetails = SurfTimelineDetails(
          detailID: infoDataList[index].topicID,
        )
          ..bangumiTimelineType = bangumiTimelineType
          ..title = infoDataList[index].topicTitle
          ..sourceTitle = extractNameCNData(surfTimelineListData[index]["subject"])
          ..sourceID = infoDataList[index].subjectID
          ..commentDetails = (
            CommentDetails()
              ..userInformation = loadUserInformations(
                surfTimelineListData[index]["user"] ?? surfTimelineListData[index]["creator"]
              )

          )
          //subject 特属 因为 还有 reples:[]
          ..replies = surfTimelineListData[index]["replyCount"]
          ..updatedAt = surfTimelineListData[index]["updatedAt"]

        ;

        surfTimelineDetailsList.add(surfTimelineDetails);
      }

    }
      
    case BangumiTimelineType.group:{
      List<GroupTopicInfo> groupDataList = loadGroupTopicInfo(surfTimelineListData);

      for(int index = 0; index < groupDataList.length; index++){
        SurfTimelineDetails surfTimelineDetails = SurfTimelineDetails(
          //groupTopicID
          detailID: surfTimelineListData[index]["id"],
        )
          ..bangumiTimelineType = bangumiTimelineType
          ..title = groupDataList[index].groupInfo?.groupTitle
          ..sourceTitle = groupDataList[index].groupInfo?.groupName
          //groupID
          ..sourceID = groupDataList[index].groupInfo?.groupID
          ..commentDetails = (
            CommentDetails()
              ..userInformation = loadUserInformations(
                surfTimelineListData[index]["user"] ?? surfTimelineListData[index]["creator"]
              )
          )
          ..replies = surfTimelineListData[index]["replyCount"]
          ..updatedAt = surfTimelineListData[index]["updatedAt"]

        ;

        surfTimelineDetailsList.add(surfTimelineDetails);
      }

    }
      
    case BangumiTimelineType.timeline:{
      List<TimelineDetails> timelineDataList = loadTimelineDetails(surfTimelineListData);

      for(int index = 0; index < timelineDataList.length; index++){

        SurfTimelineDetails surfTimelineDetails = SurfTimelineDetails(
          detailID: timelineDataList[index].timelineID,
        )
          ..bangumiTimelineType = bangumiTimelineType
            //筛选时间线是否吐槽 则会以 commentDetails 是否含有 comment && bangumiTimelineType 判断
            ..title = 
              //Not Have BBCode
              surfTimelineListData[index]?["memo"]?["status"]?["tsukkomi"] ??  
              //BBCode
              convertTimelineDescription(timelineDataList[index])

          ..commentDetails = (
            CommentDetails()
              ..userInformation = loadUserInformations(
                surfTimelineListData[index]["user"] ?? surfTimelineListData[index]["creator"]
              )
          )
          ..replies = surfTimelineListData[index]["replies"]
          ..updatedAt = surfTimelineListData[index]["updatedAt"]

        ;

        surfTimelineDetailsList.add(surfTimelineDetails);
      }
    }

    default:{}

  }

  return surfTimelineDetailsList;
}

