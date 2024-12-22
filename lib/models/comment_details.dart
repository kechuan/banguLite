
import 'package:dio/dio.dart';

class CommentDetails {

  int? userId;
  String? nickName;
  String? avatarUrl;
  
  String? comment;
  int? commentTimeStamp;
  int? rate;
  int? type;
  
}


List<CommentDetails> loadCommentResponse(Response commentDetailResponse) {

    final List<CommentDetails> commentDetailsList = [];

    Map<String,dynamic> commentResponse = commentDetailResponse.data;
    

    List commentResponseList = commentResponse["data"]; //不要试图给请求假设类型 Map也不行!!


    for(Map currentComment in commentResponseList){

      //debugPrint("${currentComment.runtimeType}, $currentComment");

      final CommentDetails commentDetails = CommentDetails();
      
        commentDetails
          ..avatarUrl = currentComment["user"]["avatar"]["medium"]
          ..userId = currentComment["user"]["id"]
          ..nickName = currentComment["user"]["nickname"]
          ..comment = currentComment["comment"]
          ..rate = currentComment["rate"]
          ..type = currentComment["type"]
          ..commentTimeStamp = currentComment["updatedAt"]
        ;
      
      commentDetailsList.add(commentDetails);

    }

    //debugPrint("comment parse done, commentStamp: ${DateTime.now()}");

    return commentDetailsList;

  }

