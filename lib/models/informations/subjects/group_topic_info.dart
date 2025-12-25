

import 'package:bangu_lite/models/informations/subjects/group_details.dart';

import 'package:bangu_lite/models/informations/subjects/topic_info.dart';

class GroupTopicInfo extends TopicInfo {
  GroupTopicInfo({super.id});

  GroupInfo? groupInfo;

  factory GroupTopicInfo.empty() => GroupTopicInfo(id: 0);

  factory GroupTopicInfo.fromTopicInfo(TopicInfo topicInfo){
    return GroupTopicInfo()
      ..topicTitle = topicInfo.topicTitle
      ..topicID = topicInfo.topicID
      ..userInformation = topicInfo.userInformation
      ..repliesCount = topicInfo.repliesCount
      ..commentState = topicInfo.commentState
      ..createdTime = topicInfo.createdTime
      ..updatedTime = topicInfo.updatedTime
    ;
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

      return GroupTopicInfo.fromTopicInfo(currentTopicInfo)
        ..groupInfo = groupInfo ?? loadGroupsInfo([bangumiGroupTopicsListData[index]?["group"]]).first
      ;

    }
  );

 
  return groupTopicInfoList;
}

