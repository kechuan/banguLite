

import 'package:bangu_lite/models/informations/subjects/group_details.dart';import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';

import 'package:bangu_lite/models/informations/subjects/topic_info.dart';

class GroupTopicInfo extends TopicInfo {
  GroupTopicInfo({super.id});

  //TopicInfo? topicInfo;
  GroupInfo? groupInfo;

  factory GroupTopicInfo.empty() => GroupTopicInfo(id: 0);

  factory GroupTopicInfo.fromSurfTimeline(SurfTimelineDetails surfTimelineData){
    return GroupTopicInfo(
      id: surfTimelineData.detailID
    )
      ..topicTitle = surfTimelineData.title
      ..topicID = surfTimelineData.detailID
      ..sourceID = surfTimelineData.sourceID
      ..userInformation = surfTimelineData.commentDetails?.userInformation
      ..repliesCount = surfTimelineData.replies
    
    ..groupInfo = (
      GroupInfo()
        ..groupTitle = surfTimelineData.sourceTitle
        ..groupName = surfTimelineData.sourceID
    );
  }
}

List<GroupTopicInfo> loadGroupTopicInfo(
  List bangumiGroupTopicsListData,
  {GroupInfo? groupInfo}
){

  List<GroupTopicInfo> groupTopicInfoList = List.generate(
    bangumiGroupTopicsListData.length, 
    (index){

      final TopicInfo currentTopicInfo = loadTopicsInfo([bangumiGroupTopicsListData[index]]).first;

      return GroupTopicInfo(
        //id: currentTopicInfo.topicID
      )
        ..topicTitle = currentTopicInfo.topicTitle
        ..topicID = currentTopicInfo.topicID
        ..userInformation = currentTopicInfo.userInformation
        ..repliesCount = currentTopicInfo.repliesCount

        /// /p1/groups/{groupName}/topics 数据来源不存在 groupInfo
        ..groupInfo = groupInfo ?? loadGroupsInfo([bangumiGroupTopicsListData[index]?["group"]]).first

      ;
    }
  );

 
  return groupTopicInfoList;
}

