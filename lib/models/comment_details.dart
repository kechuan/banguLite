
import 'package:dio/dio.dart';

class CommentDetails {

  int? userId;
  String? nickName;
  String? avatarUri;
  
  String? comment;
  int? commentTimeStamp;
  int? rate;

  static List<CommentDetails> loadCommentResponse(Response commentDetailResponse) {

    List<CommentDetails> commentDetailsList = [];

    Map<String,dynamic> commentResponse = commentDetailResponse.data;
    

    List commentResponseList = commentResponse["list"]; //不要试图给请求假设类型 Map也不行!!


    for(var currentComment in commentResponseList){

      //debugPrint("${currentComment.runtimeType}, $currentComment");

      final CommentDetails commentDetails = CommentDetails();

      commentDetails.avatarUri = currentComment["user"]["avatar"]["medium"];
      commentDetails.userId = currentComment["user"]["id"];
      commentDetails.nickName = currentComment["user"]["nickname"];

      commentDetails.comment = currentComment["comment"];
      commentDetails.rate = currentComment["rate"];
      commentDetails.commentTimeStamp = currentComment["updatedAt"];
      
      commentDetailsList.add(commentDetails);

    }

    //debugPrint("comment parse done, commentStamp: ${DateTime.now()}");

    return commentDetailsList;

  }

  
}


