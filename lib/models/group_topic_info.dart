

import 'package:bangu_lite/models/base_info.dart';
import 'package:bangu_lite/models/group_details.dart';

import 'package:bangu_lite/models/topic_info.dart';

class GroupTopicInfo extends BaseInfo {
  GroupTopicInfo({super.id});
  
  TopicInfo? topicInfo;
  GroupInfo? groupInfo;

  factory GroupTopicInfo.empty() => GroupTopicInfo(id: 0);
}

List<GroupTopicInfo> loadGroupTopicInfo(List bangumiGroupTopicsListData){

  List<GroupTopicInfo> groupTopicInfoList = List.generate(
    bangumiGroupTopicsListData.length, 
    (index){
      return GroupTopicInfo.empty()
	  	..topicInfo = loadTopicsInfo([bangumiGroupTopicsListData[index]]).first
        ..groupInfo = loadGroupsInfo([bangumiGroupTopicsListData[index]["group"]]).first
        
      ;
    }
  );

 
  return groupTopicInfoList;
}