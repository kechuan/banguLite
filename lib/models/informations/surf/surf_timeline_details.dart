import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/utils/extract.dart';
import 'package:bangu_lite/models/informations/subjects/base_details.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';

import 'package:bangu_lite/models/informations/subjects/group_topic_info.dart';
import 'package:bangu_lite/models/informations/surf/timeline_details.dart';
import 'package:bangu_lite/models/informations/subjects/topic_info.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';

class SurfTimelineDetails extends BaseDetails {
  SurfTimelineDetails({
    super.detailID
  });

  CommentDetails? commentDetails;

  String? title;
  
  BangumiSurfTimelineType? bangumiSurfTimelineType;
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
      ..bangumiSurfTimelineType = surfTimelineDetails.bangumiSurfTimelineType
      ..sourceTitle = surfTimelineDetails.sourceTitle
      ..sourceID = surfTimelineDetails.sourceID
      ..replies = surfTimelineDetails.replies
      ..updatedAt = DateTime.now().millisecondsSinceEpoch;
  }


}


List<SurfTimelineDetails> loadSurfTimelineDetails(
  List<dynamic> surfTimelineListData,
  {
    BangumiSurfTimelineType bangumiSurfTimelineType = BangumiSurfTimelineType.timeline,
  }
){

  List<SurfTimelineDetails> surfTimelineDetailsList = [];

  switch(bangumiSurfTimelineType){
    
    case BangumiSurfTimelineType.subject:{
      List<TopicInfo> infoDataList = loadTopicsInfo(surfTimelineListData);

      for(int index = 0; index < infoDataList.length; index++){
        SurfTimelineDetails surfTimelineDetails = SurfTimelineDetails(
          detailID: infoDataList[index].topicID,
        )
          ..bangumiSurfTimelineType = bangumiSurfTimelineType
          ..title = infoDataList[index].topicTitle
          ..sourceTitle = extractNameCNData(surfTimelineListData[index]["subject"])
          //破坏行为
          ..sourceID = infoDataList[index].sourceID
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
      
    case BangumiSurfTimelineType.group:{
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
          detailID: groupDataList[index].topicID,
        )
          ..bangumiSurfTimelineType = bangumiSurfTimelineType
          ..title = groupDataList[index].topicTitle
          ..sourceTitle = groupDataList[index].groupInfo?.groupTitle
          //groupID
          ..sourceID = groupDataList[index].groupInfo?.groupName
          ..commentDetails = (
            CommentDetails()
              ..userInformation = groupDataList[index].userInformation
          )
          ..replies = groupDataList[index].repliesCount
          ..updatedAt = groupDataList[index].lastRepliedTime

        ;

        surfTimelineDetailsList.add(surfTimelineDetails);
      }

    }
      
    case BangumiSurfTimelineType.timeline:{
      List<TimelineDetails> timelineDataList = loadTimelineDetails(surfTimelineListData);

      for(int index = 0; index < timelineDataList.length; index++){

        SurfTimelineDetails surfTimelineDetails = SurfTimelineDetails(
          detailID: timelineDataList[index].timelineID,
        )
          ..bangumiSurfTimelineType = bangumiSurfTimelineType
            //筛选时间线是否吐槽 则会以 commentDetails 是否含有 comment && BangumiSurfTimelineType 判断
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

