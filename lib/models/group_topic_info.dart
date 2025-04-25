

import 'package:bangu_lite/models/base_info.dart';
import 'package:bangu_lite/models/group_details.dart';
import 'package:bangu_lite/models/surf_timeline_details.dart';

import 'package:bangu_lite/models/topic_info.dart';

class GroupTopicInfo extends ContentInfo {
  GroupTopicInfo({super.id});
  
  TopicInfo? topicInfo;
  GroupInfo? groupInfo;

  @override
  String? get contentTitle => topicInfo?.topicTitle;

  factory GroupTopicInfo.empty() => GroupTopicInfo(id: 0);

  factory GroupTopicInfo.fromSurfTimeline(SurfTimelineDetails surfTimelineData){
    return GroupTopicInfo()
     ..topicInfo = (
      TopicInfo()
        ..contentTitle = surfTimelineData.title
        ..topicID = surfTimelineData.detailID
        ..userInformation = surfTimelineData.commentDetails?.userInformation
        ..repliesCount = surfTimelineData.replies
    )
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
      return GroupTopicInfo.empty()
	  	..topicInfo = loadTopicsInfo([bangumiGroupTopicsListData[index]]).first
      /// /p1/groups/{groupName}/topics 数据来源不存在 groupInfo
      ..groupInfo = groupInfo ?? loadGroupsInfo([bangumiGroupTopicsListData[index]?["group"]]).first

      ;
    }
  );

 
  return groupTopicInfoList;
}

