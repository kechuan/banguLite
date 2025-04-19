import 'package:bangu_lite/models/base_info.dart';
import 'package:bangu_lite/models/user_details.dart';

// GroupDetails 与 GroupInfo 的数据结构高度一致 直接无需编写 GroupInfo
class GroupDetails extends ContentInfo {
  GroupDetails({
    super.id,
  });

  int? get groupID => id;

  //导航用
  String? groupName;

  String? get title => contentTitle;
  set title(String? value) => contentTitle = value;
  
  String? groupAvatar;
  int? membersCount;
  bool? accessible;

  //以下 Deatails 专属 Info 缺失
  int? topicsCount;
  String? groupDescription;
  UserDetails? groupCreator;

  factory GroupDetails.empty() => GroupDetails(id: 0);

}

List<GroupDetails> loadGroupDetails(List bangumiGroupsListData){

  List<GroupDetails> groupDetailsList = [];

  for(var bangumiGroupsData in bangumiGroupsListData){

    GroupDetails currentGroupDetails = GroupDetails(
      id: bangumiGroupsData['id'],
    );

    currentGroupDetails
      ..groupName = bangumiGroupsData['name']
      ..title = bangumiGroupsData['title']
      ..groupAvatar = bangumiGroupsData['icon']['large']
      ..groupDescription = bangumiGroupsData['description']
      ..membersCount = bangumiGroupsData['members']
      ..topicsCount = bangumiGroupsData['topics']
      ..createdTime = bangumiGroupsData['createdAt']
      ..accessible = bangumiGroupsData['accessible']
      ..groupCreator = loadUserDetails(bangumiGroupsData['creator'])
    ;

    groupDetailsList.add(currentGroupDetails);
  }

  return groupDetailsList;
}
