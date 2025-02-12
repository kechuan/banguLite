
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
