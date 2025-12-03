import 'package:bangu_lite/models/informations/subjects/base_info.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';


class TopicInfo extends ContentInfo {

  TopicInfo({
    super.id,
    super.contentTitle,
  });

  int? get topicID => id;
  set topicID(int? value) => id = value;

  String? get topicTitle => contentTitle;
  set topicTitle(String? value) => contentTitle = value;

  /// 原本它应该直接归类到 [ContentDetails] 中的 
  /// 但是因为访问政策导致你都无法获取 [TopicDetails] 的内容就被返回404了
  /// 只能在这里单开一个变量了
  int? commentState;

  //int? get subjectID => sourceID;
  //set subjectID(int? value) => sourceID = value;

  factory TopicInfo.empty() {
    return TopicInfo(id: 0);
  }
}

List<TopicInfo> loadTopicsInfo(List bangumiTopicsInfoData){

	final List<TopicInfo> topicsList = [];

	for(Map currentTopicMap in bangumiTopicsInfoData){
		TopicInfo currentTopic = TopicInfo();
    	UserInformation currentUserInformation = loadUserInformations(currentTopicMap["creator"] ?? currentTopicMap["user"] );

      currentTopic
        ..sourceID = currentTopicMap["parentID"]
        ..topicID = currentTopicMap["id"]
        ..topicTitle = currentTopicMap["title"]
        ..createdTime = currentTopicMap["createdAt"]
        ..repliesCount = currentTopicMap["replyCount"]
        ..commentState = currentTopicMap["state"]
        ..lastRepliedTime = currentTopicMap["updatedAt"]
        ..userInformation = currentUserInformation
      ;

    topicsList.add(currentTopic);
	} 

	 return topicsList;

}

