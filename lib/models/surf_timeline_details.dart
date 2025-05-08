import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/extract.dart';
import 'package:bangu_lite/models/base_details.dart';
import 'package:bangu_lite/models/comment_details.dart';

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
  dynamic sourceID;
  
  int? replies;
  int? updatedAt;

  SurfTimelineDetails copyWithUpdateAt(SurfTimelineDetails surfTimelineDetails) {
    return SurfTimelineDetails(
      detailID: surfTimelineDetails.detailID,
    )
      ..commentDetails = surfTimelineDetails.commentDetails
      ..title = surfTimelineDetails.title
      ..bangumiTimelineType = surfTimelineDetails.bangumiTimelineType
      ..sourceTitle = surfTimelineDetails.sourceTitle
      ..sourceID = surfTimelineDetails.sourceID
      ..replies = surfTimelineDetails.replies
      ..updatedAt = DateTime.now().millisecondsSinceEpoch;
  }

}


List<SurfTimelineDetails> loadSurfTimelineDetails(
  List<dynamic> surfTimelineListData,
  {
    BangumiTimelineType bangumiTimelineType = BangumiTimelineType.timeline,
  }
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
          //破坏行为
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
      //isGroupSource 从 group来源得到的就已经是 GroupTopicInfo 了

      List<GroupTopicInfo> groupDataList;

      if(surfTimelineListData is List<GroupTopicInfo>){
        groupDataList = surfTimelineListData;
      }

      else{
        groupDataList = loadGroupTopicInfo(surfTimelineListData);
      }


      for(int index = 0; index < groupDataList.length; index++){
        SurfTimelineDetails surfTimelineDetails = SurfTimelineDetails(
          //groupTopicID
          detailID: groupDataList[index].topicInfo?.topicID,
        )
          ..bangumiTimelineType = bangumiTimelineType
          ..title = groupDataList[index].topicInfo?.topicTitle
          ..sourceTitle = groupDataList[index].groupInfo?.groupTitle
          //groupID
          ..sourceID = groupDataList[index].groupInfo?.groupName
          ..commentDetails = (
            CommentDetails()
              ..userInformation = groupDataList[index].topicInfo?.userInformation
          )
          ..replies = groupDataList[index].topicInfo?.repliesCount
          ..updatedAt = groupDataList[index].topicInfo?.lastRepliedTime

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
          ..title = convertTimelineDescription(timelineDataList[index],isCommentDeclared: false)
          ..commentDetails = timelineDataList[index].commentDetails
          ..replies = surfTimelineListData[index]["replies"]
          ..updatedAt = surfTimelineListData[index]["createdAt"]
        ;

        surfTimelineDetailsList.add(surfTimelineDetails);



      }
    }

    default:{}

  }

  return surfTimelineDetailsList;
}

