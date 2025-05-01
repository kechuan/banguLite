import 'package:bangu_lite/models/base_info.dart';
import 'package:bangu_lite/models/user_details.dart';


class TopicInfo extends ContentInfo {

  TopicInfo({
    super.id,
    super.contentTitle,
    
  });

  int? get topicID => id;
  set topicID(int? value) => id = value;

  String? get topicTitle => contentTitle;
  set topicTitle(String? value) => contentTitle = value;

  int? get subjectID => sourceID;
  set subjectID(int? value) => sourceID = value;

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
        ..subjectID = currentTopicMap["parentID"]
        ..topicID = currentTopicMap["id"]
        ..topicTitle = currentTopicMap["title"]
        ..createdTime = currentTopicMap["createdAt"]
        ..repliesCount = currentTopicMap["replyCount"]
        ..lastRepliedTime = currentTopicMap["updatedAt"]
        ..userInformation = currentUserInformation
      ;

			topicsList.add(currentTopic);
	} 

	 return topicsList;

}