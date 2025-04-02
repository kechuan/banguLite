
import 'package:bangu_lite/models/user_details.dart';
import 'package:dio/dio.dart';

abstract class BaseComment {
  BaseComment({
    this.commentID,
    this.userInformation,
    this.comment,
    this.commentTimeStamp,
    this.commentReactions,
  });

  int? commentID;
  UserInformation? userInformation;
  String? comment;
  int? commentTimeStamp;
  Map<int,Set<String>>? commentReactions;

  

}

class CommentDetails extends BaseComment{

  //普通 comment 没有回复 也没有index
  int? rate;
  int? type;
}

class EpCommentDetails extends BaseComment{
  String? epCommentIndex;

  int? state;
  List<EpCommentDetails>? repliedComment;

}


List<CommentDetails> loadCommentResponse(Response commentDetailResponse) {

    final List<CommentDetails> commentDetailsList = [];

    Map<String,dynamic> commentResponse = commentDetailResponse.data;
    

    List commentResponseList = commentResponse["data"]; //不要试图给请求假设类型 Map也不行!!


    for(Map currentComment in commentResponseList){

      //debugPrint("${currentComment.runtimeType}, $currentComment");

      final CommentDetails commentDetails = CommentDetails();
      
        commentDetails
          ..commentID = currentComment["id"]
          ..userInformation = loadUserInformations(currentComment["user"])
          

          ..rate = currentComment["rate"]
          ..type = currentComment["type"]
          
          
          ..comment = currentComment["comment"]
          ..commentTimeStamp = currentComment["updatedAt"]
          ..commentReactions = loadReactionDetails(currentComment["reactions"])

        ;
      
      commentDetailsList.add(commentDetails);

    }

    //debugPrint("comment parse done, commentStamp: ${DateTime.now()}");

    return commentDetailsList;

  }

List<EpCommentDetails> loadEpCommentDetails(
  List epCommentListData,
  {int? repilyCommentIndex}
){

	final List<EpCommentDetails> currentEpCommentList = [];

	int currentCommentIndex = 0;

	for(Map currentEpCommentMap in epCommentListData){
		EpCommentDetails currentEpComment = EpCommentDetails();
    UserInformation currentUserInformation = loadUserInformations(currentEpCommentMap["user"] ?? currentEpCommentMap["creator"]);

		currentCommentIndex+=1;

			currentEpComment
        ..commentID = currentEpCommentMap["id"]
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
