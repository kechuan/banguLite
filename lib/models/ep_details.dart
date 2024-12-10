import 'package:dio/dio.dart';

class EpCommentDetails{
    int? userId;
    String? epCommentIndex;

    String? nickName; //
    String? avatarUri;
    String? sign;
    String? comment;
    List<EpCommentDetails>? repliedComment;
    
    int? commentTimeStamp;
    int? rate;

}


List<EpCommentDetails> loadEpCommentDetails(Response bangumiEpDetailResponse){

	List epCommentList = bangumiEpDetailResponse.data;

	final List<EpCommentDetails> currentEpCommentList = [];

	int currentCommentIndex = 0;

	for(Map currentEpCommentMap in epCommentList){
		EpCommentDetails currentEpComment = EpCommentDetails();

		currentCommentIndex++;

			currentEpComment
			..comment = currentEpCommentMap["content"]
			..commentTimeStamp = currentEpCommentMap["createdAt"]
			..userId = currentEpCommentMap["user"]["id"]
			..avatarUri = currentEpCommentMap["user"]["avatar"]["large"]
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
						..avatarUri = currentEpCommentMap["user"]["avatar"]["large"]
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