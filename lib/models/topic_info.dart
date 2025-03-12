import 'package:bangu_lite/models/base_info.dart';
import 'package:bangu_lite/models/user_details.dart';
import 'package:dio/dio.dart';

class TopicInfo extends BaseInfo {

  TopicInfo();

	int? topicID;
  String? topicName;

  //user
  UserDetails? userInformation;


  int? createdTime;
  int? repliesCount;
  String? lastRepliedNickName;
  int? lastRepliedTime;

  factory TopicInfo.empty() {
    return TopicInfo()..topicID = 0;
  }
}

List<TopicInfo> loadTopicsInfo(Response bangumiTopicsInfoResponse){
//Map<int,TopicInfo> loadTopicsInfo(Response bangumiTopicsInfoResponse){

	List topicListData = bangumiTopicsInfoResponse.data["data"];

	final List<TopicInfo> topicsList = [];

	for(Map currentTopicMap in topicListData){
		TopicInfo currentTopic = TopicInfo();
    UserDetails currentUserInformation = loadUserDetails( currentTopicMap["creator"] ?? currentTopicMap["user"] );

			currentTopic
        ..topicID = currentTopicMap["id"]
        ..topicName = currentTopicMap["title"]
        ..createdTime = currentTopicMap["createdAt"]
        ..repliesCount = currentTopicMap["replyCount"]
        ..lastRepliedTime = currentTopicMap["updatedAt"]
        ..userInformation = currentUserInformation
      ;

			topicsList.add(currentTopic);
	} 

	 return topicsList;

}