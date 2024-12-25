

class EpCommentDetails{
    int? userId;
    String? epCommentIndex;

    String? nickName; //
    String? avatarUrl;
    String? sign;
    String? comment;
    List<EpCommentDetails>? repliedComment;
    
    int? commentTimeStamp;
	  int? state;
    

}


//List<EpCommentDetails> loadEpCommentDetails(Response bangumiEpDetailResponse){
List<EpCommentDetails> loadEpCommentDetails(List epCommentListData){

	//List epCommentListData = bangumiEpDetailResponse.data;

	final List<EpCommentDetails> currentEpCommentList = [];

	int currentCommentIndex = 0;

	for(Map currentEpCommentMap in epCommentListData){
		EpCommentDetails currentEpComment = EpCommentDetails();

		currentCommentIndex++;

			currentEpComment
        ..comment = currentEpCommentMap["content"]
        ..state = currentEpCommentMap["state"]
        ..commentTimeStamp = currentEpCommentMap["createdAt"]
        ..userId = currentEpCommentMap["user"]["id"]
        ..avatarUrl = currentEpCommentMap["user"]["avatar"]["large"]
        ..nickName = currentEpCommentMap["user"]["nickname"]
        ..sign = currentEpCommentMap["user"]["sign"]
        ..epCommentIndex = "$currentCommentIndex"
			;

			if(currentEpCommentMap["replies"].isNotEmpty){

				int currentRepliedCommentIndex = 0;

				List<EpCommentDetails> currentEpCommentRepliedList = [];

				for(Map currentEpCommentMap in currentEpCommentMap["replies"]){
					currentRepliedCommentIndex++;
					EpCommentDetails currentEpRepliedComment = EpCommentDetails();

					currentEpRepliedComment
					..comment = currentEpCommentMap["content"]
          ..state = currentEpCommentMap["state"]
					..commentTimeStamp = currentEpCommentMap["createdAt"]
          ..epCommentIndex = "$currentCommentIndex-$currentRepliedCommentIndex"
						..userId = currentEpCommentMap["user"]["id"]
						..avatarUrl = currentEpCommentMap["user"]["avatar"]["large"]
						..nickName = currentEpCommentMap["user"]["nickname"]
						..sign = currentEpCommentMap["user"]["sign"]
					;

					currentEpCommentRepliedList.add(currentEpRepliedComment);
			
				}

				currentEpComment.repliedComment = currentEpCommentRepliedList;

			}

			currentEpCommentList.add(currentEpComment);
	} 

	 return currentEpCommentList;

}

