
import 'package:bangu_lite/models/informations/subjects/base_details.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/informations/subjects/group_details.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';

class GroupTopicDetails extends ContentDetails {
  GroupTopicDetails({
    super.detailID,
  });

  String? get groupTopicTitle => contentTitle;
  set groupTopicTitle(String? value) => contentTitle = value;
  //String? groupTopicTitle;

  GroupInfo? groupInfo;

  int? get groupTopicID => detailID;
  
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
      ..contentRepliedComment = loadEpCommentDetails(bangumiGroupTopicData['replies'])
    ;

  return currentGroupTopicDetails;
}