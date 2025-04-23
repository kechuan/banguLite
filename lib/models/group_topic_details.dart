
import 'package:bangu_lite/models/base_details.dart';
import 'package:bangu_lite/models/group_details.dart';
import 'package:bangu_lite/models/user_details.dart';

class GroupTopicDetails extends ContentDetails {
  GroupTopicDetails({
    super.detailID,
  });

  GroupInfo? groupInfo;

  int? get groupTopicID => detailID;
  String? groupTopicTitle;
  int? topicReplyCount;


  factory GroupTopicDetails.empty() => GroupTopicDetails(detailID: 0);
}

GroupTopicDetails loadGroupTopicDetails(Map<String,dynamic> bangumiGroupTopicData){

  GroupTopicDetails currentGroupTopicDetails = GroupTopicDetails(
      detailID: bangumiGroupTopicData['id'],
    );

    currentGroupTopicDetails
      ..groupInfo = loadGroupsInfo([bangumiGroupTopicData["group"]]).first
      ..userInformation = loadUserInformations(bangumiGroupTopicData['creator'])
      ..createdTime = bangumiGroupTopicData['createdAt']
      ..updatedTime = bangumiGroupTopicData['updatedAt']
      ..groupTopicTitle = bangumiGroupTopicData['title']
      ..topicReplyCount = bangumiGroupTopicData['replyCount']
    ;

  return currentGroupTopicDetails;
}