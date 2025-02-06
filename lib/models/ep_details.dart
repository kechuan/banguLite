

class EpCommentDetails{
    int? userID;
    String? epCommentIndex;

    String? nickName; //
    String? avatarUrl;
    String? sign;
    int? state;
    String? comment;
    int? commentTimeStamp;

    Map<int,Set<String>>? commentReactions;

    List<EpCommentDetails>? repliedComment;
    
    
}


List<EpCommentDetails> loadEpCommentDetails(
  List epCommentListData,
  {int? repilyCommentIndex}
){

	final List<EpCommentDetails> currentEpCommentList = [];

	int currentCommentIndex = 0;

	for(Map currentEpCommentMap in epCommentListData){
		EpCommentDetails currentEpComment = EpCommentDetails();

		currentCommentIndex++;

			currentEpComment
        ..comment = currentEpCommentMap["content"]
        ..state = currentEpCommentMap["state"]
        ..commentTimeStamp = currentEpCommentMap["createdAt"]

        //user => epComment / creator => topicComment
        ..userID = currentEpCommentMap["user"]?["id"] ?? currentEpCommentMap["creatorID"]
        ..avatarUrl = currentEpCommentMap["user"]?["avatar"]["large"] ?? currentEpCommentMap["creator"]?["avatar"]["large"]
        ..nickName = currentEpCommentMap["user"]?["nickname"] ?? currentEpCommentMap["creator"]?["nickname"]
        ..sign = currentEpCommentMap["user"]?["sign"] ?? currentEpCommentMap["creator"]?["sign"]

        //..epCommentIndex = "$currentCommentIndex"
        ..epCommentIndex = repilyCommentIndex != null ? "$repilyCommentIndex-$currentCommentIndex" : "$currentCommentIndex"
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
        //(currentUser) => currentUser["nickname"]
        (currentUser) => currentUser["nickname"].toString()
      ).toSet()
    });
    
  }

  return reactionCount;
}