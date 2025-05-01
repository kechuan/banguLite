
import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/models/user_details.dart';
import 'package:dio/dio.dart';

abstract class BaseComment {
  BaseComment({


    // CommentDetails 实际上不需要这个字段 
    // 但。。有些 通用的页面需要这个字段。而我不可能就为了这一个字段再开一个 特化的类
    // 那就干脆直接填平好了
    this.contentID,

    this.commentID,
    this.userInformation,
    this.comment,
    this.commentTimeStamp,
    this.commentReactions,
  });

  int? contentID;

  int? commentID;
  UserInformation? userInformation;
  String? comment;
  int? commentTimeStamp;
  Map<int,Set<String>>? commentReactions;

  factory BaseComment.empty(){
    throw UnimplementedError('factory should implemented in subclass');
  }

}

class CommentDetails extends BaseComment{

  CommentDetails({
    super.commentID
  });

  //普通 comment 没有回复 也没有index
  int? rate;
  //int? type;
  StarType? type;

  factory CommentDetails.empty() => CommentDetails(commentID: 0);
}

class EpCommentDetails extends BaseComment{
  EpCommentDetails({super.commentID});

  List<EpCommentDetails>? repliedComment;

  String? epCommentIndex;

  int? state;


  factory EpCommentDetails.empty() => EpCommentDetails(commentID: 0);
}


List<CommentDetails> loadCommentResponse(Response commentDetailResponse) {

  //例子: https://next.bgm.tv/p1/subjects/295884/comments?limit=1
  // Uri().path =>/p1/subjects/295884/comments 

  commentDetailResponse.requestOptions.path;

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
          ..type = StarType.values.firstWhere(
            (element) => element.starTypeIndex == currentComment["type"]
          )

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
        // not pass in GroupTopicDetails
        ..contentID = currentEpCommentMap["mainID"]
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
