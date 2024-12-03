
import 'package:dio/dio.dart';

class CommentDetails {

  int? userId;
  String? nickName;
  String? avatarUri;
  
  String? comment;
  int? commentTimeStamp;
  int? rate;
  
}


List<CommentDetails> loadCommentResponse(Response commentDetailResponse) {

    final List<CommentDetails> commentDetailsList = [];

    Map<String,dynamic> commentResponse = commentDetailResponse.data;
    

    List commentResponseList = commentResponse["data"]; //不要试图给请求假设类型 Map也不行!!


    for(var currentComment in commentResponseList){

      //debugPrint("${currentComment.runtimeType}, $currentComment");

      final CommentDetails commentDetails = CommentDetails();
      
        commentDetails
          ..avatarUri = currentComment["user"]["avatar"]["medium"]
          ..userId = currentComment["user"]["id"]
          ..nickName = currentComment["user"]["nickname"]
          ..comment = currentComment["comment"]
          ..rate = currentComment["rate"]
          ..commentTimeStamp = currentComment["updatedAt"]
        ;
      
      commentDetailsList.add(commentDetails);

    }

    //debugPrint("comment parse done, commentStamp: ${DateTime.now()}");

    return commentDetailsList;

  }

