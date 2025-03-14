

import 'package:bangu_lite/models/user_details.dart';

class EpCommentDetails{

    String? comment;
    String? epCommentIndex;
    int? commentTimeStamp;
    Map<int,Set<String>>? commentReactions;
    int? state;
    List<EpCommentDetails>? repliedComment;

    UserDetails? userInformation;
    
}


List<EpCommentDetails> loadEpCommentDetails(
  List epCommentListData,
  {int? repilyCommentIndex}
){

	final List<EpCommentDetails> currentEpCommentList = [];

	int currentCommentIndex = 0;

	for(Map currentEpCommentMap in epCommentListData){
		EpCommentDetails currentEpComment = EpCommentDetails();
    UserDetails currentUserInformation = loadUserDetails(currentEpCommentMap["user"] ?? currentEpCommentMap["creator"]);

		currentCommentIndex+=1;

			currentEpComment
        ..comment = currentEpCommentMap["content"]
        ..state = currentEpCommentMap["state"]
        ..commentTimeStamp = currentEpCommentMap["createdAt"]

        //user => epComment / creator => topicComment
        ..userInformation = currentUserInformation

        ..epCommentIndex = repilyCommentIndex != null ? "$repilyCommentIndex-$currentCommentIndex" : "$currentCommentIndex"
        ..commentReactions = loadReactionDetails(currentEpCommentMap["reactions"])
			;

			if(
        currentEpCommentMap["replies"]!=null &&
        currentEpCommentMap["replies"].isNotEmpty 
      ){

				List<EpCommentDetails> currentEpCommentRepliedList = loadEpCommentDetails(
          currentEpCommentMap["replies"],
          repilyCommentIndex: currentCommentIndex
        );

				currentEpComment.repliedComment = currentEpCommentRepliedList;

			}

			currentEpCommentList.add(currentEpComment);
	} 

	 return currentEpCommentList;

}

Map<int,Set<String>> loadReactionDetails(List? reactionListData){
  Map<int,Set<String>> reactionCount = {};

  if(reactionListData == null) return reactionCount;

  for(Map currentReaction in reactionListData){

    reactionCount.addAll({
      currentReaction["value"] : 
      currentReaction["users"].map<String>(
        (currentUser) => currentUser["nickname"].toString()
      ).toSet()
    });
    
  }

  return reactionCount;
}