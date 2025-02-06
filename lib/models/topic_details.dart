
import 'package:bangu_lite/models/ep_details.dart';
import 'package:dio/dio.dart';

class TopicDetails {
  int? topicID;
  String? title;
  String? content;
  int? createdTime;
  int? state;

  Map<int,Set<String>>? topicReactions;
  List<EpCommentDetails>? topicRepliedComment;

}

TopicDetails loadTopicDetails(Response bangumiTopicDetailResponse){

	Map topicList = bangumiTopicDetailResponse.data;
	TopicDetails currentTopic = TopicDetails();
	List topicRepliedListData = bangumiTopicDetailResponse.data["replies"];

	currentTopic
		..topicID = topicList["id"]
		..title = topicList["title"]
		..content = topicList["content"]
		..state = topicList["state"]
		..createdTime = topicList["createdAt"]
		..topicRepliedComment = loadEpCommentDetails(topicRepliedListData)
    
    //..topicRepliedComment = loadTopicCommentDetails(topicRepliedListData)
	;

	return currentTopic;

}

//@Deprecated("25.2.1 API patch interface")
//List<EpCommentDetails> loadTopicCommentDetails(
//  List epCommentListData,
//  {int? repilyCommentIndex}
//){

//	final List<EpCommentDetails> currentEpCommentList = [];

//	int currentCommentIndex = 0;

//	for(Map currentEpCommentMap in epCommentListData){
//		EpCommentDetails currentEpComment = EpCommentDetails();

//		currentCommentIndex++;

//			currentEpComment
//        ..userID = currentEpCommentMap["creatorID"]
//        ..commentTimeStamp = currentEpCommentMap["createdAt"]
//        ..comment = currentEpCommentMap["content"]
//        ..state = currentEpCommentMap["state"]
        
//        /* 
//          2025.1 更新 v1接口把 topic 回复的 user/creator 数据剔除了 
//          但非常神奇的是 又在回复里保留了这些数据
//        */

//        ..avatarUrl = currentEpCommentMap["creator"]?["avatar"]["large"]
//        ..nickName = currentEpCommentMap["creator"]?["nickname"]
//        ..sign = currentEpCommentMap["creator"]?["sign"]
//        ..commentReactions = loadReactionDetails(currentEpCommentMap["reactions"])
//        ..epCommentIndex = repilyCommentIndex != null ? "$repilyCommentIndex-$currentCommentIndex" : "$currentCommentIndex"
//			;

//			if(
//        currentEpCommentMap["replies"] != null &&
//        currentEpCommentMap["replies"].isNotEmpty
//      ){

//        List<EpCommentDetails> currentEpCommentRepliedList = loadTopicCommentDetails(
//          currentEpCommentMap["replies"],
//          repilyCommentIndex: currentCommentIndex
//        );
//				currentEpComment.repliedComment = currentEpCommentRepliedList;

//			}

//			currentEpCommentList.add(currentEpComment);
//	} 

//	 return currentEpCommentList;

//}
