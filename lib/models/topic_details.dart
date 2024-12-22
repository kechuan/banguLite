



import 'package:bangu_lite/models/ep_details.dart';
import 'package:dio/dio.dart';

class TopicDetails {
  int? id;
  String? title;
  String? content;
  int? createdTime;
  int? state;
  
  List<EpCommentDetails>? repliedComment;

}

TopicDetails loadTopicDetails(Response bangumiTopicDetailResponse){

	Map topicList = bangumiTopicDetailResponse.data;

	TopicDetails currentTopic = TopicDetails();

	List topicRepliedListData = bangumiTopicDetailResponse.data["replies"];



	final List<EpCommentDetails> topicRepliedList = loadTopicCommentDetails(topicRepliedListData);

	currentTopic
		..id = 	topicList["id"]
		..title = topicList["title"]
		..content = topicList["text"]
		..state = topicList["state"]
		..createdTime = topicList["createdAt"]
		..repliedComment = topicRepliedList
	;

	return currentTopic;

}

List<EpCommentDetails> loadTopicCommentDetails(List epCommentListData){

	//List epCommentListData = bangumiEpDetailResponse.data;

	final List<EpCommentDetails> currentEpCommentList = [];

	int currentCommentIndex = 0;

	for(Map currentEpCommentMap in epCommentListData){
		EpCommentDetails currentEpComment = EpCommentDetails();

		currentCommentIndex++;

			currentEpComment
        ..comment = currentEpCommentMap["text"]
        ..commentTimeStamp = currentEpCommentMap["createdAt"]
        ..userId = currentEpCommentMap["creator"]["id"]
        ..avatarUrl = currentEpCommentMap["creator"]["avatar"]["large"]
        ..nickName = currentEpCommentMap["creator"]["nickname"]
        ..sign = currentEpCommentMap["creator"]["sign"]
        ..epCommentIndex = "$currentCommentIndex"
			;

			if(currentEpCommentMap["replies"].isNotEmpty){

				int currentRepliedCommentIndex = 0;

				List<EpCommentDetails> currentEpCommentRepliedList = [];

				for(Map currentEpCommentMap in currentEpCommentMap["replies"]){
					currentRepliedCommentIndex++;
					EpCommentDetails currentEpRepliedComment = EpCommentDetails();

					currentEpRepliedComment
            ..comment = currentEpCommentMap["text"]
            ..commentTimeStamp = currentEpCommentMap["createdAt"]
            ..userId = currentEpCommentMap["creator"]["id"]
            ..avatarUrl = currentEpCommentMap["creator"]["avatar"]["large"]
            ..nickName = currentEpCommentMap["creator"]["nickname"]
            ..sign = currentEpCommentMap["creator"]["sign"]
						..epCommentIndex = "$currentCommentIndex-$currentRepliedCommentIndex"
					;

					currentEpCommentRepliedList.add(currentEpRepliedComment);
			
				}

				currentEpComment.repliedComment = currentEpCommentRepliedList;

			}

			currentEpCommentList.add(currentEpComment);
	} 

	 return currentEpCommentList;

}