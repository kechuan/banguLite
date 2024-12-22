

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
					..commentTimeStamp = currentEpCommentMap["createdAt"]
						..userId = currentEpCommentMap["user"]["id"]
						..avatarUrl = currentEpCommentMap["user"]["avatar"]["large"]
						..nickName = currentEpCommentMap["user"]["nickname"]
						..sign = currentEpCommentMap["user"]["sign"]
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


enum CommentState {
  normal(), // 正常
  adminCloseTopic(), // 关闭
  adminReopen(), // 重开
  adminPin(), // 置顶
  adminMerge(), // 合并
  adminSilentTopic(), // 下沉
  aserDelete(), // 自行删除
  adminDelete(), // 管理员删除
  adminOffTopic(); // 折叠

  const CommentState();
}