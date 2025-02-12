
import 'package:bangu_lite/models/ep_details.dart';
import 'package:dio/dio.dart';

class CommentDetails {

  int? userId;
  String? nickName;
  String? avatarUrl;
  
  String? comment;
  int? commentTimeStamp;
  int? rate;
  int? type;

  Map<int,Set<String>>? commentReactions;
  
}


List<CommentDetails> loadCommentResponse(Response commentDetailResponse) {

    final List<CommentDetails> commentDetailsList = [];

    Map<String,dynamic> commentResponse = commentDetailResponse.data;
    

    List commentResponseList = commentResponse["data"]; //不要试图给请求假设类型 Map也不行!!


    for(Map currentComment in commentResponseList){

      //debugPrint("${currentComment.runtimeType}, $currentComment");

      final CommentDetails commentDetails = CommentDetails();
      
        commentDetails
          ..userId = currentComment["user"]["id"]
          ..nickName = currentComment["user"]["nickname"]
          ..rate = currentComment["rate"]
          ..type = currentComment["type"]
          ..avatarUrl = currentComment["user"]["avatar"]["medium"]
          
          ..comment = currentComment["comment"]
          ..commentTimeStamp = currentComment["updatedAt"]
          ..commentReactions = loadReactionDetails(currentComment["reactions"])

        ;
      
      commentDetailsList.add(commentDetails);

    }

    //debugPrint("comment parse done, commentStamp: ${DateTime.now()}");

    return commentDetailsList;

  }

