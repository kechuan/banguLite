
import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/models/user_details.dart';
import 'package:dio/dio.dart';

class CommentDetails {

  UserInformations? userInformations;

  //int? userName;
  //String? nickName;
  //String? avatarUrl;
  
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
          ..userInformations = loadUserInformations(currentComment["user"])
          

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

