
import 'package:bangu_lite/models/base_details.dart';
import 'package:bangu_lite/models/ep_details.dart';

class TopicDetails extends BaseDetails {

  TopicDetails();

  int? topicID;
  String? title;
  String? content;
  int? createdTime;
  int? state;

  Map<int,Set<String>>? topicReactions;
  List<EpCommentDetails>? topicRepliedComment;



  factory TopicDetails.empty() => TopicDetails()..topicID = 0;

}

TopicDetails loadTopicDetails(Map<String,dynamic> topicData){

	final currentTopic = TopicDetails();

	currentTopic
		..topicID = topicData["id"]
		..title = topicData["title"]
		..content = topicData["content"]
		..state = topicData["state"]
		..createdTime = topicData["createdAt"]
		..topicRepliedComment = loadEpCommentDetails(topicData["replies"])
	;

	return currentTopic;

}
