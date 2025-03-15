
import 'package:bangu_lite/models/base_details.dart';
import 'package:bangu_lite/models/ep_details.dart';

class TopicDetails extends ContentDetails{

  TopicDetails({
    super.detailID,
    super.contentTitle,
    super.contentRepliedComment,
  });

  int? get topicID => detailID;
  set topicID(int? value) => detailID = value;

  String? get topicTitle => contentTitle;
  set topicTitle(String? value) => contentTitle = value;

  List<EpCommentDetails>? get topicRepliedComment => contentRepliedComment;
  set topicRepliedComment(List<EpCommentDetails>? value) => contentRepliedComment = value;

  factory TopicDetails.empty() => TopicDetails()..detailID = 0;

}

TopicDetails loadTopicDetails(Map<String,dynamic> topicData){

	final currentTopic = TopicDetails();

	currentTopic
		..topicID = topicData["id"]
		..topicTitle = topicData["title"]
		..content = topicData["content"]
		..state = topicData["state"]
		..createdTime = topicData["createdAt"]
		..topicRepliedComment = loadEpCommentDetails(topicData["replies"])
	;

	return currentTopic;

}
