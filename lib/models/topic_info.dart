import 'package:dio/dio.dart';

class TopicInfo{
	int? topicID;
  String? topicName;

  int? creatorID;
  String? creatorNickName;
  String? creatorSign;
  String? creatorAvatarUrl;
  int? createdTime;

  int? repliesCount;
  String? lastRepliedNickName;
  int? lastRepliedTime;
}

List<TopicInfo> loadTopicsInfo(Response bangumiTopicsInfoResponse){
//Map<int,TopicInfo> loadTopicsInfo(Response bangumiTopicsInfoResponse){

	List topicListData = bangumiTopicsInfoResponse.data["data"];

	final List<TopicInfo> topicsList = [];

	for(Map currentTopicMap in topicListData){
		TopicInfo currentTopic = TopicInfo();

			currentTopic
        ..topicID = currentTopicMap["id"]
        ..topicName = currentTopicMap["title"]
        ..creatorID = currentTopicMap["creator"]["id"]
        ..creatorNickName = currentTopicMap["creator"]["nickname"]
        ..creatorSign = currentTopicMap["creator"]["sign"]
        ..creatorAvatarUrl = currentTopicMap["creator"]["avatar"]["large"]
        ..createdTime = currentTopicMap["createdAt"]
        ..repliesCount = currentTopicMap["replies"]
        //..lastRepliedNickName = currentTopicMap[""]
        ..lastRepliedTime = currentTopicMap["updatedAt"]
      ;

			topicsList.add(currentTopic);
	} 

	 return topicsList;

}