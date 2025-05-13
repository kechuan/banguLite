import 'package:bangu_lite/models/informations/subjects/base_info.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';

class GroupInfo extends ContentInfo {
  GroupInfo({
    super.id,
  });

  int? get groupID => id;

  //API导航用
  String? groupName;

  //展示的title
  String? get groupTitle => contentTitle;
  set groupTitle(String? value) => contentTitle = value;
  
  String? groupAvatar;
  int? membersCount;
  bool? accessible;


  factory GroupInfo.empty() => GroupInfo(id: 0);

}

// GroupDetails 与 GroupInfo 的数据结构高度一致
class GroupDetails extends GroupInfo {
  GroupDetails({
    super.id,
  });

  //GroupInfo? groupInfo;

  //以下 Deatails 专属 Info 缺失
  int? topicsCount;
  String? groupDescription;
  UserInformation? groupCreator;

  factory GroupDetails.empty() => GroupDetails(id: 0);

  factory GroupDetails.fromInfo(GroupInfo info) {
    return GroupDetails(id: info.id)
      ..groupName = info.groupName
      ..groupAvatar = info.groupAvatar
      ..membersCount = info.membersCount
      ..accessible = info.accessible
      ..contentTitle = info.contentTitle;
  }

}

List<GroupInfo> loadGroupsInfo(List bangumiGroupsListData){

  List<GroupInfo> groupInfoList = [];

  for(var bangumiGroupsData in bangumiGroupsListData){

    GroupInfo currentGroupInfo = GroupInfo(id: bangumiGroupsData['id']);

    currentGroupInfo
      ..groupName = bangumiGroupsData['name']
      ..groupTitle = bangumiGroupsData['title']
      ..groupAvatar = bangumiGroupsData['icon']['large']
      ..membersCount = bangumiGroupsData['members']
      ..createdTime = bangumiGroupsData['createdAt']
      ..accessible = bangumiGroupsData['accessible']
    ;

    groupInfoList.add(currentGroupInfo);
  }

  return groupInfoList;
}

List<GroupDetails> loadGroupDetails(List bangumiGroupsListData){

  List<GroupDetails> groupDetailsList = List.generate(
    bangumiGroupsListData.length,
    (index){
      return 
        GroupDetails.fromInfo(loadGroupsInfo([bangumiGroupsListData[index]]).first)
          ..groupDescription = bangumiGroupsListData[index]['description']
          ..topicsCount = bangumiGroupsListData[index]['topics']
          ..groupCreator = loadUserInformations(bangumiGroupsListData[index]['creator'])
      ;
    }
  );

  return groupDetailsList;
}
