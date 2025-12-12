
import 'package:bangu_lite/models/informations/subjects/base_details.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';

class TopicDetails extends ContentDetails{

  TopicDetails({
    super.detailID,
    super.contentTitle,
    super.contentRepliedComment,
  });

  int? get topicID => detailID;
  //set topicID(int? value) => detailID = value;

  String? get topicTitle => contentTitle;
  set topicTitle(String? value) => contentTitle = value;

  List<EpCommentDetails>? get topicRepliedComment => contentRepliedComment;
  set topicRepliedComment(List<EpCommentDetails>? value) => contentRepliedComment = value;

  factory TopicDetails.empty() => TopicDetails(detailID: 0);

}

TopicDetails loadTopicDetails(Map<String,dynamic> topicData){

	final currentTopic = TopicDetails(
    detailID: topicData["id"]
  );

	currentTopic
		..topicTitle = topicData["title"]
		..content = topicData["replies"].isEmpty ? "" : topicData["replies"]?.first["content"] ?? ""
    ..contentReactions = topicData["replies"].isEmpty ? {} : loadReactionDetails(topicData["replies"]?.first["reactions"])
		..state = topicData["state"]
		..createdTime = topicData["createdAt"]
		..topicRepliedComment = loadEpCommentDetails(topicData["replies"]).skip(1).toList()
    ..userInformation = loadUserInformations(topicData["creator"])
	;



	return currentTopic;

}
